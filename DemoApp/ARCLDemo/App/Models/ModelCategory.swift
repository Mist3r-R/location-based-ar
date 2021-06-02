//
//  ModelCategory.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 16.05.2021.
//

import SwiftUI


enum ModelCategory: CaseIterable {
    case usdzLocal
    case usdzRemote
    
    var label: String {
        get {
            switch self {
            case .usdzLocal: return "Local USDZ Models"
            case .usdzRemote: return "Remote USDZ Models"
            }
        }
    }
}
