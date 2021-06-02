//
//  CLLocationCoordinate+description.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 15.05.2021.
//

import Foundation
import CoreLocation


extension CLLocationCoordinate2D {
    var description: String {
        "lat: \(latitude.format(f: ".8")); lon: \(longitude.format(f: ".8"))"
    }
}


extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
