//
//  sss+Additions.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 24.07.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import SceneKit

extension SCNVector3 {
    // ARKit is using meter for length/width/height
    func distance(to vector: SCNVector3) -> Double {
        let xd = vector.x - self.x
        let yd = vector.y - self.y
        let zd = vector.z - self.z
        let distance = Double(sqrt(xd * xd + yd * yd + zd * zd))
        
        if distance < 0 {
            return (distance * -1)
        } else {
            return (distance)
        }
    }
}
