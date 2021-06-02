//
//  SettingsToggleButton.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 17.05.2021.
//

import SwiftUI

struct SettingsToggleButton: View {
    
    let setting: Setting
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            self.isOn.toggle()
            print("\(#file) -- \(setting): \(self.isOn)")
        }) {
            VStack {
                Image(systemName: setting.systemIconName)
                    .font(.title)
                    .foregroundColor(self.isOn ? .systemGreen : .secondaryLabel)
                    .buttonStyle(PlainButtonStyle())
                
                Text(setting.label)
                    .font(.system(size: 17, weight: .medium, design: .default))
                    .foregroundColor(self.isOn ? .label : .secondaryLabel)
                    .padding(.top, 5)
            }
        }
        .frame(width: 100, height: 100)
        .background(Color.secondarySystemFill)
        .cornerRadius(20.0)
    }
}
