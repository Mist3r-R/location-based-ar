//
//  MapContainer.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 04.05.2021.
//

import SwiftUI
import CoreLocation
import LocationBasedAR

struct MapContainer: View {
    
    @EnvironmentObject var locationManager: LBSManager
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var arSessionManager: ARSessionManager
    
    var body: some View {
        ZStack {
            MapView()
                .environmentObject(mapViewModel)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        SystemIconButton(systemIconName: mapViewModel.locationButtonIcon, action: {
                            mapViewModel.changeTrackingMode()
                        }).buttonStyle(MapButtonStyle())
//                        SystemIconButton(systemIconName: mapViewModel.annotationsIcon, action: {
//                            if mapViewModel.showAnnotations {
//                                mapViewModel.removeAnnotations()
//                            } else {
//                                mapViewModel.addAnnotations()
//                            }
//                        }).buttonStyle(MapButtonStyle())
//                        SystemIconButton(systemIconName: mapViewModel.indicatorsIcon, action: {
//                            if mapViewModel.showIndicators {
//                                mapViewModel.removeIndicators()
//                            } else {
//                                mapViewModel.addIndicators()
//                            }
//                        }).buttonStyle(MapButtonStyle())
                    }
                    
                }
                Spacer()
            }
            .padding(.all, 20)
        }
        .alert(isPresented: $locationManager.permissionDenied, content: {
            .openSettingsAlert(title: "Persmission Denied", message: "Enable Location Tracking in Settings")
        })
        .alert(isPresented: $locationManager.accuracyDenied, content: {
            .openSettingsAlert(title: "Persmission Denied", message: "Enable Full Accuracy Tracking in Settings")
        })
        .alert(
            item: $mapViewModel.selectedLocation,
            TextAlert(
                title: "New Anchor",
                message: "Input name for anchor at \n\(mapViewModel.selectedLocation?.text ?? "")",
                action: { result in
                    guard let text = result, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    guard let coordinate = self.mapViewModel.selectedLocation?.coordinate else { return }
                    let anchorName = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.arSessionManager.add(location: Placemark(coordinate: coordinate, accuracy: 0, placeName: anchorName))
                }
            )
        )
    }
}

struct MapContainer_Previews: PreviewProvider {
    static var previews: some View {
        MapContainer()
    }
}
