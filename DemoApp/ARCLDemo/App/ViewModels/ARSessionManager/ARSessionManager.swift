//
//  ARSessionManager.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 25.05.2021.
//

import SwiftUI
import ARKit
import RealityKit
import Combine
import LocationBasedAR


class ARSessionManager: NSObject, ObservableObject {
    
    // MARK: - Session Settings Properties
    @Published var isPeopleOcclusionEnabled: Bool = false { willSet(newValue) { updatePeopleOcclusion(isEnabled: newValue) }}
    @Published var isObjectOcclusionEnabled: Bool = false { willSet(newValue) { updateObjectOcclusion(isEnabled: newValue) }}
    @Published var isLidarDebugEnabled: Bool = false { willSet(newValue) { updateLidarDebug(isEnabled: newValue) }}
    @Published var isAnchorOriginsEnabled: Bool = false { willSet(newValue) { updateAnchorOrigins(isEnabled: newValue) }}
    @Published var isWorldOriginEnabled: Bool = false { willSet(newValue) { updateWorldOrigin(isEnabled: newValue) }}
    @Published var areFeaturePointsEnabled: Bool = false { willSet(newValue) { updateFeaturePoints(isEnabled: newValue) }}
    @Published var isCollisionEnabled: Bool = false { willSet(newValue) { updateCollision(isEnabled: newValue) }}
    
    @Published var showAnnotations: Bool = false {
        didSet(newValue) {
            self.resetAnnotations()
            self.arView.resetDistantAnchors()
        }
    }
    
    @Published var allowTap: Bool = false
    
    // MARK: - ARView Properties
    @Published var selectedAnchor: LocationAnchorData? = nil
    @Published var sessionError: SessionError? = nil
    @Published var notification: NotificationWrapper? = nil
    @Published var arView: FocusedARView = FocusedARView(frame: .zero)
    
    var annotations: [UUID: AnnotationEntity] = [:]
//    @Published var isRunning: Bool
    
    var addCallback: (([LBAnchor]) -> Void)?
    var removeCallback: (([LBAnchor]) -> Void)?
    
    override init() {
//        self.isRunning = false
        super.init()
        
        self.arView.session.delegate = self
        self.arView.delegate = self
        self.initGestures()
        self.startSession()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    
    // MARK: - Session Lifecycle Management
    
    public func startSession() {
//        self.isRunning = true
        self.run(defaultConfig)
    }
    
    public func stopSession() {
        // ...
        self.arView.session.pause()
    }
    
    public func resetSession() {
        
        if !self.annotations.isEmpty { self.resetAnnotations() }
        
        self.arView.removeAll()
        
        if let config = arView.session.configuration as? ARWorldTrackingConfiguration {
            self.run(config, options: [.removeExistingAnchors, .resetTracking])
        } else {
            self.run(defaultConfig, options: [.removeExistingAnchors, .resetTracking])
        }
    }
    
    func receive(location update: CLLocation?) {
//        if !isRunning { self.startSession() }
        if let newLocation = update {
            self.arView.updateLocation(newLocation)
        }
    }
    
    public func updateAnnotations() {
        for (id, anno) in annotations {
            // Gets the 2D screen point of the 3D world point.
            let translation = anno.transformMatrix(relativeTo: nil).translation
            guard let projectedPoint = self.arView.project(translation) else { return }
            
            // Calculates whether the note can be currently visible by the camera.
            let cameraForward = arView.cameraTransform.matrix.columns.2.xyz
            let cameraToWorldPointDirection = normalize(translation - self.arView.cameraTransform.translation)
            let dotProduct = dot(cameraForward, cameraToWorldPointDirection)
            let isVisible = dotProduct < 0

            // Updates the screen position of the note based on its visibility
            anno.projection = Projection(projectedPoint: projectedPoint, isVisible: isVisible)
            anno.updateScreenPosition()
            
            if anno.anchorIdentifier != nil && anno.anchorIdentifier != id && !isVisible {
                anno.reanchor(.anchor(identifier: id))
            }
        }
    }
    
    // MARK: - Private Methods & Properties
    
    private func run(_ configuration: ARWorldTrackingConfiguration, options: ARSession.RunOptions = []) {
        self.arView.session.run(configuration, options: options)
    }
    
    private var defaultConfig: ARWorldTrackingConfiguration {
        return LBARView.defaultConfiguration()
    }
    
    private func resetAnnotations() {
        for (id, anno) in annotations {
            anno.view?.removeFromSuperview()
        }
    }
    
    // MARK: - Session Settings Methods
    private func updatePeopleOcclusion(isEnabled: Bool) {
        print("\(#file) isPeopleOcclusionEnabled = \(isEnabled)")
        
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else { return }
        guard let configuration = self.arView.session.configuration as? ARWorldTrackingConfiguration else { return }
        
        if configuration.frameSemantics.contains(.personSegmentationWithDepth) {
            configuration.frameSemantics.remove(.personSegmentationWithDepth)
        } else {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        self.run(configuration)
    }
    
    private func updateObjectOcclusion(isEnabled: Bool) {
        print("\(#file) isObjectOcclusionEnabled = \(isEnabled)")
        self.arView.updateSceneUnderstandingOptions(.occlusion, isEnabled)
    }
    
    private func updateLidarDebug(isEnabled: Bool) {
        print("\(#file) isLidarDebugEnabled = \(isEnabled)")
        self.arView.updateDebugOptions(.showSceneUnderstanding, isEnabled)
    }
    
    private func updateAnchorOrigins(isEnabled: Bool) {
        print("\(#file) isAnchorOriginsEnabled = \(isEnabled)")
        self.arView.updateDebugOptions(.showAnchorOrigins, isEnabled)
    }
    
    private func updateWorldOrigin(isEnabled: Bool) {
        print("\(#file) isWorldOriginEnabled = \(isEnabled)")
        self.arView.updateDebugOptions(.showWorldOrigin, isEnabled)
    }
    
    private func updateFeaturePoints(isEnabled: Bool) {
        print("\(#file) areFeaturePointsEnabled = \(isEnabled)")
        self.arView.updateDebugOptions(.showFeaturePoints, isEnabled)
    }
    
    private func updateCollision(isEnabled: Bool) {
        print("\(#file) isCollisionEnabled = \(isEnabled)")
        self.arView.updateSceneUnderstandingOptions(.collision, isEnabled)
    }
}
