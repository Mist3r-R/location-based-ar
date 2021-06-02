//
//  Message.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 02.06.2021.
//

import SwiftUI


struct Message: View {
    
    var title: String
    var text: String
    
    var body: some View {
        HStack {
            Spacer()
            
            ZStack {
                Color.black.opacity(0.25)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.label)
                        .lineLimit(1)
                    Text(text)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondaryLabel)
                        .lineLimit(1)
                }
            }
            .frame(width: 200, height: 50)
            .cornerRadius(8.0)
            
            Spacer()
        }
        .padding(.top, 25)
    }
}
