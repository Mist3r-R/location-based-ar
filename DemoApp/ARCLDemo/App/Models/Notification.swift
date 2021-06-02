//
//  Notification.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 02.06.2021.
//

import Foundation


protocol NotificationMessage {
    var title: String { get }
    var message: String { get }
}

struct NotificationWrapper: Identifiable {
    let notification: NotificationMessage
    
    var id: String {
        notification.title + notification.message
    }
}


enum Notification {
    
    enum ARTracking: NotificationMessage {
        case tracking
        case initializing
        case relocalizing
        case tooFast
        case lowFeatures
        
        var message: String {
            switch self {
            case .tracking: return "Tracking is stable."
            case .initializing: return "Limited tracking: initializing..."
            case .relocalizing: return "Limited tracking: relocalizing..."
            case .tooFast: return "Please, slow down."
            case .lowFeatures: return "Limited tracking: poor features."
            }
        }
        
        var title: String {
            "AR Session"
        }
    }
    
    enum Model: NotificationMessage {
        case remote(URLSession.DownloadError)
        case loaded
        
        var message: String {
            switch self {
            case .remote(let err):
                switch err {
                case .cannotDeleteFile: return "Cannot override file."
                case .cannotMoveFile: return "Unable to save file."
                case .failedDownload: return "USDZ downloading failed."
                }
            case .loaded: return "Loaded succesfully"
            }
        }
        
        var title: String {
            "Model Manager"
        }
    }
    
    enum Raycasting: NotificationMessage {
        case planeFound
        case objectFound
        case failed
        
        var message: String {
            switch self {
            case .failed: return "Failed: no surface detected."
            case .objectFound: return "Virtual object tapped."
            case .planeFound: return "Plane surface detected."
            }
        }
        
        var title: String {
            "Raycasting"
        }
    }
}
