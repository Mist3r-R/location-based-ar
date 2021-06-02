//
//  LBARViewDelegates.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 19.05.2021.
//

import Foundation
import ARKit
import CoreLocation


public protocol LBARViewDelegate: class {
    func view(_ view: LBARView, didAdd anchors: [LBAnchor])
    func view(_ view: LBARView, didUpdate anchors: [LBAnchor])
    func view(_ view: LBARView, didRemove anchors: [LBAnchor])
}

public protocol LBARViewObserver: class {
    func view(_ view: LBARView, didChange trackingStatus: LBARTrackingStatus)
    func view(_ view: LBARView, didFail loadingMap: ARWorldMap, for coordinate: CLLocationCoordinate2D)
    func view(_ view: LBARView, didLoad worldMap: ARWorldMap, for coordinate: CLLocationCoordinate2D)
}

public extension LBARViewDelegate {
    func view(_ view: LBARView, didAdd anchors: [LBAnchor]) { }
    func view(_ view: LBARView, didUpdate anchors: [LBAnchor]) { }
    func view(_ view: LBARView, didRemove anchors: [LBAnchor]) { }
}

public extension LBARViewObserver {
    func view(_ view: LBARView, didChange trackingStatus: LBARTrackingStatus) { }
    func view(_ view: LBARView, didFail loadingMap: ARWorldMap, for coordinate: CLLocationCoordinate2D) { }
    func view(_ view: LBARView, didLoad worldMap: ARWorldMap, for coordinate: CLLocationCoordinate2D) { }
}
