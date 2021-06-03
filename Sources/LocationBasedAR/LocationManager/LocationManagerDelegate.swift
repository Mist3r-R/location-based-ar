//
//  LocationManagerDelegate.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 15.05.2021.
//

import Foundation
import CoreLocation


public protocol LocationManagerDelegate: class {
    
    // Manage location and heading updates
    func locationManagerDidUpdateLocation(_ location: CLLocation)
    func locationManagerDidUpdateHeading(_ heading: CLLocationDirection, accuracy: CLLocationDirectionAccuracy)
    
    // Manage LocationManager lifecycle
    func locationManagerDidStartServices()
    func locationManagerDidStopServices()
    
    // Manage tracking accuracy
    func loactionManagerDidChangeAccuracy(_ accuracy: LocationTrackingAccuracy)
    
    // Manage authorization changes
    func locationManagerDidChangeAccuracyAuthorization(_ accuracy: CLAccuracyAuthorization)
    func locationManagerDidReceiveRejection()
}


public extension LocationManagerDelegate {
    func locationManagerDidUpdateLocation(_ location: CLLocation) { }
    func locationManagerDidUpdateHeading(_ heading: CLLocationDirection, accuracy: CLLocationDirectionAccuracy) { }
    func locationManagerDidStartServices() { }
    func locationManagerDidStopServices() { }
    func loactionManagerDidChangeAccuracy(_ accuracy: LocationTrackingAccuracy) { }
    func locationManagerDidChangeAccuracyAuthorization(_ accuracy: CLAccuracyAuthorization) { }
    func locationManagerDidReceiveRejection() { }
}

public protocol LocationDataProvider: class {
    func getCurrentLocation() -> CLLocation?
}

public enum LocationTrackingAccuracy: Int {
    case undefined = 0
    case low
    case medium
    case high
    
    var string: String {
        switch self {
        case .undefined: return "undefined"
        case .low: return "low"
        case .medium: return "medium"
        case .high: return "high"
        }
    }
}
