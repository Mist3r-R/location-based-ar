//
//  ARWorldMap+helpers.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 21.05.2021.
//

import Foundation
import ARKit


public extension ARWorldMap {
    
    var locationAnchors: [LBAnchor] {
        return anchors.compactMap { $0 as? LBAnchor }
    }
}
