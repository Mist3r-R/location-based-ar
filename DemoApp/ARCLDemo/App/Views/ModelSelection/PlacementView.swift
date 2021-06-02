//
//  PlacementView.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 06.05.2021.
//

import SwiftUI

struct PlacementView: View {
    
    @EnvironmentObject var placementSettings: PlacementSettings
    
    var body: some View {
        HStack {
            
            Spacer()
            
            SystemIconButton(systemIconName: "xmark", action: {
                self.placementSettings.selectedModel = nil
            })
            .frame(width: 75, height: 75)
            .buttonStyle(MapButtonStyle())
            
            Spacer()
            
            SystemIconButton(systemIconName: "checkmark", action: {
                self.placementSettings.confirmedModel = self.placementSettings.selectedModel
                self.placementSettings.selectedModel = nil
            })
            .frame(width: 75, height: 75)
            .buttonStyle(MapButtonStyle())
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}

struct PlacementView_Previews: PreviewProvider {
    static var previews: some View {
        PlacementView()
            .background(Color.red)
    }
}
