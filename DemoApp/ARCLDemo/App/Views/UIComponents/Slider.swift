//
//  Slider.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 02.06.2021.
//

import SwiftUI

struct SliderControl: View {
    
    var label: String
    var range: ClosedRange<Double> = 500...5000
    var step: Double = 100
    @Binding var value: Double
    
    var body: some View {
        VStack {
            Text("\(label): \(Int(value))")
            
            Slider(value: $value, in: range, step: step)
                .accentColor(.systemGreen)
        }.padding()
    }
}
