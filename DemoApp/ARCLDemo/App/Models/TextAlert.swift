//
//  TextAlert.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 15.05.2021.
//

import SwiftUI


public struct TextAlert {
    public var title: String
    public var message: String
    public var placeholder: String = ""
    public var accept: String = "OK" // The left-most button label
    public var cancel: String? = "Cancel" // The optional cancel (right-most) button label
    public var keyboardType: UIKeyboardType = .default // Keyboard tzpe of the TextField
    public var action: (String?) -> Void // Triggers when either of the two buttons closes the dialog
}
