//
//  ARContainer.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 06.05.2021.
//

import SwiftUI
import RealityKit


struct ARViewContainer: UIViewRepresentable {
    
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var arSessionManager: ARSessionManager
    
    func makeUIView(context: Context) -> FocusedARView {
        let arView = arSessionManager.arView
        
        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self) { event in
            self.updateScene(for: arView)
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: FocusedARView, context: Context) {
        // ...
    }
    
    private func updateScene(for arView: FocusedARView) {
        
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
        
        if let confirmedModel = self.placementSettings.confirmedModel, let modelEntity = confirmedModel.modelEntity {
            
            self.arSessionManager.place(modelEntity)
            self.placementSettings.confirmedModel = nil
        }
        
        self.arSessionManager.updateAnnotations()
    }
}


struct ARContainer: View {
    
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var arSessionManager: ARSessionManager
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer()
            if self.placementSettings.selectedModel == nil {
                ARControls()
            } else {
                PlacementView()
            }
            
            if arSessionManager.notification != nil {
                VStack {
                    Message(
                        title: arSessionManager.notification?.notification.title ?? "",
                        text: arSessionManager.notification?.notification.message ?? ""
                    )
                    .animation(.easeInOut)
                    
                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .alert(item: $arSessionManager.sessionError) { error in
            Alert(title: Text("AR session failed!"), message: Text(error.message),
                  dismissButton: .cancel(Text("Restart"), action: { self.arSessionManager.resetSession() }))
        }
        .actionSheet(item: $arSessionManager.selectedAnchor) { locationAnchor in
            ActionSheet(
                title: Text(locationAnchor.title),
                message: Text(locationAnchor.stringDescription),
                buttons: [
                    .destructive(Text("Remove"), action: {
                        self.arSessionManager.delete(anchorData: locationAnchor)
                    }),
                    .cancel()
                ]
            )
        }
    }
}
