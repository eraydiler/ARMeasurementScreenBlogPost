//
//  ARMeasurement.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 22.07.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import Foundation

struct ARMeasurement {
    let steps: [Step] = [.first, .second, .last]
    var currentStep: Step = .first
}

extension ARMeasurement {
    var isCompleted: Bool {
        return currentStep == steps.last
    }

    mutating func goNextStep() {
        guard
            let index = steps.firstIndex(of: currentStep),
            let nextStep = steps[safeIndex: index + 1]
            else {
                return
        }

        currentStep = nextStep
    }
    
    mutating func goPreviousStep() {
        guard
            let index = steps.firstIndex(of: currentStep),
            let previousStep = steps[safeIndex: index - 1]
            else {
                return
        }

        currentStep = previousStep
    }
}

extension ARMeasurement {
    enum Step {
        case first, second, last
    }
}
