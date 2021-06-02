//
//  LBARView+configuration.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 18.05.2021.
//

import Foundation
import ARKit


public extension LBARView {
    
    static func defaultConfiguration() -> ARWorldTrackingConfiguration {
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading
        config.planeDetection = [.horizontal, .vertical]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            config.sceneReconstruction = .meshWithClassification
        }
        
        return config
    }
}
