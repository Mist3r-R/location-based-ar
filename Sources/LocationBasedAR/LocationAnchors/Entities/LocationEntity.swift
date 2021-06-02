//
//  LocationEntity.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 26.05.2021.
//

import Foundation
import CoreLocation
import ARKit
import RealityKit


public class LocationEntity: Entity, HasAnchoring, HasLocationComponent {
    
    public var locationComponent: LocationComponent
    
    public init(_ locationComponent: LocationComponent, worldTransform: simd_float4x4) {
        self.locationComponent = locationComponent
        super.init()
        self.transform.matrix = worldTransform
    }
    
    public convenience init(
        worldTransform: simd_float4x4,
        coordinate: CLLocationCoordinate2D,
        accuracy: CLLocationAccuracy,
        altitude: CLLocationDistance? = nil,
        altitudeAccuracy: CLLocationAccuracy? = nil
    ) {
        self.init(
            LocationComponent(
                coordinate: coordinate, accuracy: accuracy,
                altitude: altitude, altitudeAccuracy: altitudeAccuracy
            ),
            worldTransform: worldTransform
        )
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
