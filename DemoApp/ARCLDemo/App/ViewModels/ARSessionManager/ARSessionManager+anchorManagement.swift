//
//  ARSessionManager+anchorManagement.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 02.06.2021.
//

import Foundation
import ARKit
import RealityKit
import LocationBasedAR


extension ARSessionManager {
    
    internal func createAnnotation(projection: CGPoint, anchor: LBAnchor) {
        let frame = CGRect(origin: projection, size: CGSize(width: 200, height: 100))
        let annotation = AnnotationEntity(frame: frame, anchor: anchor)
        annotation.setPositionCenter(projection)
        annotation.view?.distanceLabel.text = self.arView.getDistanceString(for: anchor.identifier)
        self.arView.scene.addAnchor(annotation)
        annotationTapSetup(annotation)
        annotation.view?.showCallback = { [unowned self] in
            self.selectedAnchor = self.arView.getAnchor(by: anchor.identifier)
        }
        guard let annoView = annotation.view else { return }
        
        // Gets the 2D screen point of the 3D world point.
        let translation = annotation.transformMatrix(relativeTo: nil).translation
        guard let projectedPoint = self.arView.project(translation) else { return }
        
        // Calculates whether the note can be currently visible by the camera.
        let cameraForward = arView.cameraTransform.matrix.columns.2.xyz
        let cameraToWorldPointDirection = normalize(translation - self.arView.cameraTransform.translation)
        let dotProduct = dot(cameraForward, cameraToWorldPointDirection)
        let isVisible = dotProduct < 0

        // Updates the screen position of the note based on its visibility
//        annotation.projection = Projection(projectedPoint: projectedPoint, isVisible: isVisible)
//        annotation.updateScreenPosition()
        annotation.view?.isHidden = true
        self.arView.addSubview(annoView)
        self.annotations[anchor.identifier] = annotation
    }
    
    internal func createAnchorEntity(name: String, anchor: LBAnchor) {
        let anchorEntity = AnchorEntity(anchor: anchor)
        let sphere = ModelEntity.sphereModel(radius: 0.1, color: anchor.locationEstimation.color, isMetallic: true)
        let text = ModelEntity.textModel(name, color: anchor.locationEstimation.color, isMetallic: true)
        let offset = -(text.model?.mesh.bounds.center ?? .zero)
        text.setPosition(SIMD3<Float>(offset.x, -offset.y, 0), relativeTo: sphere)
        sphere.addChild(text)
        sphere.generateCollisionShapes(recursive: true)
        anchorEntity.addChild(sphere)
        if let scaleCoeff = self.arView.getScaling(for: anchor.location, with: 5.0) {
            anchorEntity.setScale(.scaleTransform(scaleCoeff), relativeTo: nil)
        }
        self.arView.scene.addAnchor(anchorEntity)
        self.arView.getAnchor(by: anchor.identifier)?.anchorEntity = anchorEntity
    }
    
    // MARK: - Placement Methods
    
    func place(_ modelEntity: ModelEntity) {
        
        let clonedEntity = modelEntity.clone(recursive: true)
        clonedEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: clonedEntity)
        
        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)
        
        arView.scene.addAnchor(anchorEntity)
        
        let matrix = anchorEntity.transformMatrix(relativeTo: nil)
        self.arView.worldTransformToLocation(matrix) { result in
            switch result {
            case .failure(let err): print("err: \(err)")
            case .success(let location):
                self.arView.add(entity: anchorEntity, with: location)
            }
        }
    }
    
    func place(_ transform: Transform) {
        
        self.arView.worldTransformToLocation(transform.matrix) { result in
            switch result {
            case .failure(let err): print("Unable to place entity due to err: \(err)")
            case .success(let location):
                let sphere = ModelEntity.sphereModel(radius: 0.1, color: .systemIndigo, isMetallic: true)
                sphere.generateCollisionShapes(recursive: true)
                let anchorEntity = AnchorEntity(world: transform.matrix)
                anchorEntity.addChild(sphere)
                self.arView.scene.addAnchor(anchorEntity)
                self.arView.add(entity: anchorEntity, with: location)
            }
        }
    }
    
    func add(location: Placemark) {
        self.arView.add(placemark: location)
    }
    
    func delete(anchorData: LocationAnchorData) {
        self.arView.remove(by: anchorData.id)
        LocalDataManager.shared.delete(by: anchorData.id)
    }
    
    func loadCachedAnchors() {
        let cached = LocalDataManager.shared.loadSavedLocations()
        print("\(#file) -- loadCachedAnchors -- count = \(cached.count)")
        let placemarks: [Placemark]
        
        if cached.isEmpty || cached.count > 50 {
            LocalDataManager.shared.clearCache()
             placemarks = LocalDataManager.shared.defaultLocations
        } else {
            placemarks = cached.compactMap({
                guard $0.accuracy < 3 else { return nil }
                LocalDataManager.shared.delete($0)
                return Placemark(
                    coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                    accuracy: $0.accuracy,
                    altitude: nil,
                    altitudeAccuracy: nil,
                    placeName: $0.name
                )
            })
        }
        placemarks.forEach { place in
            let distanceTime = (self.arView.lastSceneLocation?.distance(from: place.location) ?? 0) / 1000
            DispatchQueue.main.asyncAfter(deadline: .now() + distanceTime) {
                self.add(location: place)
            }
        }
    }
}
