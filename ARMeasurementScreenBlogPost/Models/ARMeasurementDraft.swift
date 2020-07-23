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

    private var startDotNode: DotNode?
    private var endDotNode: DotNode?
    private var line: Line?
    private var measurement = ARMeasurement()

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
}

// MARK: - Dot node creation

extension ARMeasurementDraft {
    func addDotNode(to position: SCNVector3?) -> DotNode? {
        if measurement.isCompleted {
            return nil
        }
        
        guard let position = position else {
            return nil
        }
                
        return DotNode(position: position)
    }
}

// MARK: - Line Drawing

extension ARMeasurementDraft {
    func drawLineIfNeeded(
        to position: SCNVector3?,
        withPointOfView pointOfView: SCNNode?
    ) -> Line? {
        if measurement.isCompleted {
            return nil
        }
        
        return addLine(to: position, withPointOfView: pointOfView)
    }

    private func addLine(
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

// MARK: - Distance calculation

extension ARMeasurementDraft {
    func updateCurrentDistanceIfNeeded(to position: SCNVector3?) {
        if measurement.isCompleted {
            return
        }

        guard
            let fromPosition = startDotNode?.position,
            let toPosition = position
            else {
                return
        }

        let distance = calculateDistance(from: fromPosition, to: toPosition)
        setDistance(distance)
    }
    
    private func calculateDistance(
        from fromVector: SCNVector3,
        to toVector: SCNVector3
    ) -> Double {
        // ARKit is using meter for length/width/height
        let distanceInMeters = sqrt(
            (fromVector.x - toVector.x) * (fromVector.x - toVector.x)
                + (fromVector.y - toVector.y) * (fromVector.y - toVector.y)
                + (fromVector.z - toVector.z) * (fromVector.z - toVector.z)
        )
                
        return Double(distanceInMeters)
    }
    
    private func setDistance(_ distance: Double?) {
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
}
