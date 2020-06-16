//
//  MeasurementViewController.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 24.05.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class MeasurementViewController: UIViewController {
    
    // MARK: - Properties

    var planes = [ARPlaneAnchor: PlaneNode]()
    private var draft = MeasurementDraft()
    private var isMeasuring = false
    
    // MARK: - Subviews

    private(set) lazy var measurementView = MeasurementView()
        
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setListeners()
        addMeasurementView()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        measurementView.runSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        measurementView.pauseSession()
    }

    private func setListeners() {
        measurementView.delegate = self
        measurementView.session.delegate = self
    }
    
    private func addMeasurementView() {
        view.addSubview(measurementView)
        
        measurementView.addConstraints(
            equalToSuperview(
                with: .zero,
                pinBottomToSafeArea: true,
                pinTopToSafeArea: false
            )
        )
    }
    
    // MARK: - Actions
    
    @objc
    private func createDotNode() {
        if draft.measurement.isCompleted {
            return
        }
        
        guard let position = centerDotWorldPositionOnExistingPlanes() else {
            return
        }
        
        if !isMeasuring {
            isMeasuring = true
        }
        
        let dotNode = DotNode(position: position)
        goNextStep(fromStarting: dotNode)
        measurementView.addChildNode(dotNode)
    }
    
    @objc
    private func reset() {
        isMeasuring = false
        draft.reset()
//        updateStepInfoLabelText()
    }

    // MARK: - UI Updates
    
    private func updateCurrentDistanceIfNeeded() {
        if draft.measurement.isCompleted {
            return
        }
        
        guard let distance = calculateCurrentDistance() else {
            return
        }
        
        let distanceText: String
//        if draft.unitSystem == .metric {
            distanceText = String(format: "%.1f cm", distance)
//        } else {
//            distanceText = String(format: "%.1f\"", distance)
//        }
        
        switch draft.measurement.currentStep {
        case .first:
            break
        case .second:
            draft.distances[0] = distance
            draft.lines[0].textString = distanceText
        case .last:
            break
        }
    }
}

// MARK: - Distance calculation

extension MeasurementViewController {
    private func calculateCurrentDistance() -> Double? {
        let fromDotNode = draft.startDotNode

        guard
            let fromPosition = fromDotNode?.position,
            let toPosition = centerDotWorldPositionOnExistingPlanes()
            else {
                return nil
        }

        return calculateDistance(from: fromPosition, to: toPosition)
    }
    
    private func calculateDistance(from fromVector: SCNVector3, to toVector: SCNVector3) -> Double {
        
        // ARKit is using meter for length/width/height
        let distanceInMeters = sqrt(
            (fromVector.x - toVector.x) * (fromVector.x - toVector.x)
                + (fromVector.y - toVector.y) * (fromVector.y - toVector.y)
                + (fromVector.z - toVector.z) * (fromVector.z - toVector.z)
        )
        
        let centimeterConvertionRatio: Float = 100.0
        
        return Double(distanceInMeters * centimeterConvertionRatio) // in metric
    }
}

// MARK: - Line Drawing

extension MeasurementViewController {
    private func drawLineIfNeeded() {
        if draft.measurement.isCompleted {
            return
        }
        
        let fromDotNode = draft.startDotNode
        
        guard
            let fromPosition = fromDotNode?.position,
            let toPosition = self.centerDotWorldPositionOnExistingPlanes()
            else {
                return
        }
        
        switch draft.measurement.currentStep {
        case .first, .last:
            break
        case .second:
            let line = Line(
                fromVector: fromPosition,
                toVector: toPosition,
                pointOfView: measurementView.pointOfView
            )

            for node in draft.lines[0].nodes {
                node.removeFromParentNode()
            }

            draft.lines[0].removeFromParentNode()
            draft.lines[0] = line

            for node in line.nodes {
                measurementView.addChildNode(node)
            }
        }

    }
}

// MARK: - Step Updates

extension MeasurementViewController {
    private func goNextStep(fromStarting dotNode: DotNode) {
        draft.goNextStep(fromStarting: dotNode)
//        updateStepInfoLabelText()
    }
    
    private func goPreviousStep() {
        draft.goPreviousStep()
//        updateStepInfoLabelText()
    }
}

// MARK: - Position calculation between world and UI

extension MeasurementViewController {
    private func nearestCenterWorldPositionOnAvailablePlanes() -> simd_float4x4? {
        let results = measurementView.hitTest(
            view.center,
            types: [ .featurePoint, .existingPlaneUsingExtent ]
        )
        
        return results.first?.worldTransform
    }
    
    private func centerDotWorldPositionOnExistingPlanes() -> SCNVector3? {
        return nearestCenterWorldPositionOnAvailablePlanes()?.toSCNVector3()
    }
}

// MARK: ARSCNViewDelegate

extension MeasurementViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            self.addPlaneFor(node, anchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            self.updateIndicatorPosition(for: anchor)
            self.updatePlaneFor(node, anchor)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            self.removePlane(for: anchor)
        }
    }
        
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !isMeasuring || draft.measurement.isCompleted {
            return
        }
        
        DispatchQueue.main.async {
            self.drawLineIfNeeded()
            self.updateCurrentDistanceIfNeeded()
        }
    }
}

// MARK: - ARSessionDelegate

extension MeasurementViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else {
            return
        }
        
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else {
            return
        }
        
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        guard let frame = session.currentFrame else {
            return
        }
        
        updateSessionInfoLabel(for: frame, trackingState: camera.trackingState)
    }
}

// MARK: - ARMeasureViewDelegate

extension MeasurementViewController: MeasureViewDelegate {
    func measurementViewDidTapUndo(_ view: MeasurementView) {
        goPreviousStep()
    }
    
    func measurementViewDidTapAdd(_ view: MeasurementView) {
        createDotNode()
    }
    
    func measurementViewDidTapClear(_ view: MeasurementView) {
        reset()
    }
}

// MARK: - Info

extension MeasurementViewController {
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty, // No planes detected
        .limited(.excessiveMotion),
        .limited(.initializing),
        .limited(.insufficientFeatures),
        .notAvailable:
            message = "Move your phone on a flat surface until it's detected"
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
        }
        
        print(message)
        //        measurementView.sessionInfo = message.attributed(textAttributes)
    }
}


extension simd_float4x4 {
    func toSCNVector3() -> SCNVector3 {
        return SCNVector3(
            self.columns.3.x,
            self.columns.3.y,
            self.columns.3.z
        )
    }
}
