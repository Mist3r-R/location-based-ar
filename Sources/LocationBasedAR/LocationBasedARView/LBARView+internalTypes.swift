//
//  LBARView+utils.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 18.05.2021.
//

import Foundation
import CoreLocation


public extension LBARView {
    
    /// Defines the status of LocationAnchor
    ///
    /// Anchors marked with `.waitingForDisplay` will be shown during next processing.
    /// Anchors marked with `.waitingForHide` witll be hidden during next processing
    enum LocationAnchorStatus: Int {
        case none = 0
        case waitingForDisplay
        case displayed
        case waitingForHide
        case hidden
    }
    
    /// Error which may occure during coordinates translation process
    ///
    /// Same error is also used during anchor creation process
    enum TranslationError: Error {
        case outOfRange
        case forceSkip
        case locationServiceNotReady
    }
    
    /// Error which may occure during `ARWorldMap` processing
    enum WorldMapError: Error {
        case locationUnavailable
        case emptyData
        case arError
        case compressionError
        case decompressionError
        case archiveLoadingError
    }
    
    /// Estimation of anchor's altitude
    ///
    /// `.mapBased`means that altitude data comes from map services
    /// while `.userBased`shows that data is a result of user input
    enum AltitudeEstimation: Int {
        case none = 0
        case mapBased
        case userBased
    }
    
    /// Defines the scheme for anchors scaling
    ///
    /// Values:
    /// - none: The content is not scaled at all
    /// - equal: The content is scaled in a way that all anchors are of same visible size
    /// - normal: The content is scaled based on distance with gradually decreasing visible size
    /// - scaleFaraway: The content is scaled in a way that all anchors are of same visible size and distant anchors appear smaller
    enum ScalingScheme: Int {
        case none = 0
        case equal
        case normal
        case scaleFaraway
    }
    
    /// A helper struct to store info about current scene location
    ///
    /// Stores values of last updated location and its accuracy as well as the camera transform when the update was performed
    internal struct SceneLocaiton {
        
        var lastSceneLocation: CLLocation?
        var lastSceneLocationAccuracy: CLLocationAccuracy?
        var lastCameraPosition: SIMD3<Float>?
        
        init(sceneLocation: CLLocation?, locationAccuracy: CLLocationAccuracy?, cameraPosition: SIMD3<Float>?) {
            self.lastSceneLocation = sceneLocation
            self.lastSceneLocationAccuracy = locationAccuracy
            self.lastCameraPosition = cameraPosition
        }
        
        init() {
            self.init(sceneLocation: nil, locationAccuracy: nil, cameraPosition: nil)
        }
    }
}
