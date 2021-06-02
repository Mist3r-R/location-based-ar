//
//  CLLocation+helpers.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 20.05.2021.
//

import Foundation
import CoreLocation


public extension CLLocation {
    
    convenience init(
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        horizontalAccuracy: CLLocationAccuracy
    ) {
        self.init(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            horizontalAccuracy: horizontalAccuracy
        )
    }
    
    convenience init(
        coordinate: CLLocationCoordinate2D,
        horizontalAccuracy: CLLocationAccuracy,
        altitude: CLLocationDistance? = nil,
        verticalAccuracy: CLLocationAccuracy? = nil
    ) {
        self.init(
            coordinate: coordinate,
            altitude: altitude ?? 0,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: verticalAccuracy ?? 0,
            timestamp: Date()
        )
    }
}


public extension CLLocation {

    var latitude: CLLocationDegrees {
        self.coordinate.latitude
    }
    
    var longitude: CLLocationDegrees {
        self.coordinate.longitude
    }
}

