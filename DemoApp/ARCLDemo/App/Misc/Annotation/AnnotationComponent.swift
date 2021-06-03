//
//  AnnotationComponent.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 01.06.2021.
//

import UIKit
import RealityKit


protocol HasAnnotationView: Entity {
    var annotationComponent: AnnotationComponent { get set }
}
extension HasAnnotationView {
    
    var view: AnnotationView? {
        get { annotationComponent.view }
        set { annotationComponent.view = newValue }
    }
    
    var shouldAnimate: Bool {
        get { annotationComponent.shouldAnimate }
        set { annotationComponent.shouldAnimate = newValue }
    }
    
    var projection: Projection? {
        get { annotationComponent.projection }
        set { annotationComponent.projection = newValue }
    }
    
    // Returns the center point of the enity's screen space view
    func getCenterPoint(_ point: CGPoint) -> CGPoint {
        guard let view = view else {
            fatalError("Called getCenterPoint(_point:) with no view.")
        }
        let xCoord = CGFloat(point.x) - (view.frame.width) / 2
        let yCoord = CGFloat(point.y) - (view.frame.height) / 2
        return CGPoint(x: xCoord, y: yCoord)
    }
    
    // Centers the entity's screen space view on the specified screen location.
    func setPositionCenter(_ position: CGPoint) {
        let centerPoint = getCenterPoint(position)
        guard let view = view else {
            fatalError("Called setPositionCenter(_ position:) with no view.")
        }
        view.frame.origin = CGPoint(x: centerPoint.x, y: centerPoint.y)
        
        // Updating the lastFrame of the StickyNoteView
        view.lastFrame = view.frame
    }
    

    // Animates the entity's view to the the specified screen location, and updates the shouldAnimate state of the entity.
    func animateTo(_ point: CGPoint) {

        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear) {
            self.setPositionCenter(point)
        }

        animator.addCompletion {
            switch $0 {
            case .end: self.annotationComponent.shouldAnimate = false
            default: self.annotationComponent.shouldAnimate = true
            }
        }
                
        animator.startAnimation()
    }
    
    // Updates the screen space position of an entity's annotation view to the current projection.
    func updateScreenPosition() {
        guard let projection = projection else { return }
        let projectedPoint = projection.projectedPoint
        // Hides the annotation if it can not visible from the current point of view
        isEnabled = projection.isVisible
        view?.isHidden = !isEnabled

        if shouldAnimate {
            animateTo(projectedPoint)
        } else {
            setPositionCenter(projectedPoint)
        }
    }
    
    func updateDistanceLabel(with text: String?) {
        guard let projection = projection else { return }
        guard projection.isVisible else { return }
        self.view?.distanceLabel.text = text
    }
    
}


struct AnnotationComponent: Component {
    var view: AnnotationView?
    var shouldAnimate = false
    var projection: Projection?
}

struct Projection {
    
    let projectedPoint: CGPoint
    let isVisible: Bool
    
}

