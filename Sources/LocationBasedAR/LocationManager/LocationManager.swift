//
//  LocationManager.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 15.05.2021.
//

import Foundation
import CoreLocation


public class LocationManager: NSObject {
    
    private let locationManager = CLLocationManager()
    
    public var delegate: LocationManagerDelegate?
    
    public override init() {
        super.init()
        
        // setup locationManager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest //kCLLocationAccuracyBestForNavigation
        // self.locationManager.distanceFilter = 5
    }
    
    public func requestAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    public func requestFullAccuracy() {
        self.locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "forAR") { error in
            if let err = error {
                print("\(#file) -- Failed to request full accuracy with error=\(err.localizedDescription)")
            }
            self.delegate?.locationManagerDidChangeAccuracyAuthorization(
                self.locationManager.accuracyAuthorization
            )
        }
    }
    
    public func start() {
        // start tracking location
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        
        // execute any additional logic (if present) after startup
        self.delegate?.locationManagerDidStartServices()
    }
    
    public func stop() {
        // stop tracking location
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopUpdatingHeading()
        
        // execute any additional logic (if present) after updates are stopped
        self.delegate?.locationManagerDidStopServices()
    }
    
    public func getCurrentLocation() -> CLLocation? {
        return self.locationManager.location
    }
    
    func filterAndAddLocation(_ location: CLLocation) -> Bool {
        let age = -location.timestamp.timeIntervalSinceNow
        
        if age > 10 {
//            print("\(#file) -- filterAndAddLocation -- Cashed location")
            return false
        }
        
        if location.horizontalAccuracy < 0 {
//            print("\(#file) -- filterAndAddLocation -- Invalid accuracy")
            return false
        }
        
        // TODO: Make a param?
        if location.horizontalAccuracy > 70 {
//            print("\(#file) -- filterAndAddLocation -- Too high accuracy")
            return false
        }
        
        return true
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .denied, .restricted: self.delegate?.locationManagerDidReceiveRejection()
        case .notDetermined: self.requestAuthorization()
        case .authorizedWhenInUse:
            // check accuracy permissions
            switch manager.accuracyAuthorization {
            case .fullAccuracy: self.start()
            case .reducedAccuracy: self.requestFullAccuracy()
            default: ()
            }
        default: ()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("DEBUG -- LocationManager -- didFailWithError = \(error.localizedDescription)")
        
        if let error = error as? CLError, error.code == .denied {
            self.locationManager.stopMonitoringSignificantLocationChanges()
            return
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // handle location updates
        guard let location = locations.last else { return }
        
        // apply location update filter
        let locationAdded = self.filterAndAddLocation(location)
        
        if locationAdded {
            // handle location update
            self.delegate?.locationManagerDidUpdateLocation(location)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        // handle heading updates
        let heading = newHeading.headingAccuracy >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        let accuracy = newHeading.headingAccuracy
        
        self.delegate?.locationManagerDidUpdateHeading(heading, accuracy: accuracy)
    }
    
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        true
    }
}
