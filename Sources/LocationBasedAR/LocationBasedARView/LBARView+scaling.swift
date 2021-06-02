//
//  LBARView+scaling.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 19.05.2021.
//

import Foundation
import CoreLocation


public extension LBARView {
    
    /// Returns scale coefficient for given location
    ///
    /// - Parameters:
    ///     - location: location of an anhor to get scaling for
    ///     - minimumDistance: distance in meters at which the anchor is presented without scaling
    /// - Returns: estimated scaling coefficient or `nil` if anchor is too far or there is no `sceneLocation` data yet
    func getScaling(for location: CLLocation, with minimumDistance: Double = 10.0) -> Float? {
        guard let lastLocation = self.lastSceneLocation else { return nil }
        let distance = lastLocation.haversineDistance(from: location)
        if distance > displayRangeFilter { return nil }
        if distance <= minimumDistance { return 1.0 }
        
        switch self.scalingScheme {
        case .none: break
        case .equal:
            let adjustedDistance = min(distance, maximumVisibleAnchorDistance)
            return Float(adjustedDistance / minimumDistance)
        case .scaleFaraway:
            if distance > maximumVisibleAnchorDistance {
                return Float(maximumVisibleAnchorDistance / minimumDistance) * 0.75
            } else {
                return Float(distance / minimumDistance)
            }
        case .normal:
            let adjustedDistance = min(distance, maximumVisibleAnchorDistance)
            return Float((adjustedDistance / minimumDistance) * (1 - distance / displayRangeFilter))
        }
        
        return 1.0
    }
}
