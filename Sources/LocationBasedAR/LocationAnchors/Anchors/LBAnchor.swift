//
//  LBAnchor.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 24.05.2021.
//

import Foundation
import ARKit
import RealityKit
import CoreLocation


open class LBAnchor: ARAnchor {
    
    public let coordinate: CLLocationCoordinate2D
    public let accuracy: CLLocationAccuracy
    public let altitude: CLLocationDistance?
    
    public init(
        name: String,
        transform: float4x4,
        coordinate: CLLocationCoordinate2D,
        accuracy: CLLocationDistance,
        altitude: CLLocationDistance? = nil
    ) {
        self.coordinate = coordinate
        self.accuracy = accuracy
        self.altitude = altitude
        super.init(name: name, transform: transform)
    }
    
    // this is guaranteed to be called with anchor of the same class
    required public init(anchor: ARAnchor) {
        let other = anchor as! LBAnchor
        self.coordinate = other.coordinate
        self.accuracy = other.accuracy
        self.altitude = other.altitude
        super.init(anchor: other)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDouble(forKey: "latitude")
        let longitude = aDecoder.decodeDouble(forKey: "longitude")
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.accuracy = aDecoder.decodeDouble(forKey: "accuracy")
        if let decodedAltitude = aDecoder.decodeObject(forKey: "altitude") as? CLLocationDistance {
            self.altitude = decodedAltitude
        } else {
            self.altitude = nil
        }
        super.init(coder: aDecoder)
    }
    
    open override class var supportsSecureCoding: Bool {
        return true
    }
    
    open override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(coordinate.latitude, forKey: "latitude")
        aCoder.encode(coordinate.longitude, forKey: "longitude")
        aCoder.encode(accuracy, forKey: "accuracy")
        if let optionalAltitude = altitude {
            aCoder.encode(optionalAltitude, forKey: "altitude")
        }
    }
    
    public var locationEstimation: LocationEstimation {
        accuracy < 0 ? .invalid : (accuracy < 3 ? .exact : .approximate)
    }
    
    public var location: CLLocation {
        CLLocation(coordinate: coordinate, horizontalAccuracy: accuracy)
    }
}

public extension LBAnchor {
    
    convenience init(transform: float4x4, coordinate: CLLocationCoordinate2D, accuracy: CLLocationDistance) {
        self.init(name: "LBAnchor", transform: transform, coordinate: coordinate, accuracy: accuracy)
    }
    
    convenience init(from oldAnchor: LBAnchor, with newTransform: float4x4) {
        self.init(
            name: oldAnchor.name ?? "LBAnchor",
            transform: newTransform,
            coordinate: oldAnchor.coordinate,
            accuracy: oldAnchor.accuracy
        )
    }
}
