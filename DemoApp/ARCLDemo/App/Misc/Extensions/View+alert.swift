//
//  View+alert.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 20.05.2021.
//

import SwiftUI


extension View {
    
    public func alert<Item: Identifiable>(item: Binding<Item?>, _ alert: TextAlert) -> some View {
        AlertWrapper(item: item, alert: alert, content: self)
    }
}

extension UIAlertController {
    convenience init(alert: TextAlert) {
        self.init(title: alert.title, message: alert.message, preferredStyle: .alert)
        addTextField {
            $0.placeholder = alert.placeholder
            $0.keyboardType = alert.keyboardType
        }
        if let cancel = alert.cancel {
            addAction(UIAlertAction(title: cancel, style: .cancel) { _ in
                alert.action(nil)
            })
        }
        let textField = self.textFields?.first
        addAction(UIAlertAction(title: alert.accept, style: .default) { _ in
            alert.action(textField?.text)
        })
    }
}
