//
//  ARMeasurementFormatter.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 22.07.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import Foundation

class ARMeasurementFormatter: MeasurementFormatter {
    override init() {
        super.init()
        
        unitOptions = [.providedUnit]
        unitStyle = .short
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        self.numberFormatter = numberFormatter
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
