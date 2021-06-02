//
//  AnchorMapIndicator.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 16.05.2021.
//

import Foundation
import MapKit


public class AnchorIndicator: MKCircle {
    
    public var color: UIColor = .systemGreen
    
    public convenience init(center: CLLocationCoordinate2D, color: UIColor = .systemGreen) {
        self.init(center: center, radius: 3.0)
        self.color = color
    }
}
