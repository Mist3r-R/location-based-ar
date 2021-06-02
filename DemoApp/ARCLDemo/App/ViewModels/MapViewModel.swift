//
//  MapViewModel.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 04.05.2021.
//

import SwiftUI
import MapKit
import CoreLocation
import LocationBasedAR


class MapViewModel: NSObject, ObservableObject {
    
    @Published var mapView = MKMapView()
    @Published var userTrackingMode: MKUserTrackingMode = .none
    
    // selected location
    @Published var selectedLocation: MapLocation? = nil
    
    @Published var allowTap: Bool = UserDefaultsConfig.isMapTapEnabled {
        willSet(newValue) { UserDefaultsConfig.isMapTapEnabled = newValue }
    }
    
    // Chosen anchor
    // Added anchors
    @Published var anchors: [LBAnchor] = []
    // Overlays
    
    override init() {
        super.init()
        setupGestures()
    }
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        mapView.addGestureRecognizer(tap)
    }
    
    var locationButtonIcon: String {
        switch userTrackingMode {
        case .none: return "location"
        case .follow: return "location.fill"
        case .followWithHeading: return "location.north.line.fill"
        default: return "location"
        }
    }
    
    func focusOnUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            DispatchQueue.main.async {
                self.userTrackingMode = .follow
            }
        }
    }
    
    func changeTrackingMode() {
        switch userTrackingMode {
        case .none: userTrackingMode = .follow
        case .follow: userTrackingMode = .followWithHeading
        case .followWithHeading: userTrackingMode = .none
        default: userTrackingMode = .none
        }
        
        mapView.userTrackingMode = userTrackingMode
    }
    
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        
        guard allowTap else { return }
        
        // get the tap location
        let tapLocation = recognizer.location(in: mapView)
        
        // convert tap location to real world location
        let coordinate = mapView.convert(tapLocation, toCoordinateFrom: mapView)
        
        // handle addition at specified coordinates
        self.selectedLocation = MapLocation(coordinate: coordinate)
    }
    
    // show anchors on map
    func addAnchors(_ anchors: [LBAnchor]) {
        let incoming = anchors.filter({ !self.anchors.contains($0) })
        self.anchors.append(contentsOf: incoming)
        
        let indicators = self.mapView.overlays.compactMap({ $0 as? AnchorIndicator })
        self.mapView.addOverlays(
            incoming
                .compactMap({ AnchorIndicator(center: $0.coordinate, color: $0.locationEstimation.color)})
                .filter({ !indicators.contains($0) })
        )
    }
    // remove anchors from map
    func removeAnchors(_ anchors: [LBAnchor]) {
        let indicators = self.mapView.overlays.compactMap({ $0 as? AnchorIndicator })
        anchors.forEach { anchor in
            if let index = self.anchors.firstIndex(of: anchor) {
                self.anchors.remove(at: index)
            }
            if let overlay = indicators.first(where: {
                $0.coordinate.latitude == anchor.coordinate.latitude
                    && $0.coordinate.longitude == anchor.coordinate.longitude
                    && $0.color == anchor.locationEstimation.color
            }) {
                DispatchQueue.main.async {
                    self.mapView.removeOverlay(overlay)
                }
            }
        }
    }
}
