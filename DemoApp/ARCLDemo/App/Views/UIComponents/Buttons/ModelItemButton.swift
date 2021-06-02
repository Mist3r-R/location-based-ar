//
//  ModelItemButton.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 14.05.2021.
//

import SwiftUI


struct ModelItemButton: View {
    
    let model: Model
    let action: () -> Void
    
    var body: some View {
        Button(action: { self.action() }) {
            Image(uiImage: self.model.thumbnail)
                .resizable()
                .frame(height: 150)
                .aspectRatio(1/1, contentMode: .fit)
                .background(Color.secondarySystemFill)
                .cornerRadius(8.0)
        }
    }
}
