//
//  MatrixUtils.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 10.05.2021.
//

import GLKit
import CoreLocation


public struct MatrixUtils {
    
    // visible outside the package
    public static func convert(glkMatrix matrix: GLKMatrix4) -> float4x4 {
        return float4x4(SIMD4(matrix.m00, matrix.m01, matrix.m02, matrix.m03),
                        SIMD4(matrix.m10, matrix.m11, matrix.m12, matrix.m13),
                        SIMD4(matrix.m20, matrix.m21, matrix.m22, matrix.m23),
                        SIMD4(matrix.m30, matrix.m31, matrix.m32, matrix.m33))
    }
    
    // invisible outside the package
    static func rotateHorizontally(matrix: simd_float4x4, around radians: Float) -> simd_float4x4 {
        let rotation = GLKMatrix4MakeYRotation(radians)
        return simd_mul(convert(glkMatrix: rotation), matrix)
    }
    
    
    
    
    // visible outside the package
    static func rotateVertically(matrix: simd_float4x4, around radians: Float) -> simd_float4x4 {
        let rotation = GLKMatrix4MakeXRotation(radians)
        return simd_mul(convert(glkMatrix: rotation), matrix)
    }
    
}
