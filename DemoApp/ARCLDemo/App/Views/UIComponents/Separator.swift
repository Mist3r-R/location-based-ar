//
//  Separator.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 06.05.2021.
//

import SwiftUI


struct Separator: View {
    
    var horizontalPadding: CGFloat = 20
    var verticalPadding: CGFloat = 10
    
    var body: some View {
        Divider()
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
    }
}
