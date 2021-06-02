//
//  Float4x4+distance.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 20.05.2021.
//

import Foundation
import simd


public extension simd_float4x4 {
    
    static func distanceTransform(_ d: Float) -> simd_float4x4 {
        var result = matrix_identity_float4x4
        result.columns.3.z = d
        return result
    }
}

public extension float4x4 {
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return SIMD3<Float>(translation.x, translation.y, translation.z)
        }
        set(newValue) {
            columns.3 = SIMD4<Float>(newValue.x, newValue.y, newValue.z, columns.3.w)
        }
    }
}
