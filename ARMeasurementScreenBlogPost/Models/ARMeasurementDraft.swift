//
//  MeasurementDraft.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 8.06.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import SceneKit

class ARMeasurementDraft {
    
    // MARK: - Properties

    var startDotNode: DotNode?
    var endDotNode: DotNode?
    var line: Line?
    
    private(set) var measurement = ARMeasurement()

    // MARK: - Computed properties
    
    private var allNodes: [SCNNode] {
        var nodes = [SCNNode]()
        
        if let startDotNode = startDotNode {
            nodes.append(startDotNode)
        }
        
        if let line = line {
            nodes.append(contentsOf: line.nodes)
        }
        
        if let endDotNode = endDotNode {
            nodes.append(endDotNode)
        }
        
        return nodes
    }
}

// MARK: - Public

extension ARMeasurementDraft {
//    var info: String {
//        return measurement.info(forLength: distances.first)
//    }

    func reset() {
        allNodes.forEach { $0.removeFromParentNode() }
        startDotNode = nil
        endDotNode = nil
        line = nil
        measurement.currentStep = .first
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
            line?.removeFromParentNode()
            line = nil
        case .last:
            endDotNode?.removeFromParentNode()
            endDotNode = nil
            line?.removeFromParentNode()
            line = nil
        }

        measurement.goPreviousStep()
    }
    
    func setDistance(_ distance: Double?) {
        guard let distance = distance else { return }
        
        var measurement = Measurement(value: distance, unit: UnitLength.meters)
        
        if Locale.current.usesMetricSystem {
            measurement = measurement.converted(to: UnitLength.centimeters)
        } else {
            measurement = measurement.converted(to: UnitLength.inches)
        }
        
        let distanceText = ARMeasurementFormatter().string(from: measurement)
        
        switch self.measurement.currentStep {
        case .first:
            break
        case .second:
            line?.textString = distanceText
        case .last:
            break
        }
    }
    
    func addLine(
        to position: SCNVector3?,
        withPointOfView pointOfView: SCNNode?
    ) -> Line? {
        guard
            measurement.currentStep == .second,
            let fromPosition = startDotNode?.position,
            let toPosition = position,
            let pointOfView = pointOfView
            else {
                return nil
        }
        
        let line = Line(
            fromVector: fromPosition,
            toVector: toPosition,
            pointOfView: pointOfView
        )
        
        self.line?.nodes.forEach { $0.removeFromParentNode() }
        self.line?.removeFromParentNode()
        self.line = line
        
        return line
    }
}
