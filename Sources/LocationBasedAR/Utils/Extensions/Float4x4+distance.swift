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
    
    static func scaleTransform(_ scale: Float) -> simd_float4x4 {
        var result = matrix_identity_float4x4
        result.columns.0.x = scale
        result.columns.1.y = scale
        result.columns.2.z = scale
        return result
    }
    
    static func scaleTransform(_ vector: SIMD3<Float>) -> simd_float4x4 {
        var result = matrix_identity_float4x4
        result.columns.0.x = vector.x
        result.columns.1.y = vector.y
        result.columns.2.z = vector.z
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

public extension SIMD4 where Scalar == Float {
    init(_ xyz: SIMD3<Float>, w: Float) {
        self.init(xyz.x, xyz.y, xyz.z, w)
    }

    var xyz: SIMD3<Float> {
        get { return SIMD3<Float>(x: x, y: y, z: z) }
        set {
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }
}
