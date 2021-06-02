//
//  CLLocation+metrics.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 12.05.2021.
//

import Foundation
import CoreLocation


public extension CLLocation {
    
    func haversineDistance(from location: CLLocation) -> CLLocationDistance {
        
        let R: Double = 6_371_000.0 // average earth radius
        
        let dLat = (self.latitude - location.latitude).degreesToRadians
        let dLon = (self.longitude - location.longitude).degreesToRadians
        
        let lat1 = self.latitude.degreesToRadians
        let lat2 = location.latitude.degreesToRadians
        
        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let d = R * c
        
        return d
    }
    
    func bearingBetween(_ point: CLLocation) -> Double {
        let dLon = (self.longitude - point.longitude).degreesToRadians
        let lat1 = self.latitude.degreesToRadians
        let lat2 = point.latitude.degreesToRadians
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let theta = atan2(y, x)
        return theta // in radians
    }
    
    func destination(for distance: Double, with initialBearing: Double) -> CLLocation {
        let destinationPoint = self.coordinate.destination(for: distance, with: initialBearing)
        return CLLocation(coordinate: destinationPoint, horizontalAccuracy: self.horizontalAccuracy)
    }
}


public extension CLLocationCoordinate2D {
    
    // source: https://planetcalc.com/7721/
    func earthRadius() -> Double {
        let WGS84EquatorialRadius  = 6_378_137.0
        let WGS84PolarRadius = 6_356_752.3
        
        // shorter versions to make formulas easier to read
        let equator = WGS84EquatorialRadius
        let polar = WGS84PolarRadius
        let phi = self.latitude.degreesToRadians
        
        let numerator = pow(equator * equator * cos(phi), 2) + pow(polar * polar * sin(phi), 2)
        let denominator = pow(equator * cos(phi), 2) + pow(polar * sin(phi), 2)
        let radius = sqrt(numerator/denominator)
        return radius
    }
    
    func destination(for distance: Double, with initialBearing: Double) -> CLLocationCoordinate2D {
        let lat1 = self.latitude.degreesToRadians
        let lon1 = self.longitude.degreesToRadians
        
        let theta = initialBearing.degreesToRadians
        let delta = distance / self.earthRadius()
        
        let lat2 = asin(sin(lat1) * cos(delta) + cos(lat1) * sin(delta) * cos(theta))
        let y = sin(theta) * sin(delta) * cos(lat1)
        let x = cos(delta) - sin(lat1) * sin(lat2)
        let lon2 = lon1 + atan2(y, x)
        
        return CLLocationCoordinate2D(latitude: lat2.radiansToDegrees, longitude: lon2.radiansToDegrees)
    }
}
