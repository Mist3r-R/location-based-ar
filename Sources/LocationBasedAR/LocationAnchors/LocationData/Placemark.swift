//
//  Placemark.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 18.05.2021.
//

import Foundation
import UIKit
import CoreLocation


/// A wrapper class to store location with optional place name
///
/// Can be used to pass locations to `LBARView`
public struct Placemark: Equatable {
    
    public var placeName: String?
    public var coordinate: CLLocationCoordinate2D
    public var accuracy: CLLocationAccuracy
    public var altitude: CLLocationDistance?
    public var altitudeAccuracy: CLLocationAccuracy?
    
    public init(
        coordinate: CLLocationCoordinate2D,
        accuracy: CLLocationAccuracy,
        altitude: CLLocationDistance? = nil,
        altitudeAccuracy: CLLocationAccuracy? = nil,
        placeName: String? = nil
    ) {
        self.coordinate = coordinate
        self.accuracy = accuracy
        self.altitude = altitude
        self.altitudeAccuracy = altitudeAccuracy
        self.placeName = placeName
    }
    
    public init(location: CLLocation, placeName: String? = nil) {
        self.placeName = placeName
        self.coordinate = location.coordinate
        self.accuracy = location.horizontalAccuracy
        self.altitude = location.altitude
        self.altitudeAccuracy = location.verticalAccuracy
    }
    
    public var latitude: CLLocationDegrees {
        coordinate.latitude
    }

    public var longitude: CLLocationDegrees {
        coordinate.longitude
    }
    
    public var location: CLLocation {
        CLLocation(
            coordinate: coordinate,
            horizontalAccuracy: accuracy,
            altitude: altitude,
            verticalAccuracy: altitudeAccuracy
        )
    }
    
    public static func == (lhs: Placemark, rhs: Placemark) -> Bool {
        return (lhs.location == rhs.location) && (lhs.placeName == rhs.placeName)
    }
    
    public var locationEstimation: LocationEstimation {
        accuracy < 0 ? .invalid : (accuracy < 3 ? .exact : .approximate)
    }
}


public enum LocationEstimation: String {
    case exact
    case approximate
    case invalid
    
    public var color: UIColor {
        switch self {
        case .exact: return .systemGreen
        case .approximate: return .systemYellow
        case .invalid: return .systemRed
        }
    }
}
