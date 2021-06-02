//
//  UserDefaultsConfig.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 01.06.2021.
//

import Foundation

public struct UserDefaultsConfig {
    public static let defaults = UserDefaults.standard
    
    @OptionalUserDefault("last-worldmap-path", defaultValue: nil)
    public static var lastWorldMapPath: URL?
    
    @UserDefault("people-occlusion-setting", defaultValue: false)
    public static var isPeopleOcclusionEnabled: Bool
    
    @UserDefault("object-occlusion-setting", defaultValue: false)
    public static var isObjectOcclusionEnabled: Bool
    
    @UserDefault("world-origin-setting", defaultValue: false)
    public static var isWorldOriginEnabled: Bool
    
    @UserDefault("collision-setting", defaultValue: false)
    public static var isCollisionEnabled: Bool
    
    @UserDefault("annotations-preferred-setting", defaultValue: false)
    public static var isAnnotationsPreferred: Bool
    
    @UserDefault("ar-tap-setting", defaultValue: false)
    public static var isARTapEnabled: Bool
    
    @UserDefault("map-tap-setting", defaultValue: false)
    public static var isMapTapEnabled: Bool
    
    @UserDefault("distance-filter-setting", defaultValue: 1000.0)
    public static var distanceFilterValue: Double
    
    @OptionalCodableUserDefault("saved-locations", defaultValue: [])
    public static var savedLocations: [LocationData]?
    
    public static var description: String {
        var str = "UserDefaultsConfig:\n"
        str += "isPeopleOcclusionEnabled = \(isPeopleOcclusionEnabled)\n"
        str += "isObjectOcclusionEnabled = \(isObjectOcclusionEnabled)\n"
        str += "isWorldOriginEnabled = \(isWorldOriginEnabled)\n"
        str += "isCollisionEnabled = \(isCollisionEnabled)\n"
        str += "isAnnotationsPreferred = \(isAnnotationsPreferred)\n"
        str += "isARTapEnabled = \(isARTapEnabled)\n"
        str += "isMapTapEnabled = \(isMapTapEnabled)\n"
        str += "distanceFilterValue = \(distanceFilterValue)\n"
        return str
    }
}
