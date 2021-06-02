//
//  PlacementSettings.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 06.05.2021.
//

import SwiftUI
import RealityKit
import Combine


class PlacementSettings: ObservableObject {
    
    @Published var selectedModel: Model? {
        willSet(newValue) {
            print("Setting selectedModel to \(String(describing: newValue?.description))")
        }
    }
    
    @Published var confirmedModel: Model? {
        willSet(newValue) {
            guard let model = newValue else {
                print("Clearing confirmedModel")
                return
            }
            print("Setting confirmed to \(model.description)")
            self.recentlyPlaced.append(model)
        }
    }
    
    @Published var recentlyPlaced: [Model] = []
    
    var sceneObserver: Cancellable?
}
