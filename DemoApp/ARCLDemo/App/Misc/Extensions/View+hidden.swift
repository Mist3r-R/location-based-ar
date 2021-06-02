//
//  View+hidden.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 16.05.2021.
//

import SwiftUI


extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
