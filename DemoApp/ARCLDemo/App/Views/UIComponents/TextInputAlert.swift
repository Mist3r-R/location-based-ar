//
//  TextInputAlert.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 15.05.2021.
//

import SwiftUI


struct AlertWrapper<Item: Identifiable, Content: View>: UIViewControllerRepresentable {
    
    @Binding var item: Item?
    let alert: TextAlert
    let content: Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIHostingController<Content> {
        UIHostingController(rootView: content)
    }
    
    final class Coordinator {
        var alertController: UIAlertController?
        init(_ controller: UIAlertController? = nil) {
            self.alertController = controller
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<AlertWrapper>) {
        uiViewController.rootView = content
        if item != nil && uiViewController.presentedViewController == nil {
            var alert = self.alert
            alert.action = {
                self.alert.action($0)
                self.item = nil
            }
            context.coordinator.alertController = UIAlertController(alert: alert)
            uiViewController.present(context.coordinator.alertController!, animated: true)
        }
        if item == nil && uiViewController.presentedViewController == context.coordinator.alertController {
            uiViewController.dismiss(animated: true)
        }
    }
}
