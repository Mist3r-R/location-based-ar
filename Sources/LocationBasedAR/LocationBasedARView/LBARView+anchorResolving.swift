//
//  File.swift
//  
//
//  Created by Miron Rogovets on 03.06.2021.
//

import Foundation
import ARKit
import RealityKit
import CoreLocation


public extension LBARView {
    
    // Basically, we can have the following situations:
    // (1) Anchor's old distance > visible range   &&   new distance <= visible range      --> show at tracking bound
    // (2) Anchor's old distance > visible range   &&   new distance > visible range       --> skip
    // (3) Anchor's old distance > tracking range  &&   new distance > visible range       --> hide
    // (4) Acnhor's old distance > tracking range  &&   new distance <= tracking range     --> check if position ok (similar to 5.1-3)
    // (5) Anchor's old distance > tracking range  &&   new distance > tracking range      --> configure place on tracking bound
    //     (5.1) Became closer than should be               --> move further right now
    //     (5.2) Became further than should be              --> move closer when possible
    //     (5.3) Remained the same                          --> skip
    // (6) Anchor's old distance <= tracking range &&   new distance > tracking range      --> move to tracking bound when possible
    // (7) Anchor's old distance <= tracking range &&   new distance <= tracking range     --> skip
    
    func updateAnchors() {
        
        guard let currentLocation = lastSceneLocation,
              let currentAccuracy = lastSceneLocationAccuracy,
              let currentCameraPosition = lastCameraPosition else { return }
        
        var updatedIds: [String] = []
        
        // get hidden anchors based on old locations
        let hiddenAnchors = self.anchorDistances
            .filter({ $0.value > self.displayRangeFilter })
            .compactMap({ $0.key })
            .compactMap({ id in self.anchors.first(where: {$0.id == id })})
        
        
        print("\(Date()) -- hidden = \(hiddenAnchors.count)")
        hiddenAnchors.forEach { anchorData in
            let newDistance = currentLocation.haversineDistance(from: anchorData.location)
            self.anchorDistances[anchorData.id] = newDistance
            guard newDistance <= displayRangeFilter else { return } // case (2)
            
            // case (1)
            self.locationToWorldTransform(anchorData.location, from: currentLocation, with: currentAccuracy) { result in
                switch result {
                case .failure(let error): break
                case .success(let transform):
                    let newAnchor: LBAnchor
                    if let oldAnchor = anchorData.anchor {
                        newAnchor = LBAnchor(from: oldAnchor, with: transform)
                        if let entity = anchorData.anchorEntity {
                            if entity.anchoring.target == .anchor(identifier: oldAnchor.identifier) {
                                entity.anchoring = .init(newAnchor)
                            }
                        }
                    } else {
                        newAnchor = LBAnchor(
                            name: anchorData.name ?? "LBAnchor",
                            transform: transform,
                            coordinate: anchorData.coordinate,
                            accuracy: anchorData.accuracy
                        )
                        if let entity = anchorData.anchorEntity {
                            switch entity.anchoring.target {
                            case .anchor(_): entity.anchoring = .init(newAnchor)
                            default: break
                            }
                        }
                    }
                    anchorData.anchor = newAnchor
                    anchorData.status = .waitingForDisplay
                    updatedIds.append(anchorData.id)
                }
            }
        }
        
        // get anchors out of tracking range
        let distantAnchors = self.anchorDistances
            .filter({ $0.value > self.maximumVisibleAnchorDistance && $0.value <= self.displayRangeFilter })
            .compactMap({ $0.key })
            .compactMap({ id in self.anchors.first(where: {$0.id == id })})
        
        print("\(Date()) -- distant = \(distantAnchors.count)")
        distantAnchors.forEach { anchorData in
            let newDistance = currentLocation.haversineDistance(from: anchorData.location)
            guard newDistance <= displayRangeFilter else {
                // case (3)
                self.anchorDistances[anchorData.id] = newDistance
                anchorData.status = .waitingForHide
                updatedIds.append(anchorData.id)
                return
            }
            
            // case (4) & (5)
            guard let oldTransform = anchorData.anchor?.transform else { return }
            let virtualDistance = self.cameraTransform.translation.distanceFrom(oldTransform.translation)
            
            let realDistance = min(newDistance, maximumVisibleAnchorDistance)
            
            print("Checking: \(anchorData.id):\n\tvirtualDistance=\(virtualDistance)\n\tnewDistance=\(newDistance)\n\tmaximumVisibleAnchorDistance=\(maximumVisibleAnchorDistance)\n\tdiff=\(Double(virtualDistance) - realDistance)")
            
            // if difference between real and virtual distance is less than 1%, consider as ok
            guard abs(Double(virtualDistance) - realDistance) > realDistance * 0.01 else {
                self.anchorDistances[anchorData.id] = newDistance
                return // case (5.3)
            }
            
            self.locationToWorldTransform(anchorData.location, from: currentLocation, with: currentAccuracy) { result in
                guard case .success(let newTransform) = result else { return }
                
                self.anchorDistances[anchorData.id] = newDistance
                
                // object is further than should be
                if Double(virtualDistance) - realDistance > 0 {
                    
                    if !self.isInPoV(objectTransform: newTransform, cameraTransform: self.cameraTransform) {
                        
                        if let oldAnchor = anchorData.anchor {
                            let newAnchor = LBAnchor(from: oldAnchor, with: newTransform)
                            self.session.add(anchor: newAnchor)
                            if let entity = anchorData.anchorEntity,
                               entity.anchoring.target == .anchor(identifier: oldAnchor.identifier) {
                                entity.reanchor(.anchor(identifier: newAnchor.identifier))
                            }
                            anchorData.anchor = newAnchor
                            print("Updates to: old=\(oldAnchor.transform) -> \(newTransform)")
                            self.session.remove(anchor: oldAnchor)
                            updatedIds.append(anchorData.id)
                        }
                    }
                    
                } else { // object is closer than should be, need to move away
                    
                    if !self.isInPoV(objectTransform: newTransform, cameraTransform: self.cameraTransform) {
                        
                        if let oldAnchor = anchorData.anchor {
                            let newAnchor = LBAnchor(from: oldAnchor, with: newTransform)
                            self.session.add(anchor: newAnchor)
                            if let entity = anchorData.anchorEntity,
                               entity.anchoring.target == .anchor(identifier: oldAnchor.identifier) {
                                entity.reanchor(.anchor(identifier: newAnchor.identifier))
                            }
                            anchorData.anchor = newAnchor
                            self.session.remove(anchor: oldAnchor)
                            updatedIds.append(anchorData.id)
                        }
                    } else { // object appears in PoV, need to be careful
                        if let oldAnchor = anchorData.anchor {
                            if let entity = anchorData.anchorEntity,
                               entity.anchoring.target == .anchor(identifier: oldAnchor.identifier) {
                                let newTransformPreservingScale = MatrixHelper.scale(newTransform, with: entity.scale)
                                entity.move(to: newTransformPreservingScale, relativeTo: nil, duration: 1.0)
                            }
                            updatedIds.append(anchorData.id)
                        }
                    }
                }
            }
        }
        
        // get anchors in tracking range
        let nearbyAnchors = self.anchorDistances
            .filter({ $0.value <= self.maximumVisibleAnchorDistance })
            .compactMap({ $0.key })
            .compactMap({ id in self.anchors.first(where: {$0.id == id })})
        
        print("\(Date()) -- nearby = \(nearbyAnchors.count)")
        nearbyAnchors.forEach { anchorData in
            let newDistance = currentLocation.haversineDistance(from: anchorData.location)
            self.anchorDistances[anchorData.id] = newDistance
            // case (6)
            if newDistance > maximumVisibleAnchorDistance {
                self.locationToWorldTransform(anchorData.location, from: currentLocation, with: currentAccuracy) { result in
                    guard case .success(let newTransform) = result else { return }
                    
                    if !self.isInPoV(objectTransform: newTransform, cameraTransform: self.cameraTransform) {
                        
                        if let oldAnchor = anchorData.anchor {
                            let newAnchor = LBAnchor(from: oldAnchor, with: newTransform)
                            self.session.add(anchor: newAnchor)
                            if let entity = anchorData.anchorEntity,
                               entity.anchoring.target == .anchor(identifier: oldAnchor.identifier) {
                                entity.reanchor(.anchor(identifier: newAnchor.identifier))
                            }
                            anchorData.anchor = newAnchor
                            self.session.remove(anchor: oldAnchor)
                            updatedIds.append(anchorData.id)
                        }
                    }
                }
            }
        }
        let updatedAnchors = updatedIds
            .compactMap({ id in self.anchors.first(where: { $0.id == id }) })
            .compactMap({ $0.anchor })
        print("UPDATING ANCHORS: \(updatedIds), a total of \(updatedAnchors.count)")
        if !updatedAnchors.isEmpty {
            self.delegate?.view(self, didUpdate: updatedAnchors)
        }
        self.processWaitingAnchors()
    }
    
    internal func isInPoV(objectTransform: float4x4, cameraTransform: Transform) -> Bool {
        let cameraForward = cameraTransform.matrix.columns.2.xyz
        let cameraToWorldPointDirection = normalize(objectTransform.translation - cameraTransform.translation)
        let dotProduct = dot(cameraForward, cameraToWorldPointDirection)
        let isVisible = dotProduct < 0
        return isVisible
    }
}
