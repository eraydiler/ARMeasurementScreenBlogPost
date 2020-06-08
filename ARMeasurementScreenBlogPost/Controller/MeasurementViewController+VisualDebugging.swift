//
//  MeasurementViewController+VisualDebugging.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 8.06.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import ARKit
import SceneKit

extension MeasurementViewController {
    private var isDebuggingEnabled: Bool { true }
    
    func addPlaneFor(_ node: SCNNode, _ anchor: ARAnchor) {
        if !isDebuggingEnabled {
            return
        }
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = PlaneNode(anchor: planeAnchor, in: measurementView)
        node.addChildNode(plane)
        self.planes[planeAnchor] = plane
    }
    
    func updatePlaneFor(_ node: SCNNode, _ anchor: ARAnchor) {
        if !isDebuggingEnabled {
            return
        }
        guard
            let planeAnchor = anchor as? ARPlaneAnchor,
            let plane = node.childNodes.first as? PlaneNode
            else {
                return
        }
        
        // Update ARSCNPlaneGeometry to the anchor's new estimated shape.
        if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: planeAnchor.geometry)
        }
        
        // Update extent visualization to the anchor's new bounding rectangle.
        if let extentGeometry = plane.extentNode.geometry as? SCNPlane {
            extentGeometry.width = CGFloat(planeAnchor.extent.x)
            extentGeometry.height = CGFloat(planeAnchor.extent.z)
            plane.extentNode.simdPosition = planeAnchor.center
        }
    }
    
    func removePlane(for anchor: ARAnchor) {
        if !isDebuggingEnabled {
            return
        }
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        planes.removeValue(forKey: planeAnchor)
    }
    
    func updateIndicatorPosition(for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        self.measurementView.updateIndicatorPosition(with: planeAnchor.alignment)
    }
}
