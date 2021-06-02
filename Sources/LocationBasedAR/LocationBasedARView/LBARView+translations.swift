//
//  LBARView+anchors.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 18.05.2021.
//

import Foundation
import CoreLocation
import ARKit
import RealityKit


public extension LBARView {
    
    // typealiases for callbacks
    typealias AnchorResult = ((Result<LBAnchor, TranslationError>) -> Void)
    typealias TransformResult = ((Result<float4x4, TranslationError>) -> Void)
    typealias CLLocationResult = ((Result<CLLocation, TranslationError>) -> Void)
    
    /// Transforms real-world location to AR coordinates' systes
    ///
    /// The result of translation is `LBAnchor` object
    func locationToAnchor(_ location: CLLocation, completion: @escaping AnchorResult) {
        self.locationToWorldTransform(location) { result in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(let transform):
                let anchor = LBAnchor(
                    transform: transform,
                    coordinate: location.coordinate,
                    accuracy: location.horizontalAccuracy
                )
                completion(.success(anchor))
            }
        }
    }
    
    /// Transforms real-world location to AR coordinates' systes
    ///
    /// The result of translaiton is transform maxtrix 4x4 which represents the position and appearance of acnhor
    func locationToWorldTransform( _ location: CLLocation, completion: @escaping TransformResult) {
        guard let currentLocation = self.lastSceneLocation,
              let currentAccuracy = self.lastSceneLocationAccuracy
        else {
            completion(.failure(.locationServiceNotReady))
            return
        }
        
        self.locationToWorldTransform(
            location,
            from: currentLocation,
            with: currentAccuracy,
            completion: completion
        )
    }
    
    /// Transforms AR coordinatates to real-world locatio
    func worldTransformToLocation(_ transform: float4x4, completion: @escaping CLLocationResult) {
        guard let currentLocation = self.lastSceneLocation,
              let currentAccuracy = self.lastSceneLocationAccuracy
        else {
            completion(.failure(.locationServiceNotReady))
            return
        }
        
        let location = self.worldTransformToLocation(transform, from: currentLocation, with: currentAccuracy)
        completion(.success(location))
    }
    
    /// Internal method to translate real-world coordinate to position virtual world
    internal func locationToWorldTransform(
        _ location: CLLocation,
        from currentLocation: CLLocation,
        with accuracy: CLLocationAccuracy,
        completion: @escaping TransformResult
    ) {
        var distance = currentLocation.haversineDistance(from: location)
        
        if distance > displayRangeFilter {
            completion(.failure(.outOfRange))
            return
        }
        
        distance = min(distance, maximumVisibleAnchorDistance)
        
        let distanceTransform = simd_float4x4.distanceTransform(-Float(distance))
        let bearing = currentLocation.bearingBetween(location)
        let rotation = MatrixHelper.rotateAroundY(matrix_identity_float4x4, for: Float(bearing))
        let transform = simd_mul(rotation, distanceTransform)
        
        completion(.success(transform))
        
    }
    
    /// Internal method to translate position in virtual world to real-world coordinate with a given accuracy
    internal func worldTransformToLocation(
        _ transform: float4x4,
        from currentLocation: CLLocation,
        with accuracy: CLLocationAccuracy
    ) -> CLLocation {
        
        let distanceFromCurrentPosition = Double(distance(self.cameraTransform.translation, transform.translation))
        let distanceFromLastPosition = Double(distance(self.lastCameraPosition ?? [0, 0, 0], transform.translation))
        let bearing = Double(transform.translation.angleBetweenTrueNorth)
        
        let distanceToObject = self.needsLocationUpdate() ? distanceFromCurrentPosition : distanceFromLastPosition
        // when object appears closer than 2m away it is more reasonable to use current scene location
        return distanceToObject < 2
            ? currentLocation : currentLocation.destination(for: distanceToObject, with: bearing)
    }
}
