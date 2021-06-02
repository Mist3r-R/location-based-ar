//
//  ARCLDemoApp.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 04.05.2021.
//

import SwiftUI

@main
struct ARCLDemoApp: App {
    
    @StateObject var locationManager = LBSManager()
    @StateObject var mapViewModel = MapViewModel()
    @StateObject var placementSettings = PlacementSettings()
    @StateObject var arSessionManager = ARSessionManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(locationManager)
                .environmentObject(mapViewModel)
                .environmentObject(placementSettings)
                .environmentObject(arSessionManager)
        }
    }
}
