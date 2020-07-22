//
//  simd_float4x4+Addition.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 22.07.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import SceneKit

extension simd_float4x4 {
    func toSCNVector3() -> SCNVector3 {
        return SCNVector3(
            self.columns.3.x,
            self.columns.3.y,
            self.columns.3.z
        )
    }
}
