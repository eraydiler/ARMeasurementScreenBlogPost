//
//  MeasurementDraft.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 8.06.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import SceneKit

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}

struct Measurement {
    let steps: [Step] = [.first, .second, .last]
    var currentStep: Step = .first
}

extension Measurement {
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

extension Measurement {
    enum Step {
        case first, second, last
    }
}

class MeasurementDraft {
    
    // MARK: - Properties

    var startDotNode: DotNode?
    var endDotNode: DotNode?
    var lines = [Line()]
    var distances = [Double()]
    
    private(set) var measurement = Measurement()

    // MARK: - Computed properties
    
    private var allNodes: [SCNNode] {
        var nodes = [SCNNode]()
        
        if let startDotNode = startDotNode {
            nodes.append(startDotNode)
        }
        
        if !lines.isEmpty {
            for aLine in lines {
                nodes.append(contentsOf: aLine.nodes)
            }
        }
        
        if let endDotNode = endDotNode {
            nodes.append(endDotNode)
        }
        
        return nodes
    }
}

// MARK: - Public

extension MeasurementDraft {
//    var info: String {
//        return measurement.info(forLength: distances.first)
//    }

    func reset() {
        allNodes.forEach { $0.removeFromParentNode() }
        startDotNode = nil
        endDotNode = nil
        lines = [Line(), Line()]
        distances = [Double(), Double()]
        measurement.currentStep = .first
    }

    func clearNodes() {
    }

    func goNextStep(fromStarting dotNode: DotNode) {
        switch measurement.currentStep {
        case .first:
            startDotNode = dotNode
        case .second:
            endDotNode = dotNode
        case .last:
            break
        }

        measurement.goNextStep()
    }

    func goPreviousStep() {
        switch measurement.currentStep {
        case .first:
            break
        case .second:
            startDotNode?.removeFromParentNode()
            startDotNode = nil
            if !lines.isEmpty {
                lines[0].removeFromParentNode()
                lines[0] = Line()
            }
            if !distances.isEmpty {
                distances[0] = Double()
            }
        case .last:
            endDotNode?.removeFromParentNode()
            endDotNode = nil
            if !lines.isEmpty {
                lines[0].removeFromParentNode()
                lines[0] = Line()
            }
            if !distances.isEmpty {
                distances[0] = Double()
            }
        }

        measurement.goPreviousStep()
    }
}
