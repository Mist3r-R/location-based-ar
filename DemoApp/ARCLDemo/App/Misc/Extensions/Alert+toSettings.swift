//
//  Alert+toSettings.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 20.05.2021.
//

import SwiftUI


extension Alert {
    static func openSettingsAlert(title: String, message: String) -> Alert {
        return Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text("Open Settings"), action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
        )
    }
}
