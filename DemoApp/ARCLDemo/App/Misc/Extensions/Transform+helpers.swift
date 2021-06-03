//
//  Transform+helpers.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 16.05.2021.
//

import ARKit
import Foundation
import RealityKit


extension Transform {
    init(_ position: SIMD3<Float>, normal: SIMD3<Float>) {
        self.init(matrix: float4x4(position, normal: normal))
    }

    var upVector: SIMD3<Float> {
        return normalize(matrix.columns.1.xyz)
    }

    var rightVector: SIMD3<Float> {
        return normalize(matrix.columns.0.xyz)
    }

    var forwardVector: SIMD3<Float> {
        return normalize(-matrix.columns.2.xyz)
    }
}

extension float4x4 {
    
    public init(_ position: SIMD3<Float>, normal: SIMD3<Float>) {
        // build a transform from the position and normal (up vector, perpendicular to surface)
        let absX = abs(normal.x)
        let absY = abs(normal.y)
        let abzZ = abs(normal.z)
        let yAxis = normalize(normal)
        // find a vector sufficiently different from yAxis
        var notYAxis = yAxis
        if absX <= absY, absX <= abzZ {
            // y of yAxis is smallest component
            notYAxis.x = 1
        } else if absY <= absX, absY <= abzZ {
            // y of yAxis is smallest component
            notYAxis.y = 1
        } else if abzZ <= absX, abzZ <= absY {
            // z of yAxis is smallest component
            notYAxis.z = 1
        } else {
            fatalError("couldn't find perpendicular axis")
        }
        let xAxis = normalize(cross(notYAxis, yAxis))
        let zAxis = cross(xAxis, yAxis)

        self = float4x4(SIMD4<Float>(xAxis, w: 0.0),
                        SIMD4<Float>(yAxis, w: 0.0),
                        SIMD4<Float>(zAxis, w: 0.0),
                        SIMD4<Float>(position, w: 1.0))
    }
}
