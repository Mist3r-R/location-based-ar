//
//  ARView+updateOptions.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 20.05.2021.
//

import Foundation
import RealityKit


extension ARView {
    
    func updateDebugOptions(_ options: ARView.DebugOptions, _ enable: Bool) {
        guard enable != debugOptions.contains(options) else { return }
        if enable {
            debugOptions.insert(options)
        } else {
            debugOptions.remove(options)
        }
    }
    
    func updateSceneUnderstandingOptions(_ options: ARView.Environment.SceneUnderstanding.Options, _ enable: Bool) {
        guard enable != environment.sceneUnderstanding.options.contains(options) else {
            return
        }
        if enable {
            environment.sceneUnderstanding.options.insert(options)
        } else {
            environment.sceneUnderstanding.options.remove(options)
        }
    }
}
