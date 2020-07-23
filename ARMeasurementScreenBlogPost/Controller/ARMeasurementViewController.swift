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
        DispatchQueue.main.async {
            let position = self.measurementView.centerRealWorldPosition()
            let pointOfView = self.measurementView.pointOfView
            
            if let line = self.draft.drawLineIfNeeded(to: position, withPointOfView: pointOfView) {
                self.measurementView.addChildNodes(line.nodes)
            }
            self.draft.updateCurrentDistanceIfNeeded(to: position)
        }
    }
}

// MARK: - ARMeasureViewDelegate

extension ARMeasurementViewController: MeasurementViewDelegate {
    func measurementViewDidTapUndo(_ view: ARMeasurementView) {
        draft.goPreviousStep()
    }
    
    func measurementViewDidTapAdd(_ view: ARMeasurementView) {
        if let dotNode = draft.addDotNode(to: measurementView.centerRealWorldPosition()) {
            draft.goNextStep(fromStarting: dotNode)
            measurementView.addChildNode(dotNode)
        }
    }
    
    func measurementViewDidTapClear(_ view: ARMeasurementView) {
        draft.reset()
    }
}
