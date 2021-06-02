//
//  ARSessionManager+gestures.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 02.06.2021.
//

import Foundation
import ARKit
import RealityKit
import LocationBasedAR


extension ARSessionManager {
    
    internal func initGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        arView.addGestureRecognizer(tap)
        arView.addGestureRecognizer(longPress)
    }
    
    internal func annotationTapSetup(_ annotation: AnnotationEntity) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedOnAnnotation(_:)))
        annotation.view?.addGestureRecognizer(tap)
    }
    
    @objc func tappedOnAnnotation(_ sender: UITapGestureRecognizer) {
        guard let annotationView = sender.view as? AnnotationView else { return }
        self.arView.bringSubviewToFront(annotationView)
    }
    
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        
        guard allowTap else { return }
        
        // get the tap location
        let tapLocation = recognizer.location(in: arView)
        
        // make ray through location & perform raycasting
        guard let rayResult = arView.ray(through: tapLocation) else { return }
        
        // check if we have collision enabled
        if arView.environment.sceneUnderstanding.options.contains(.collision) {
            // perform collision raycast
            if let transform = arView.meshRaycast(origin: rayResult.origin, direction: rayResult.direction) {
                self.presentMessage(Notification.Raycasting.planeFound)
                self.place(transform)
            } else {
                self.presentMessage(Notification.Raycasting.failed)
            }
        } else {
            // perform basic raycast
            let results = arView.scene.raycast(origin: rayResult.origin, direction: rayResult.direction)
            if let firstResult = results.first {
                // ray passes through virtual object(s)
                self.presentMessage(Notification.Raycasting.objectFound)
            } else {
                // ray doesn't pass through any virtual object, perform plane raycasting
                let planeResults = self.arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any)
                if let firstResult = planeResults.first {
                    // ray passes through recognized plane
                    self.presentMessage(Notification.Raycasting.planeFound)
                    self.place(Transform(matrix: firstResult.worldTransform))
                } else {
                    self.presentMessage(Notification.Raycasting.failed)
                }
            }
        }
    }
    
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let pressLocation = recognizer.location(in: arView)
        if let entity = arView.entity(at: pressLocation) {
            if let anchorEntity = entity.anchor as? AnchorEntity {
                switch anchorEntity.anchoring.target {
                case .anchor(let identifier):
                    self.selectedAnchor = arView.getAnchor(by: identifier)
                default:
                    if let identifier = anchorEntity.anchorIdentifier {
                        self.selectedAnchor = arView.getAnchor(by: identifier, lookupEntities: true)
                    }
                }
            }
        }
    }
}
