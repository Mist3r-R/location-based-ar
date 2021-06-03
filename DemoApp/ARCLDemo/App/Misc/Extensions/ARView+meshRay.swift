//
//  ARView+meshRay.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 20.05.2021.
//

import Foundation
import RealityKit
import ARKit
import LocationBasedAR

extension ARView {
    
    func meshRaycast(origin: SIMD3<Float>, direction: SIMD3<Float>) -> Transform? {
        
        // Perform RealityKit's raycast
        let collisionResults = scene.raycast(origin: origin, direction: normalize(direction))
        let filteredResults = collisionResults.compactMap { $0.entity as? HasSceneUnderstanding != nil ? $0 : nil }
        guard let hit = filteredResults.first, hit.entity is HasSceneUnderstanding else { return nil }
        return Transform(hit.position, normal: hit.normal)
    }
}


extension LBARView {
    
    func getDistanceString(for anchorId: UUID) -> String? {
        guard let anchorData = self.getAnchor(by: anchorId) else { return nil }
        guard let distance = self.anchorDistances[anchorData.id] else { return nil }
        return distance.distanceString
    }
    
    func resetDistantAnchors() -> [LocationAnchorData] {
        var toRemove = [LocationAnchorData]()
        self.getVisibleAnchors().forEach { anchor in
            if let estimation = anchor.anchor?.locationEstimation,
               estimation == .exact,
               let name = anchor.anchor?.name, name != "LBAnchor" {
                toRemove.append(anchor)
            }
        }
        return toRemove
    }
}

extension LocationAnchorData {
    
    var stringDescription: String {
        "latitude: \(coordinate.latitude.format(f: ".8"))"
            + "\nlongitude: \(coordinate.longitude.format(f: ".8"))"
            + "\nhorizontal accuracy: \(accuracy.format(f: ".1"))"
    }
    
    var title: String {
        if let name = name { return name }
        else if let anchorName = anchor?.name, anchorName != "LBAnchor" { return anchorName }
        else { return "Location Anchor" }
    }
}


extension Double {
    
    var distanceString: String {
        "\(Int(self)) m"
    }
}
