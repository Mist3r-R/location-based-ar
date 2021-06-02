//
//  ModelEntity+simpleModels.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 16.05.2021.
//

import Foundation
import UIKit
import RealityKit

extension ModelEntity {
    
    static func cubeModel(size: Float = 0.1, color: UIColor = .blue, isMetallic: Bool = true) -> ModelEntity {
        let mesh = MeshResource.generateBox(size: size)
        let material = SimpleMaterial(color: color, roughness: 0.3, isMetallic: isMetallic)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        modelEntity.generateCollisionShapes(recursive: true)
        return modelEntity
    }
    
    static func sphereModel(radius: Float = 0.1, color: UIColor = .blue, isMetallic: Bool = true) -> ModelEntity {
        let mesh =  MeshResource.generateSphere(radius: radius)
        let material = SimpleMaterial(color: color, roughness: 0.3, isMetallic: isMetallic)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        modelEntity.generateCollisionShapes(recursive: true)
        return modelEntity
    }
    
    static func textModel(_ text: String, color: UIColor = .blue, isMetallic: Bool = true) -> ModelEntity {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.1,
            font: .systemFont(ofSize: 0.5),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
        let material = SimpleMaterial(color: color, roughness: 0.3, isMetallic: isMetallic)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        return modelEntity
    }
}

extension ModelComponent {
    
    static func textComponent(_ text: String, color: UIColor = .blue, isMetallic: Bool = true) -> ModelComponent {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.1,
            font: .systemFont(ofSize: 0.5),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
        let material = SimpleMaterial(color: color, roughness: 0.3, isMetallic: isMetallic)
        return ModelComponent(mesh: mesh, materials: [material])
    }
}

extension AnchorEntity {
    
    var textEntity: Entity? {
        self.children.first?.children.first
    }
}
