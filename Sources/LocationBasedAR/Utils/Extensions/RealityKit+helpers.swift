//
//  RealityKit+helpers.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 21.05.2021.
//

import Foundation
import RealityKit

public extension AnchorEntity {
    
    var locationEntities: [LocationEntity] {
        return self.children.compactMap({ $0 as? LocationEntity })
    }
}


public extension Scene.AnchorCollection {
    
    func contains(anchor: HasAnchoring) -> Bool {
        return self.contains(where: { $0.id == anchor.id })
    }
}
