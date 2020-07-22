//
//  Array+Additions.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 22.07.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
