//
//  SelectedLocation.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 15.05.2021.
//

import Foundation
import CoreLocation


struct MapLocation: Identifiable {
    let coordinate: CLLocationCoordinate2D
    
    var id: String {
        coordinate.description
    }
    
    var text: String {
        coordinate.description
    }
}
