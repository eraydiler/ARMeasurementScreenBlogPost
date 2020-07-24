//
//  CylinderLineNode.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 8.06.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import SceneKit

class CylinderLineNode: SCNNode {
    init(
        fromVector: SCNVector3,
        toVector: SCNVector3,
        radius: CGFloat,
        radSegmentCount: Int,
        color: UIColor
    ) {
        super.init()
        
        let height = fromVector.distance(to: toVector)
        position = fromVector
        
        let nodeV2 = SCNNode()
        nodeV2.position = toVector
        
        let zAlign = SCNNode()
        zAlign.eulerAngles.x = Float(CGFloat.pi / 2)
        
        let cylinder = SCNCylinder(radius: radius, height: CGFloat(height))
        cylinder.radialSegmentCount = radSegmentCount
        cylinder.firstMaterial?.diffuse.contents = color
        
        let nodeCylinder = SCNNode(geometry: cylinder )
        nodeCylinder.position.y = -Float(height / 2)
        zAlign.addChildNode(nodeCylinder)
        
        addChildNode(zAlign)
        
        constraints = [SCNLookAtConstraint(target: nodeV2)]
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
