//
//  UserDefaultsConfig.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 01.06.2021.
//

import Foundation

public struct UserDefaultsConfig {
    public static let defaults = UserDefaults.standard
    
    @OptionalUserDefault("last-worldmap", defaultValue: nil)
    public static var lastWorldMapPath: String?
    
    // default range
    
    // default scaling
    
    // default locations
    
    @OptionalCodableUserDefault("saved-locations", defaultValue: [])
    public static var savedLocations: [LocationData]?
}
