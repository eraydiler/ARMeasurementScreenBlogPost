//
//  Line.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 8.06.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import SceneKit
import ARKit

final class Line {
    
    // MARK: - Properties
    
    private let lineNode: CylinderLineNode
    private let textNode: SCNNode
    private var text = SCNText()
    
    // MARK: - Initializations
    
    init(fromVector: SCNVector3, toVector: SCNVector3, pointOfView: SCNNode?) {
        lineNode = CylinderLineNode(
            fromVector: fromVector,
            toVector: toVector,
            radius: 0.001,
            radSegmentCount: 16,
            color: UIColor(named: "primaryYellow") ?? UIColor.yellow
        )
        textNode = SCNNode()

        setupTextNode(fromVector: fromVector, toVector: toVector, pointOfView: pointOfView)
    }
    
    init() {
        lineNode = CylinderLineNode()
        textNode = SCNNode()
        text = SCNText()
    }
    
    // MARK: - Setup
    
    private func setupTextNode(fromVector: SCNVector3, toVector: SCNVector3, pointOfView: SCNNode?) {
        text.extrusionDepth = 0.4
        text.chamferRadius = 0.1
        text.font = .systemFont(ofSize: 5, weight: .bold)
        text.firstMaterial?.diffuse.contents = UIColor(named: "primaryYellow")
        text.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        text.truncationMode = CATextLayerTruncationMode.middle.rawValue
        text.firstMaterial?.isDoubleSided = true
        
        let textWrapperNode = SCNNode(geometry: text)
        
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1 / 500.0, 1 / 500.0, 1 / 500.0)
        textNode.addChildNode(textWrapperNode)
        
        let constraint = SCNLookAtConstraint(target: pointOfView)
        
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        
//        textNode.position = SCNVector3(
//            (fromVector.x + toVector.x) / 2.0,
//            (fromVector.y + toVector.y) / 2.0,
//            (fromVector.z + toVector.z) / 2.0
//        )
        textNode.position = toVector
    }
    
    // MARK: - Helpers
    
    var nodes: [SCNNode] {
        return [lineNode, textNode]
    }
    
    var textString: String? {
        get {
            return text.string as? String ?? nil
        }
        set {
            text.string = newValue
        }
    }
    
    func removeFromParentNode() {
        lineNode.removeFromParentNode()
        textNode.removeFromParentNode()
    }
}
