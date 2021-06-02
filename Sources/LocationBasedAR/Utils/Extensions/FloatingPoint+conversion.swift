//
//  FloatingPoint+conversion.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 18.05.2021.
//

import Foundation

public extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
