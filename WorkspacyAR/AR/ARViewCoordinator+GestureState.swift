//
//  ARViewCoordinator+Transform.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 22/07/26.
//

import Foundation
import RealityKit
import UIKit

extension ARViewCoordinator {

    public func updateGesturesState(_ interactionMode: ARInteractionMode? = nil)
    {
        guard let arView = arView,
            let gestureRecognizers = arView.gestureRecognizers
        else { return }

        for gesture in gestureRecognizers {
            if let translationGesture = gesture
                as? EntityTranslationGestureRecognizer
            {
                translationGesture.isEnabled =
                    (stateManager.interactionMode == .move)
            } else if let rotationGesture = gesture
                as? EntityRotationGestureRecognizer
            {
                rotationGesture.isEnabled =
                    (stateManager.interactionMode == .rotate)
            } else if let panGesture = gesture as? UIPanGestureRecognizer,
                panGesture.minimumNumberOfTouches == 2
            {
                panGesture.isEnabled = (stateManager.interactionMode == .move)
            }
        }
    }
}
