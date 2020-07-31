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
    private let textNode: TextNode
    
    // MARK: - Initializations
    
    init(
        fromVector: SCNVector3,
        toVector: SCNVector3,
        pointOfView: SCNNode?
    ) {
        lineNode = CylinderLineNode(
            fromVector: fromVector,
            toVector: toVector,
            radius: 0.001,
            radSegmentCount: 16,
            color: UIColor.yellow
        )
        
        textNode = TextNode(
            vector: toVector,
            pointOfView: pointOfView
        )
    }
    
    // MARK: - Helpers
    
    var nodes: [SCNNode] {
        return [lineNode, textNode]
    }
    
    var textString: String? {
        get {
            return textNode.text
        }
        set {
            textNode.text = newValue
        }
    }
    
    func removeFromParentNode() {
        lineNode.removeFromParentNode()
        textNode.removeFromParentNode()
    }
}

private final class TextNode: SCNNode {
    private var textGeometry = SCNText()
    private lazy var textWrapperNode = SCNNode(geometry: textGeometry)

    init(
        vector: SCNVector3,
        pointOfView: SCNNode?
    ) {
        super.init()
        
        customizeTextNodeFor(
            vector: vector,
            pointOfView: pointOfView
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customizeTextNodeFor(
        vector: SCNVector3,
        pointOfView: SCNNode?
    ) {
        textGeometry.extrusionDepth = 0.4
        textGeometry.chamferRadius = 0.1
        textGeometry.font = .systemFont(ofSize: 5, weight: .bold)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        textGeometry.truncationMode = CATextLayerTruncationMode.middle.rawValue
        textGeometry.firstMaterial?.isDoubleSided = true
                
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1 / 500.0, 1 / 500.0, 1 / 500.0)
        addChildNode(textWrapperNode)
        
        let constraint = SCNLookAtConstraint(target: pointOfView)
        constraint.isGimbalLockEnabled = true
        
        constraints = [constraint]
        position = vector
    }
}

extension TextNode {
    var text: String? {
        get {
            return textGeometry.string as? String ?? nil
        }
        set {
            textGeometry.string = newValue
        }
    }
}
