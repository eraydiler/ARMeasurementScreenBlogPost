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
    private var draft = ARMeasurementDraft()
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
        
        draft.setDistance(calculateCurrentDistance())
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
                
        return Double(distanceInMeters)
    }
}

// MARK: - Line Drawing

extension MeasurementViewController {
    private func drawLineIfNeeded() {
        if draft.measurement.isCompleted {
            return
        }
        
        let line = draft.addLine(
            to: centerDotWorldPositionOnExistingPlanes(),
            withPointOfView: measurementView.pointOfView
        )
        
        measurementView.addChildNodes(line?.nodes ?? [])
    }
}

// MARK: - Step Updates

extension MeasurementViewController {
    private func goNextStep(fromStarting dotNode: DotNode) {
        draft.goNextStep(fromStarting: dotNode)
    }
    
    private func goPreviousStep() {
        draft.goPreviousStep()
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
            self.measurementView.resetIndicatorPosition()
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

// MARK: - ARMeasureViewDelegate

extension MeasurementViewController: MeasurementViewDelegate {
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
