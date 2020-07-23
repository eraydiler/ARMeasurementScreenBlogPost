//
//  ARMeasurementViewController.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 24.05.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARMeasurementViewController: UIViewController {
    
    // MARK: - Properties

    var planes = [ARPlaneAnchor: PlaneNode]()
    private var draft = ARMeasurementDraft()
    
    // MARK: - Subviews

    private(set) lazy var measurementView = ARMeasurementView()
        
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
    
    private func createDotNode() {
        if draft.measurement.isCompleted {
            return
        }
        
        guard let position = measurementView.centerRealWorldPosition() else {
            return
        }
                
        let dotNode = DotNode(position: position)
        goNextStep(fromStarting: dotNode)
        measurementView.addChildNode(dotNode)
    }
    
    private func reset() {
        draft.reset()
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

extension ARMeasurementViewController {
    private func calculateCurrentDistance() -> Double? {
        let fromDotNode = draft.startDotNode

        guard
            let fromPosition = fromDotNode?.position,
            let toPosition = measurementView.centerRealWorldPosition()
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

extension ARMeasurementViewController {
    private func drawLineIfNeeded() {
        if draft.measurement.isCompleted {
            return
        }
        
        let line = draft.addLine(
            to: measurementView.centerRealWorldPosition(),
            withPointOfView: measurementView.pointOfView
        )
        
        measurementView.addChildNodes(line?.nodes ?? [])
    }
}

// MARK: - Step Updates

extension ARMeasurementViewController {
    private func goNextStep(fromStarting dotNode: DotNode) {
        draft.goNextStep(fromStarting: dotNode)
    }
    
    private func goPreviousStep() {
        draft.goPreviousStep()
    }
}

// MARK: ARSCNViewDelegate

extension ARMeasurementViewController: ARSCNViewDelegate {
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
        if draft.measurement.isCompleted {
            return
        }
        
        DispatchQueue.main.async {
            self.drawLineIfNeeded()
            self.updateCurrentDistanceIfNeeded()
        }
    }
}

// MARK: - ARMeasureViewDelegate

extension ARMeasurementViewController: MeasurementViewDelegate {
    func measurementViewDidTapUndo(_ view: ARMeasurementView) {
        goPreviousStep()
    }
    
    func measurementViewDidTapAdd(_ view: ARMeasurementView) {
        createDotNode()
    }
    
    func measurementViewDidTapClear(_ view: ARMeasurementView) {
        reset()
    }
}
