//
//  Settings.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 17.05.2021.
//

import Foundation


enum Setting {
    case peopleOcclusion
    case objectOcclusion
    case lidarDebug
    case anchorOrigins
    case worldOrigin
    case featurePoints
    case collision
    case annotations
    case mapInput
    case arInput
    
    var label: String {
        get {
            switch self {
            case .peopleOcclusion, .objectOcclusion: return "Occlusion"
            case .lidarDebug: return "LiDAR"
            case .anchorOrigins: return "Anchors"
            case .worldOrigin: return "World"
            case .featurePoints: return "Features"
            case .collision: return "Collision"
            case .annotations: return "Annotation"
            case .mapInput: return "Map Input"
            case .arInput: return "AR Input"
            }
        }
    }
    
    var systemIconName: String {
        get {
            switch self {
            case .peopleOcclusion: return "person"
            case .objectOcclusion: return "cube.box.fill"
            case .lidarDebug: return "light.min"
            case .anchorOrigins, .worldOrigin: return "move.3d"
            case .featurePoints: return "camera.filters"
            case .collision: return "sparkles"
            case .annotations: return "text.bubble.fill"
            case .mapInput, .arInput: return "hand.tap.fill"
            }
        }
    }
}
