//
//  AnnotationEntity.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 01.06.2021.
//

import ARKit
import RealityKit
import LocationBasedAR


class AnnotationEntity: Entity, HasAnchoring, HasAnnotationView {
    // ...

    var annotationComponent = AnnotationComponent()
    
    /// Initializes a new StickyNoteEntity and assigns the specified transform.
    /// Also automatically initializes an associated StickyNoteView with the specified frame.
    init(frame: CGRect, anchor: LBAnchor) {
        super.init()
        self.anchoring = AnchoringComponent(anchor)
        // ...
        annotationComponent.view = AnnotationView(frame: frame, annotation: self)
        annotationComponent.view?.titleLabel.text = anchor.name
    }
    required init() {
        fatalError("init() has not been implemented")
    }
}
