//
//  LocalData.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 01.06.2021.
//

import Foundation
import CoreLocation
import LocationBasedAR


class LocalDataManager {
    
    // default locations
    let defaultLocations = [
        LocationData(id: nil, name: "Luzhniki Stadium", latitude: 55.716181, longitude: 36.556228, accuracy: 0),
        LocationData(id: nil, name: "Gorky Park", latitude: 55.728211, longitude: 37.600030, accuracy: 0),
        LocationData(id: nil, name: "Moscow City", latitude: 55.748413, longitude: 37.539465, accuracy: 0),
        LocationData(id: nil, name: "Cathedral of Christ the Saviour", latitude: 55.744037, longitude: 37.605614, accuracy: 0),
        LocationData(id: nil, name: "HSE Pokrovka", latitude: 55.753898, longitude: 37.648929, accuracy: 0),
    ]
    
    static var shared = LocalDataManager()
    
    private init() { }
    
    func storeDefault() {
        if loadSavedLocations().isEmpty {
            save(defaultLocations)
        }
    }
    
    func clearCache() {
        UserDefaultsConfig.savedLocations = nil
    }
    
    func loadSavedLocations() -> [LocationData] {
        return UserDefaultsConfig.savedLocations ?? []
    }
    
    func save(_ locations: [LocationData]) {
        var cached = loadSavedLocations()
        cached.append(contentsOf: locations)
        UserDefaultsConfig.savedLocations = cached
    }
    
    func save(_ location: LocationData) {
        var cached = loadSavedLocations()
        if !cached.contains(location) {
            cached.append(location)
            UserDefaultsConfig.savedLocations = cached
        }
    }
    
    func delete(by id: String) {
        var cached = loadSavedLocations()
        if let index = cached.firstIndex(where: { $0.id != nil && $0.id == id }) {
            cached.remove(at: index)
            UserDefaultsConfig.savedLocations = cached
        }
    }
    
    func delete(_ location: LocationData) {
        var cached = loadSavedLocations()
        if let index = cached.firstIndex(of: location) {
            cached.remove(at: index)
            UserDefaultsConfig.savedLocations = cached
        }
    }
}


public struct LocationData: Codable, Equatable {
    let id: String?
    let name: String?
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let accuracy: CLLocationAccuracy
    
}
