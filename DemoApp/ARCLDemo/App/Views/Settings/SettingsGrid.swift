//
//  SettingsGrid.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 17.05.2021.
//

import SwiftUI


struct SettingsView: View {
    
    @Binding var showSettings: Bool
    
    var body: some View {
        NavigationView {
            SettingsGrid()
                .navigationBarTitle(Text("Settings"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    self.showSettings.toggle()
                }) {
                    Text("Done").bold()
                })
        }
    }
}


struct SettingsGrid: View {
    
    @EnvironmentObject var arSessionManager: ARSessionManager
    @EnvironmentObject var mapViewModel: MapViewModel
    
    private var gridItemLayout = [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 25)]
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 25) {
                
                Text("App Settings")
                    .font(.title2).bold()
                    .padding(.top, 10)
                
                LazyVGrid(columns: gridItemLayout, spacing: 25) {
                    SettingsToggleButton(setting: .annotations, isOn: $arSessionManager.showAnnotations)
                    SettingsToggleButton(setting: .mapInput, isOn: $mapViewModel.allowTap)
                    SettingsToggleButton(setting: .arInput, isOn: $arSessionManager.allowTap)
                }
                
                SliderControl(label: "Distance Filter", value: $arSessionManager.distanceFilterValue)
                    .frame(maxWidth: 350)
                    
                
                Separator()
                
                Text("AR Configuration")
                    .font(.title2).bold()
                    .padding(.top, 10)
                
                
                LazyVGrid(columns: gridItemLayout, spacing: 25) {
                    SettingsToggleButton(setting: .peopleOcclusion, isOn: $arSessionManager.isPeopleOcclusionEnabled)
                    SettingsToggleButton(setting: .objectOcclusion, isOn: $arSessionManager.isObjectOcclusionEnabled)
                    SettingsToggleButton(setting: .lidarDebug, isOn: $arSessionManager.isLidarDebugEnabled)
                    SettingsToggleButton(setting: .anchorOrigins, isOn: $arSessionManager.isAnchorOriginsEnabled)
                    SettingsToggleButton(setting: .worldOrigin, isOn: $arSessionManager.isWorldOriginEnabled)
                    SettingsToggleButton(setting: .featurePoints, isOn: $arSessionManager.areFeaturePointsEnabled)
                    SettingsToggleButton(setting: .collision, isOn: $arSessionManager.isCollisionEnabled)
                }
            }
        }
        .padding(.top, 35)
    }
}
