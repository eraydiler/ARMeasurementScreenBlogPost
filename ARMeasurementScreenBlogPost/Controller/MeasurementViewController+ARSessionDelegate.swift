//
//  MeasurementViewController+ARSessionDelegate.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 22.07.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import ARKit

// MARK: - ARSessionDelegate

extension MeasurementViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else {
            return
        }
        
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else {
            return
        }
        
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        guard let frame = session.currentFrame else {
            return
        }
        
        updateSessionInfoLabel(for: frame, trackingState: camera.trackingState)
    }
}

// MARK: - Info

extension MeasurementViewController {
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty, // No planes detected
        .limited(.excessiveMotion),
        .limited(.initializing),
        .limited(.insufficientFeatures),
        .notAvailable:
            message = "Move your phone on a flat surface until it's detected"
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
        }
        
        print(message)
        //        measurementView.sessionInfo = message.attributed(textAttributes)
    }
}
