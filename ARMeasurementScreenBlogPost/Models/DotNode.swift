//
//  DotNode.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 8.06.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import SceneKit

final class DotNode: SCNNode {
    
    // MARK: - Initialization
    
    init(position: SCNVector3) {
        super.init()
        
        self.position = position
        
        let sphere = SCNSphere(radius: 0.003)
        
        sphere.firstMaterial?.diffuse.contents = UIColor(named: "primaryYellow")
        sphere.firstMaterial?.lightingModel = .constant
        sphere.firstMaterial?.isDoubleSided = true
        
        self.geometry = sphere
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
