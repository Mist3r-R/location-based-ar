//
//  LBARView+locationUpdates.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 19.05.2021.
//

import Foundation
import CoreLocation
import simd


public extension LBARView {
    
    /// Resets `currentSceneLocation` to nil
    ///
    /// Resetting location means that the scene will not receive any update until a new location is obtained
    func resetLocation() {
        self.currentSceneLocation = SceneLocaiton()
        self.trackingStatus = TrackingStatus.initializing(with: .waitingForLocation)
    }
    
    func startLocationUpdateTimer(with interval: TimeInterval = 5) {
        self.locationUpdatesTimer = Timer(timeInterval: interval, target: self, selector: #selector(checkAndUpdateLocation), userInfo: nil, repeats: true)
    }
    
    func stopLocationUpdateTimer() {
        self.locationUpdatesTimer.invalidate()
    }
    
    @objc func checkAndUpdateLocation() {
        if let location = self.locationProvider?.getCurrentLocation() {
            print("DEBUG: -- performing location check and update ...")
            self.updateLocation(location)
        }
    }
    
    /// Updates `currenSceneLocation` with the provided location
    func updateLocation(_ newLocation: CLLocation) {
        _ = self.updateSceneLocation(newLocation)
    }
    
    // Helper method to update currentSceneLocation value
    private func updateSceneLocation(_ newlocation: CLLocation) -> CLLocation {
        
        guard let lastLocation = self.lastSceneLocation,
              let lastAccuracy = self.lastSceneLocationAccuracy,
              let lastCameraPosition = self.lastCameraPosition else {
            // save without any additional checks if first update
            self.setLocation(newlocation, with: newlocation.horizontalAccuracy)
            return newlocation
        }
        if newlocation.horizontalAccuracy < lastAccuracy {
            // new location is more reliable
            self.setLocation(newlocation, with: newlocation.horizontalAccuracy)
            return newlocation
        }
        
        guard needsLocationUpdate() else { return lastLocation }
//        print("\(#file) -- LBARView -- updating to new location = \(newlocation)")
        self.setLocation(newlocation, with: newlocation.horizontalAccuracy)
        return newlocation
    }
    
    // Helper method to check whether the currentSceneLocation value should be updated
    internal func needsLocationUpdate() -> Bool {
        
        guard let lastLocation = self.lastSceneLocation,
              let lastAccuracy = self.lastSceneLocationAccuracy,
              let lastCameraPosition = self.lastCameraPosition else {
            return true
        }
        
        let distanceFromLastPosition = Double((lastCameraPosition.resetToHorizon - self.cameraTransform.translation.resetToHorizon).length)
        
        // last location data is too old
        if -lastLocation.timestamp.timeIntervalSinceNow > 5 { return true }
        
        // traveled distance of device is larger than previous location accuracy range
        if distanceFromLastPosition >= lastAccuracy { return true }
        
        // traveled distance of device is larger than update filter
        if distanceFromLastPosition > locationUpdateFilter { return true }
        
        // current location data is more reliable or the changes are too small, keep on using old one
        return false
    }
    
    // Set provided location as currentSceneLocation 
    private func setLocation(_ newLocation: CLLocation, with accuracy: CLLocationAccuracy) {
        self.currentSceneLocation = SceneLocaiton(
            sceneLocation: newLocation,
            locationAccuracy: accuracy,
            cameraPosition: self.cameraTransform.translation
        )
        self.trackingStatus = TrackingStatus.tracking(with: .init(with: accuracy))
    }
}
