//
//  MatrixHelper.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 27.05.2021.
//

import Foundation
import simd
import CoreLocation


struct MatrixHelper {
    
    static func rotateAroundY(_ matrix: matrix_float4x4, for degrees: Float) -> matrix_float4x4 {
        var matrix : matrix_float4x4 = matrix
                
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
                
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix//.inverse
    }
    
    static func transform(from distance: CLLocationDistance, with bearing: Float) -> matrix_float4x4 {
        let distanceTransform = simd_float4x4.distanceTransform(-Float(distance))
        let rotation = MatrixHelper.rotateAroundY(matrix_identity_float4x4, for: bearing)
        let transform = simd_mul(rotation, distanceTransform)
        return transform
    }
    
    static func scale(_ matrix: matrix_float4x4, with coeff: Float) -> matrix_float4x4 {
        let scaling = simd_float4x4.scaleTransform(coeff)
        let transform = simd_mul(scaling, matrix)
        return transform
    }
    
    static func scale(_ matrix: matrix_float4x4, with vector: SIMD3<Float>) -> matrix_float4x4 {
        let scaling = simd_float4x4.scaleTransform(vector)
        var transform = simd_mul(scaling, matrix)
        transform.columns.3.x = matrix.columns.3.x
        transform.columns.3.y = matrix.columns.3.y
        transform.columns.3.z = matrix.columns.3.z
        return transform
    }
}
