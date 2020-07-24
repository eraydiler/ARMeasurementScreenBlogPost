//
//  ARSceneView+Additions.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 29.05.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import ARKit

extension ARSCNView {
    func realWorldPosition(for point: CGPoint) -> SCNVector3? {
        let result = self.hitTest(point, types: [ .featurePoint, .existingPlaneUsingExtent ])
        
        guard let hitResult = result.last else {
            return nil
        }
        
        let hitTransform = SCNMatrix4(hitResult.worldTransform)

        // m4x -> position 1: x, 2: y, 3: z
        let hitVector = SCNVector3Make(
            hitTransform.m41,
            hitTransform.m42,
            hitTransform.m43
        )

        return hitVector
    }
    
    func centerRealWorldPosition() -> SCNVector3? {
        realWorldPosition(for: center)
    }
}
