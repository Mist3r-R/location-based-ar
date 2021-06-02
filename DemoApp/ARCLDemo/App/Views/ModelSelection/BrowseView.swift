//
//  BrowseView.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 06.05.2021.
//

import SwiftUI


struct BrowseView: View {
    
    @Binding var isShown: Bool
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                // Gridviews for thumbnails
                ModelByCategoryGrid(isShown: $isShown)
            }
            .navigationBarTitle(Text("Browse"), displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                self.isShown.toggle()
            }, label: {
                Text("Done").bold()
            }))
        }
    }
}


struct ModelByCategoryGrid: View {
    
    @Binding var isShown: Bool
    let models = Models()
    
    var body: some View {
        VStack {
            ForEach(ModelCategory.allCases, id: \.self) { category in
                
                if let modelsByCategory = models.get(category: category) {
                    HorizontalGrid(title: category.label, items: modelsByCategory, isShown: $isShown)
                }
            }
        }
    }
}
