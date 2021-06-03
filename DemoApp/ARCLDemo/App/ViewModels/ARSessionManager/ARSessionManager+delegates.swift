//
//  ARSessionManager+delegates.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 02.06.2021.
//

import Foundation
import ARKit
import RealityKit
import LocationBasedAR


extension ARSessionManager: LBARViewDelegate {
    
    func view(_ view: LBARView, didAdd anchors: [LBAnchor]) {
        print("\(#file) -- ARSessionManager/LBARViewDelegate -- didAdd \(anchors.debugDescription)")
        self.addCallback?(anchors)
        anchors.forEach({
            if let name = $0.name, name != "LBAnchor" {
                
                LocalDataManager.shared.save(
                    LocationData(
                        id: self.arView.getAnchor(by: $0.identifier)!.id,
                        name: name,
                        latitude: $0.location.latitude,
                        longitude: $0.location.longitude,
                        accuracy: $0.accuracy
                    ))
                
                if self.showAnnotations {
                    if let projection = self.arView.project($0.transform.translation) {
                        self.createAnnotation(projection: projection, anchor: $0)
                    }
                } else {
                    self.createAnchorEntity(name: name, anchor: $0)
                }
            }
        })
    }
    
    func view(_ view: LBARView, didUpdate anchors: [LBAnchor]) {
        self.addCallback?(anchors)
        anchors.forEach({ lbAnchor in
            if let name = lbAnchor.name,
               name != "LBAnchor",
               let anchorData = self.arView.getAnchor(by: lbAnchor.identifier) {
                
                if self.showAnnotations {
                    
                    if let annotation = self.annotations[lbAnchor.identifier] {
                        annotation.view?.distanceLabel.text = self.arView.getDistanceString(for: lbAnchor.identifier)
                    } else {
                        if let projection = self.arView.project(lbAnchor.transform.translation) {
                            self.createAnnotation(projection: projection, anchor: lbAnchor)
                        }
                    }
                    
                } else {
                    if let anchorEntity = anchorData.anchorEntity,
                       let textEntity = anchorEntity.textEntity as? ModelEntity {
                        
                        let text = ModelComponent.textComponent(name, color: lbAnchor.locationEstimation.color, isMetallic: true)
                        textEntity.components.set(text)
                        
                        if let scaleCoeff = self.arView.getScaling(for: lbAnchor.location, with: 5.0) {
                            
                            anchorEntity.setScale(.scaleTransform(scaleCoeff), relativeTo: nil)
                        }
                    }
                }
            }
        })
    }
    
    func view(_ view: LBARView, didRemove anchors: [LBAnchor]) {
        print("\(#file) -- ARSessionManager/LBARViewDelegate -- didRemove \(anchors.debugDescription)")
        self.removeCallback?(anchors)
        anchors.forEach({ anchor in
            if let annotation = self.annotations[anchor.identifier] {
                annotation.view?.isHidden = true
                annotation.view?.removeFromSuperview()
                self.arView.scene.removeAnchor(annotation)
            }
            self.annotations.removeValue(forKey: anchor.identifier)
        })
    }
}

extension ARSessionManager: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // ...
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        // ...
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        // ...
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        let locationAnchors = anchors.compactMap({ $0 as? LBAnchor })
        for anchor in locationAnchors {
            if let annotation = self.annotations[anchor.identifier] {
                annotation.view?.isHidden = true
                annotation.view?.removeFromSuperview()
                self.arView.scene.removeAnchor(annotation)
                self.annotations.removeValue(forKey: anchor.identifier)
            }
        }
        self.removeCallback?(locationAnchors)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        self.sessionError = SessionError(error)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .limited(let reason):
            switch reason {
            case .initializing: self.presentMessage(Notification.ARTracking.initializing)
            case .excessiveMotion: self.presentMessage(Notification.ARTracking.tooFast)
            case .insufficientFeatures: self.presentMessage(Notification.ARTracking.lowFeatures)
            case .relocalizing: self.presentMessage(Notification.ARTracking.relocalizing)
            @unknown default:
                break
            }
        case .normal: self.presentMessage(Notification.ARTracking.tracking)
        default: break
        }
    }
}


extension ARSessionManager {
    
    func presentMessage(_ notification: NotificationMessage) {
        self.notification = NotificationWrapper(notification: notification)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.notification = nil
        }
    }
}
