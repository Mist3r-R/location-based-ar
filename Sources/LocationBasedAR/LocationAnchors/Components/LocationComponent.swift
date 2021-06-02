//
//  LocationComponent.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 24.05.2021.
//

import Foundation
import RealityKit
import CoreLocation


public struct LocationComponent: Component {
    
    var coordinate: CLLocationCoordinate2D
    var accuracy: CLLocationAccuracy
    var altitude: CLLocationDistance?
    var altitudeAccuracy: CLLocationAccuracy?
    
}


public protocol HasLocationComponent: Entity {
    var locationComponent: LocationComponent { get set }
}

public extension HasLocationComponent {
    
    var coordinate: CLLocationCoordinate2D {
        get { locationComponent.coordinate }
        set { locationComponent.coordinate = newValue }
    }
    
    var accuracy: CLLocationAccuracy {
        get { locationComponent.accuracy }
        set { locationComponent.accuracy = newValue }
    }
    
    var altitude: CLLocationDistance? {
        get { locationComponent.altitude }
        set { locationComponent.altitude = newValue }
    }
    
    var altitudeAccuracy: CLLocationAccuracy? {
        get { locationComponent.altitudeAccuracy }
        set { locationComponent.altitudeAccuracy = newValue }
    }
    
    var location: CLLocation {
        CLLocation(
            coordinate: coordinate, horizontalAccuracy: accuracy,
            altitude: altitude, verticalAccuracy: altitudeAccuracy
        )
    }
}
