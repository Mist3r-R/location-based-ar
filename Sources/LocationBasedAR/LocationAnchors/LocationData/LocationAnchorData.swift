//
//  LocationAnchors.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 18.05.2021.
//

import Foundation
import ARKit
import RealityKit
import CoreLocation


/// A wrapper class to store location anhcors' data
///
/// Provides the control of anchors tracking and displaying with the reference to assosiated `LBAnchor` and `Entity`
open class LocationAnchorData {
    
    public private(set) var id: String
    public var name: String?
    public private(set) var coordinate: CLLocationCoordinate2D
    public private(set) var accuracy: CLLocationAccuracy
    public private(set) var altitude: CLLocationDistance?
    public private(set) var altitudeAccuracy: CLLocationAccuracy?
    
    public var anchor: LBAnchor? {
        didSet(newValue) {
            // to have full synchronization with LBAnchor data
            guard let value = newValue else { return }
            self.coordinate = value.coordinate
            self.accuracy = value.accuracy
        }
    }
    public var anchorId: UUID? { anchor?.identifier }
    
    public var anchorEntity: AnchorEntity?
    public var entityId: ObjectIdentifier? { anchorEntity?.id }

    public var status: LBARView.LocationAnchorStatus
    
    public var location: CLLocation {
        CLLocation(
            coordinate: coordinate, horizontalAccuracy: accuracy,
            altitude: altitude, verticalAccuracy: altitudeAccuracy
        )
    }
    
    public init(
        coordinate: CLLocationCoordinate2D, accuracy: CLLocationAccuracy,
        altitude: CLLocationDistance? = nil, altitudeAccuracy: CLLocationAccuracy? = nil) {
        
        self.id = UUID().uuidString
        self.coordinate = coordinate
        self.accuracy = accuracy
        self.altitude = altitude
        self.altitudeAccuracy = altitudeAccuracy
        self.status = .none
    }
    
    public convenience init(_ anchor: LBAnchor) {
        self.init(coordinate: anchor.coordinate, accuracy: anchor.accuracy, altitude: anchor.altitude)
        self.anchor = anchor
    }
    
    var locationEstimation: LocationEstimation {
        accuracy < 0 ? .invalid : (accuracy < 3 ? .exact : .approximate)
    }
}

extension LocationAnchorData: Equatable, Identifiable {
    
    public static func == (lhs: LocationAnchorData, rhs: LocationAnchorData) -> Bool {
        return lhs.id == rhs.id
    }
    
}
