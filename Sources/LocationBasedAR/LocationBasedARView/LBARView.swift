//
//  LBARView.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 17.05.2021.
//

import Foundation
import ARKit
import RealityKit
import CoreLocation


open class LBARView: ARView {
    
    public internal(set) var trackingStatus: TrackingStatus = .initializing() {
        didSet(newValue) {
            self.sessionDelegate?.view(self, didChange: newValue)
        }
    }
    
    public var scalingScheme: ScalingScheme = .none {
        didSet {
            self.updateAnchors()
        }
    }
    
    internal var anchors: [LocationAnchorData] = []
    public var anchorDistances: [String: Double] = [:]
    internal var pendingLocations: [Placemark] = []
    
    // View Delegates
    public var delegate: LBARViewDelegate?
    public var sessionDelegate: LBARViewObserver?
    public var locationProvider: LocationDataProvider?
    
    /// Maximum range of visible locations
    ///
    /// Too high values `(> 1000)` may result in too many anchors to be tracked
    /// which may significantly decrease performance
    public var displayRangeFilter = 1000.0 {
        didSet {
            self.updateAnchors()
        }
    }
    
    /// Maximum distance of anchors' tracking
    ///
    /// Values from `[30; 100]` are recommended
    public var maximumVisibleAnchorDistance = 50.0 {
        didSet {
            self.updateAnchors()
        }
    }
    
    /// Filter to control the frequency of location updates
    ///
    /// Implies that location won't be updated within given range
    public var locationUpdateFilter = 5.0
    
    
    /// Current location of AR Scene
    internal var currentSceneLocation = SceneLocaiton() {
        didSet {
            self.updateAnchors()
        }
    }
    
    internal var locationUpdatesTimer = Timer()
    
    // convenience properties to access scene location data
    public var lastSceneLocation: CLLocation? { currentSceneLocation.lastSceneLocation }
    public var lastSceneLocationAccuracy: CLLocationAccuracy? { currentSceneLocation.lastSceneLocationAccuracy }
    public var lastCameraPosition: SIMD3<Float>? { currentSceneLocation.lastCameraPosition }
    
    // MARK: - Initializers
    
    public convenience init(
        frame: CGRect = .zero,
        displayRangeFilter: Double = 1000.0,
        maximumVisibleAnchorDistance: Double = 50.0,
        locationUpdateFilter: Double = 10.0,
        scalingScheme: ScalingScheme = .none
    ) {
        self.init(frame: frame)
        self.displayRangeFilter = displayRangeFilter
        self.maximumVisibleAnchorDistance = maximumVisibleAnchorDistance
        self.locationUpdateFilter = locationUpdateFilter
        self.scalingScheme = scalingScheme
        self.currentSceneLocation = SceneLocaiton()
        self.trackingStatus = .initializing()
    }
    
