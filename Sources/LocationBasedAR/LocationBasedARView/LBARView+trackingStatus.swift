//
//  LBARView+trackingStatus.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 21.05.2021.
//

import Foundation
import CoreLocation

public typealias LBARTrackingStatus = LBARView.TrackingStatus

public extension LBARView {
    
    struct TrackingStatus {
        var state: State
        var accuracy: Accuracy
        var reason: StateReason
        
        static func initializing(with reason: StateReason = .none) -> TrackingStatus {
            return TrackingStatus(state: .initializing, accuracy: .undefined, reason: reason)
        }
        
        static func failed(with reason: StateReason) -> TrackingStatus {
            return TrackingStatus(state: .unavailable, accuracy: .undefined, reason: reason)
        }
        
        static func tracking(with accuracy: Accuracy) -> TrackingStatus {
            return TrackingStatus(state: .tracking, accuracy: accuracy, reason: .none)
        }
    }
}


public extension LBARTrackingStatus {
    
    enum State: Int {
        case unavailable = 0
        case initializing
        case tracking
    }
    
    enum Accuracy: Int {
        case undefined = 0
        case low
        case medium
        case high
        
        init(with horizontalAccuracy: CLLocationAccuracy) {
            if horizontalAccuracy < 0 { self = .undefined }
            else {
                if horizontalAccuracy < 15 { self = .high }
                else if horizontalAccuracy < 35 { self = .medium }
                else if horizontalAccuracy < 70 { self = .low }
                else { self = .undefined }
            }
        }
    }
    
    enum StateReason: Int {
        case none = 0
        case waitingForLocation
        case needLocationPermissions
        case locationServiceUnavailable
        case locationTrackingUnstable
    }
}
