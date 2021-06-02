//
//  WorldMapData.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 21.05.2021.
//

import Foundation
import ARKit
import CoreLocation


public struct WorldMap: Codable {
    
    var id: String
    var timestamp: Date
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var accuracy: CLLocationAccuracy
    var arWorldMap: ARWorldMap?
    
    enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case latitude
        case longitude
        case accuracy
        case arWorldMap
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude, horizontalAccuracy: accuracy)
    }
    
    public init(
        coordinate: CLLocationCoordinate2D,
        accuracy: CLLocationAccuracy,
        timestamp: Date = Date(),
        arWorldMap: ARWorldMap? = nil
    ) {
        self.id = UUID().uuidString
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.accuracy = accuracy
        self.arWorldMap = arWorldMap
        self.timestamp = timestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let worldMapData = try container.decode(Data.self, forKey: .arWorldMap)
        self.arWorldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: worldMapData)
        self.id = try container.decode(String.self, forKey: .id)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.accuracy = try container.decode(Double.self, forKey: .accuracy)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(accuracy, forKey: .accuracy)
        if let worldMapData = arWorldMap {
            let data = try NSKeyedArchiver.archivedData(withRootObject: worldMapData, requiringSecureCoding: true)
            try container.encode(data, forKey: .arWorldMap)
        }
    }
}
