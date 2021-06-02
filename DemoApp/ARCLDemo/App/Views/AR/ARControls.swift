//
//  ARControls.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 06.05.2021.
//

import SwiftUI

struct ARControls: View {
    
    @State var isControlsVisible: Bool = true
    @State var isBrowseVisible: Bool = false
    @State var isSettingVisible: Bool = false
    
    var body: some View {
        VStack {
            TopControlItems(isControlsVisible: $isControlsVisible)
                
            Spacer()
            
            if isControlsVisible {
                BottomControlBar(showBrowse: $isBrowseVisible, showSettings: $isSettingVisible)
            }
        }
    }
}


struct TopControlItems: View {
    
    @Binding var isControlsVisible: Bool
    @EnvironmentObject var arSessionManager: ARSessionManager
    
    var body: some View {
        HStack {
            ZStack {
                Color.black.opacity(0.25)
                SystemIconButton(systemIconName: "arrow.triangle.2.circlepath", action: {
                    self.arSessionManager.resetSession()
                })
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 50, height: 50, alignment: .center)
            .cornerRadius(8.0)
            Spacer()
            ZStack {
                Color.black.opacity(0.25)
                SystemIconButton(
                    systemIconName: isControlsVisible ?
                        "rectangle" : "slider.horizontal.below.rectangle",
                    action: {
                    self.isControlsVisible.toggle()
                })
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 50, height: 50, alignment: .center)
            .cornerRadius(8.0)
        }
        .padding(25)
    }
}


struct BottomControlBar: View {
    
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var arSessionManager: ARSessionManager

    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
            
            MostRecentlyPlacedButton().hidden(self.placementSettings.recentlyPlaced.isEmpty)
            
            Spacer()
            
            SystemIconButton(systemIconName: "square.grid.2x2", action: {
                self.showBrowse.toggle()
            })
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showBrowse, content: {
                BrowseView(isShown: $showBrowse)
            })
            
            Spacer()
            
            
            SystemIconButton(systemIconName: "slider.horizontal.3", action: {
                self.showSettings.toggle()
            })
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showSettings, content: {
                SettingsView(showSettings: $showSettings)
                    .environmentObject(arSessionManager)
            })
        }
        .padding(30)
        .background(Color.black.opacity(0.25))
    }
}


struct MostRecentlyPlacedButton: View {
    
    @EnvironmentObject var placementSettings: PlacementSettings
    
    var body: some View {
        
        if let mostRecent = self.placementSettings.recentlyPlaced.last {
            Button(action: self.handlePress) {
                Image(uiImage: mostRecent.thumbnail)
                    .resizable()
                    .frame(width: 46)
                    .aspectRatio(1/1, contentMode: .fit)
            }
            .frame(width: 50, height: 50)
            .background(Color.white)
            .cornerRadius(8.0)
        } else {
            SystemIconButton(systemIconName: "clock", action: self.handlePress)
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func handlePress() {
        print("Recent button tapped")
        self.placementSettings.selectedModel = self.placementSettings.recentlyPlaced.last
    }
}

struct ARControls_Previews: PreviewProvider {
    static var previews: some View {
        ARControls()
    }
}
