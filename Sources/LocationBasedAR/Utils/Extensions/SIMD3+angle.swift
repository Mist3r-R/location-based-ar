//
//  SIMD3+angleZ.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 19.05.2021.
//

import Foundation
import simd


public extension SIMD3 where Scalar == Float {
    
    /// Calculates the angle between true north and anchor position
    ///
    /// When `.gravityAndHeading` configuration is set the `Z+` axis represents the *South*,
    /// `Z-` represents  the *True North* and `X+`, `X-` are the *East* and *West* respectively. Thus, in order
    /// to calculate the **clockwise** angle between *True North* and a given anchor location (X, Y, Z), we take the following steps
    /// - discard Y coordinate to have a position in `XZ` plane
    /// - calculate the angle between `Z+` axis and `(X, Z)` point
    /// - mirror the angle to have it clockwise
    /// - add `.pi` and perform module division by `2 * .pi`
    /// - convert the result in radians to degrees
    var angleBetweenTrueNorth: Float {
        let radians = atan2(self.x, self.z)
        return (-radians + .pi).truncatingRemainder(dividingBy: 2 * .pi).radiansToDegrees
    }
    
    func distanceFrom(_ translation: SIMD3<Float>) -> Float {
        return distance(translation, self)
    }
    
    static func scaleTransform(_ coeff: Float) -> SIMD3<Float> {
        return [coeff, coeff, coeff]
    }
    
    var resetToHorizon: SIMD3<Float> {
        return [self.x, 0, self.z]
    }
    
    var length: Float {
        return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    }
}