    public required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.automaticallyConfigureSession = false
    }
    
    @objc required dynamic public init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        self.automaticallyConfigureSession = false
    }
    
    // MARK: - Methods for adding anchors
    
    /// Adds array of `Placemark` to `LBARView`
    ///
    /// All added locations are stored in buffer array, which is processed once `SceneLocation` is provided
    public func add(placemarks: [Placemark]) {
        let newLocations = placemarks.filter({ !self.pendingLocations.contains($0) })
        self.pendingLocations.append(contentsOf: newLocations)
        self.processPendingLocations()
    }
    
    /// Adds single `Placemark` to `LBARView`
    public func add(placemark: Placemark) {
        self.add(placemarks: [placemark])
    }
    
    /// Adds array of `CLLocation` objects to `LBARView`
    ///
    /// Converts `CoreLocation` objects to  array `Placemark` and adds them
    public func add(locations: [CLLocation]) {
        self.add(placemarks: locations.compactMap({ Placemark(location: $0) }))
    }
    
    /// Adds single `CLLocation` to `LBARView`
    public func add(location: CLLocation, with name: String? = nil) {
        self.add(placemark: Placemark(location: location, placeName: name))
    }
    
    /// Adds an instance of `LBAnchor` to `LBARView`
    ///
    /// Checks anchor's location and  assignes`status` property
    public func add(anchor: LBAnchor) {
        
        guard !self.anchors.contains(where: { $0.anchor == anchor }) else { return }
        
        guard let location = lastSceneLocation else { return }
        
        let locationAnchor = LocationAnchorData(
            coordinate: anchor.coordinate, accuracy: anchor.accuracy, altitude: anchor.altitude
        )
        locationAnchor.name = anchor.name
        
        // check distance to location and assign apropriate status
        let distance = location.haversineDistance(from: anchor.location)
        locationAnchor.status =  distance > displayRangeFilter ? .hidden : .waitingForDisplay
        locationAnchor.anchor = anchor

        self.anchors.append(locationAnchor)
        self.anchorDistances[locationAnchor.id] = location.haversineDistance(from: locationAnchor.location)
        self.processWaitingAnchors()
    }
    
    /// Adds `AnchorEntity` object to `LBARView` with optionally provided location data
    ///
    /// If anchor is already added to `Scene`, checks if location data is provided and estimates approximate locaiton in real-world space if not.
    /// Otherwise uses provided location data to estimate the target position in AR world space
    /// - Note: Silently fails if `AnchorEntity` is not added to a `Scene`and is not provided with `Placemark`
    public func add(entity: AnchorEntity, with placemark: Placemark?) {
        
        if self.scene.anchors.contains(anchor: entity) {
            
            if let placemark = placemark {
                let anchor = LBAnchor(
                    transform: entity.transformMatrix(relativeTo: nil),
                    coordinate: placemark.coordinate,
                    accuracy: placemark.accuracy
                )
                let anchorData = LocationAnchorData(anchor)
                anchorData.anchorEntity = entity
                anchorData.status = .waitingForDisplay
                self.anchors.append(anchorData)
                if let location = lastSceneLocation {
                    self.anchorDistances[anchorData.id] = location.haversineDistance(from: anchorData.location)
                }
            } else {
                // find location based on transform
                guard let location = lastSceneLocation,
                      let accuracy = lastSceneLocationAccuracy else { return }
                
                let transform = entity.transformMatrix(relativeTo: nil)
                let anchorLocation = self.worldTransformToLocation(
                    transform, from: location, with: accuracy
                )
                let anchor = LBAnchor(
                    transform: transform,
                    coordinate: anchorLocation.coordinate,
                    accuracy: anchorLocation.horizontalAccuracy
                )
                let anchorData = LocationAnchorData(anchor)
                anchorData.anchorEntity = entity
                anchorData.status = .waitingForDisplay
                self.anchors.append(anchorData)
                self.anchorDistances[anchorData.id] = location.haversineDistance(from: anchorData.location)
            }
        } else {
            if let placemark = placemark {
                
                self.locationToWorldTransform(placemark.location) { result in
                    switch result {
                    case .failure(let err): return
                    case .success(let transform):
                        
                        let anchor = LBAnchor(
                            transform: transform,
                            coordinate: placemark.coordinate,
                            accuracy: placemark.accuracy
                        )
                        let anchorData = LocationAnchorData(anchor)
                        
                        entity.reanchor(.world(transform: transform))
                        
                        anchorData.anchorEntity = entity
                        anchorData.status = .waitingForDisplay
                        self.anchors.append(anchorData)
                        if let location = self.lastSceneLocation {
                            self.anchorDistances[anchorData.id] = location.haversineDistance(from: anchorData.location)
                        }
                        self.scene.addAnchor(entity)
                    }
                }
            }
        }
        
        self.processWaitingAnchors()
    }
    
    /// Adds `AnchorEntity` object to `LBARView` with provided location data
    ///
    /// Behaves as `add(AnchorEntity, Placemark?)` method with provided `Placemark`
    public func add(entity: AnchorEntity, with location: CLLocation) {
        self.add(entity: entity, with: Placemark(location: location))
    }
    
    /// Adds `AnchorEntity` object to `LBARView`
    ///
    /// Behaves as `add(AnchorEntity, Placemark?)` method with `Placemark` set to `nil`
    public func add(entity: AnchorEntity) {
        self.add(entity: entity, with: nil)
    }
    
    
    // MARK: - Methods for handling anchor removal
    
    /// Removes single `LBAnchor` from the scene if present
    public func remove(anchor: LBAnchor) {
        if let index = self.anchors.firstIndex(where: { $0.anchor == anchor }) {
            if let entity = self.anchors[index].anchorEntity {
                self.scene.removeAnchor(entity)
            }
            if let anchor = self.anchors[index].anchor {
                self.session.remove(anchor: anchor)
            }
            self.anchorDistances.removeValue(forKey: self.anchors[index].id)
            self.anchors.remove(at: index)
        }
    }
    
    /// Removes single `LocationEntity` from the scene if present
    public func remove(entity: AnchorEntity) {
        if let index = self.anchors.firstIndex(where: { $0.anchorEntity == entity }) {
            if let entity = self.anchors[index].anchorEntity {
                self.scene.removeAnchor(entity)
            }
            if let anchor = self.anchors[index].anchor {
                self.session.remove(anchor: anchor)
            }
            self.anchorDistances.removeValue(forKey: self.anchors[index].id)
            self.anchors.remove(at: index)
        }
    }
    
    /// Remove single `LBAnchor` with provided id if present
    public func remove(by id: String) {
        if let index = self.anchors.firstIndex(where: { $0.id == id }) {
            if let entity = self.anchors[index].anchorEntity {
                self.scene.removeAnchor(entity)
            }
            if let anchor = self.anchors[index].anchor {
                self.session.remove(anchor: anchor)
            }
            self.anchorDistances.removeValue(forKey: self.anchors[index].id)
            self.anchors.remove(at: index)
        }
    }
    
    /// Removes all location-based anchors fromt the scene
    public func removeAll() {
        self.anchors.forEach({
            if let anchor = $0.anchor {
                self.session.remove(anchor: anchor)
            }
            if let entity = $0.anchorEntity {
                self.scene.removeAnchor(entity)
            }
        })
        self.anchorDistances.removeAll()
        self.anchors.removeAll()
    }
    
    // MARK: - Methods for getting anchors
    
    /// Returns anchors collection
    public func getAnchors() -> [LocationAnchorData] {
        return self.anchors
    }
    
    /// Returns only currently visible anchors
    public func getVisibleAnchors() -> [LocationAnchorData] {
        return self.anchors.filter({ $0.status == .displayed })
    }
    
    /// Returns only currently hidden anchors
    public func getHiddenAnchors() -> [LocationAnchorData] {
        return self.anchors.filter({ $0.status == .hidden })
    }
    
    /// Returns anchors that are location within `sceneLocationAccuracy` range
    public func getAnchorsInAccuracyRange() -> [LocationAnchorData] {
        
        guard let sceneLocation = self.lastSceneLocation,
              let sceneLocationAccuracy = self.lastSceneLocationAccuracy else { return [] }
        
        return self.anchors.compactMap({ anchor in
            let distance = sceneLocation.distance(from: anchor.location)
            if distance <= sceneLocationAccuracy {
                return anchor
            } else {
                return nil
            }
        })
    }
    
    /// Returns anchors in given range from device's position
    public func getAnchors(in range: CLLocationDistance) -> [LocationAnchorData] {
        guard let sceneLocation = self.lastSceneLocation else { return [] }
        
        return self.anchors.compactMap({ anchor in
            let distance = sceneLocation.distance(from: anchor.location)
            if distance <= range {
                return anchor
            } else {
                return nil
            }
        })
    }
    
    /// Returns anchor with provided id if present
    public func getAnchor(by id: String) -> LocationAnchorData? {
        return self.anchors.first(where: { $0.id == id })
    }
    
    /// Returns anchor with provided anchor id if present
    public func getAnchor(by anchorId: UUID, lookupEntities: Bool = false) -> LocationAnchorData? {
        return self.anchors.first(where: { anchorData in
            
            if lookupEntities {
                if let id = anchorData.anchorEntity?.anchorIdentifier { return anchorId == id }
                else { return false }
            } else {
                if let id = anchorData.anchorId { return anchorId == id }
                else { return false }
            }
        })
    }
    
    /// Returns anchor that is located at provided coordinates within specified range
    ///
    /// It number of found anchors is more than one, returns the first one found
    public func getAnchor(by location: CLLocation, with accuracy: CLLocationAccuracy) -> LocationAnchorData? {
        return self.getAnchors(by: location, with: accuracy).first
    }
    
    /// Returns all anchors that are location at provided coordinates within specified range
    public func getAnchors(by location: CLLocation, with accuracy: CLLocationAccuracy) -> [LocationAnchorData] {
        return self.anchors.filter({
            $0.location.distance(from: location) <= accuracy
        })
    }
    
    // MARK: - Private methods for location anchors management
    
    // Helper method to process pending locations once scene location is estimated
    private func processPendingLocations() {
        guard let sceneLocation = self.lastSceneLocation,
              let sceneLocationAccuracy = self.lastSceneLocationAccuracy else { return }
        
        self.pendingLocations.forEach({ placemark in
            
            // create anchor for location with given scene location
            self.locationToWorldTransform(
                placemark.location, from: sceneLocation, with: sceneLocationAccuracy
            ) { result in
                
                switch result {
                case .failure(let err):
                    switch err {
                    case .outOfRange:
                        let anchorData = LocationAnchorData(coordinate: placemark.coordinate, accuracy: placemark.accuracy)
                        anchorData.status = .hidden
                        self.anchors.append(anchorData)
                        self.anchorDistances[anchorData.id] = sceneLocation.haversineDistance(from: anchorData.location)
                    default: return
                    }
                case .success(let transform):
                    let anchorData = LocationAnchorData(coordinate: placemark.coordinate, accuracy: placemark.accuracy)
                    let anchor = LBAnchor(
                        name: placemark.placeName ?? "LBAnchor",
                        transform: transform,
                        coordinate: placemark.coordinate,
                        accuracy: placemark.accuracy
                    )
                    anchorData.anchor = anchor
                    anchorData.status = .waitingForDisplay
                    self.anchors.append(anchorData)
                    self.anchorDistances[anchorData.id] = sceneLocation.haversineDistance(from: anchorData.location)
                }
            }
        })
        self.pendingLocations.removeAll()
        self.processWaitingAnchors()
    }
    
    // Helper method to process anchors that are in transition state (hidden -> displayed and vice versa)
    internal func processWaitingAnchors() {

        let willBecomeVisible = self.anchors.filter({ $0.status == .waitingForDisplay && $0.anchor != nil })
        willBecomeVisible.forEach({
            guard let anchor = $0.anchor else { return }
            $0.status = .displayed
            self.session.add(anchor: anchor)
            $0.anchorEntity?.isEnabled = true
        })
        let addedAnchors = willBecomeVisible.compactMap({ $0.anchor })
        if !addedAnchors.isEmpty {
            self.delegate?.view(self, didAdd: addedAnchors)
        }
        
        let willBecomeHidden = self.anchors.filter({ $0.status == .waitingForHide })
        willBecomeHidden.forEach({
            guard let anchor = $0.anchor else { return }
            $0.status = .hidden
            self.session.remove(anchor: anchor)
            $0.anchorEntity?.isEnabled = false
        })
        let removedAnchors = willBecomeHidden.compactMap({ $0.anchor })
        if !removedAnchors.isEmpty {
            self.delegate?.view(self, didRemove: removedAnchors)
        }
    }
    
    // Helper method to update anchors positions in virtual (AR) coordinates based on current location
    private func updateAnchors(at currentLocation: CLLocation, with accuracy: CLLocationAccuracy) {
        
        var updatedAnchors = [LocationAnchorData]()
        
        self.anchors.filter({ $0.status == .displayed && $0.anchor != nil }).forEach({ anchor in
            if processAndUpdate(anchor, at: currentLocation, with: accuracy) {
                updatedAnchors.append(anchor)
            }
        })
        
        self.anchors.filter({ $0.status == .hidden }).forEach({ anchor in
            if processAndUpdate(anchor, at: currentLocation, with: accuracy) {
                updatedAnchors.append(anchor)
            }
        })
        
        let anchors = updatedAnchors.compactMap({ $0.anchor })
        if !anchors.isEmpty {
            self.delegate?.view(self, didUpdate: anchors)
        }
        
        self.processWaitingAnchors()
    }
    
    // use with animation??
    private func processAndUpdate(
        _ anchorData: LocationAnchorData,
        at currentLocation: CLLocation,
        with accuracy: CLLocationAccuracy
    ) -> Bool {
        guard anchorData.status == .displayed || anchorData.status == .hidden else { return false }
        
        let distance = currentLocation.haversineDistance(from: anchorData.location)
        let bearing = currentLocation.bearingBetween(anchorData.location)
        
        if anchorData.status == .hidden, distance <= displayRangeFilter {
            
            let distanceToAnchor = min(distance, maximumVisibleAnchorDistance)
            let transform = MatrixHelper.transform(from: distanceToAnchor, with: Float(bearing))
            
            let anchor = LBAnchor(
                name: anchorData.name ?? "LBAnchor",
                transform: transform,
                coordinate: anchorData.coordinate,
                accuracy: anchorData.accuracy
            )
            anchorData.anchor = anchor
            anchorData.status = .waitingForDisplay
            return true
        }
        
        if anchorData.status == .displayed, let oldAnchor = anchorData.anchor {
            if distance > displayRangeFilter {
                anchorData.status = .waitingForHide
                return true
            }
            let distanceToAnchor = min(distance, maximumVisibleAnchorDistance)
            let transform = MatrixHelper.transform(from: distanceToAnchor, with: Float(bearing))
            
            let oldDistance = oldAnchor.transform.translation.distanceFrom(lastCameraPosition ?? [0, 0, 0])
            let newDistance = transform.translation.distanceFrom(lastCameraPosition ?? [0, 0, 0])
            
            if abs(Double(newDistance - oldDistance)) >= min(accuracy, distanceToAnchor / 100.0) {
                print("\(#file) -- updating anchor=\(anchorData.id): old distance=\(oldDistance), new=\(newDistance)")
                
                if let oldAnchor = anchorData.anchor {
                    
                    let newAnchor = LBAnchor(from: oldAnchor, with: transform)
                    self.session.add(anchor: newAnchor)
                    anchorData.anchor = newAnchor
                    
                    if let anchorEntity = anchorData.anchorEntity {
                        anchorEntity.reanchor(.anchor(identifier: newAnchor.identifier))
                        anchorData.anchorEntity = anchorEntity
                    }
                    self.session.remove(anchor: oldAnchor)
                    return true
                } else {
                    
                    let newAnchor = LBAnchor(
                        transform: transform, coordinate: anchorData.coordinate, accuracy: anchorData.accuracy
                    )
                    self.session.add(anchor: newAnchor)
                    anchorData.anchor = newAnchor
                    
                    if let anchorEntity = anchorData.anchorEntity {
                        anchorEntity.reanchor(.anchor(identifier: newAnchor.identifier))
                        anchorData.anchorEntity = anchorEntity
                    }
                    return true
                }
            }
            
        }
        
        return false
    }
}
