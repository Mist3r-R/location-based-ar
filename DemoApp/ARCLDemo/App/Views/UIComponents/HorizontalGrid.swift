//
//  HorizontalGrid.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 04.05.2021.
//

import SwiftUI


struct HorizontalGrid: View {
    
    @EnvironmentObject var placementSettings: PlacementSettings
    
    var title: String
    var items: [Model]
    @Binding var isShown: Bool
    
    private let gridItemLayout = [GridItem(.fixed(150))]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Separator()
            
            Text(title)
                .font(.title2).bold()
                .padding(.leading, 22)
                .padding(.top, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: gridItemLayout, spacing: 30) {
                    ForEach(0..<items.count) { index in
                        
                        let model = items[index]
                        
                        ModelItemButton(model: model) {
                            model.loadModelEntityAsync()
                            self.placementSettings.selectedModel = model
                            print("\(#file) -- selected model \(model.description)")
                            self.isShown = false
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
            }
        }
    }
}
