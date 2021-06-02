//
//  FocusedARView.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 21.05.2021.
//

import SwiftUI
import ARKit
import RealityKit
import FocusEntity
import LocationBasedAR


class FocusedARView: LBARView {
    
    var focusEntity: FocusEntity?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.scalingScheme = .equal
        focusEntity = FocusEntity(on: self, focus: .classic)
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FocusEntity {
    var publicLastPosition: float4x4? {
        switch state {
        case .initializing: return nil
        case .tracking(let raycastResult, _): return raycastResult.worldTransform
        }
    }
}
