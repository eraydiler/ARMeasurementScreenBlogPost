//
//  MeasurementView.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 29.05.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import ARKit

protocol MeasureViewDelegate: ARSCNViewDelegate {
    func measurementViewDidTapUndo(_ view: MeasurementView)
    func measurementViewDidTapClear(_ view: MeasurementView)
    func measurementViewDidTapAdd(_ view: MeasurementView)
}

final class MeasurementView: ARSCNView {
        
    // MARK: - Properties
    
    private let layout = LayoutConstants()
    
    // MARK: - Subviews
    
    private lazy var undoButton = UIButton()
    private lazy var clearButton = UIButton()
    private lazy var indicatorNode = SCNNode()
    private lazy var centerDotView = UIImageView(image: UIImage(named: "icon-dot"))
    private lazy var addButton = UIButton()
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: CGRect.zero, options: [:])
        
        customizeAppearance()
        linkInteractors()
        prepareLayout()
        runSession()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Setup

extension MeasurementView {
    private func customizeAppearance() {
        customizeScene()
        customizeUndoButton()
        customizeClearButton()
        customizeAddButton()
    }
    
    private func prepareLayout() {
        setupUndoButtonLayout()
        setupClearButtonLayout()
        setupCenterDotViewLayout()
        setupAddButtonLayout()
    }
        
    private func linkInteractors() {
        undoButton.addTarget(
            self,
            action: #selector(notifyDelegateUndoButtonDidTap),
            for: .touchUpInside
        )
        clearButton.addTarget(
            self,
            action: #selector(notifyDelegateClearButtonDidTap),
            for: .touchUpInside
        )
        addButton.addTarget(
            self,
            action: #selector(notifyDelegateAddButtonDidTap),
            for: .touchUpInside
        )
    }
}

// MARK: - Appearance

extension MeasurementView {
    private func customizeScene() {
        scene = SCNScene()
        showsStatistics = false // Shows fps and timing information
        autoenablesDefaultLighting = true
        debugOptions = [
//            ARSCNDebugOptions.showFeaturePoints,
//            ARSCNDebugOptions.showWorldOrigin
        ]
    }
    
    private func customizeUndoButton() {
        undoButton.setImage(UIImage(named: "btn-bg-image-undo"), for: .normal)
        undoButton.setTitleColor(.black, for: .normal)
    }
    
    private func customizeClearButton() {
        clearButton.setTitleColor(.black, for: .normal)
        clearButton.setBackgroundImage(UIImage(named: "btn-bg-image-clear"), for: .normal)
        clearButton.contentEdgeInsets = layout.clearButtonContentEdgeInsets
    }
    
    private func customizeAddButton() {
        addButton.setBackgroundImage(UIImage(named: "btn-bg-image-add"), for: .normal)
    }
}

// MARK: - Layout

extension MeasurementView {
    private func setupUndoButtonLayout() {
        addSubview(undoButton)
                
        undoButton.addConstraints([
            equal(self, \.safeAreaLayoutGuide.topAnchor, constant: layout.defaultInset),
            equal(self, \.leadingAnchor, constant: layout.defaultInset)
        ])
    }
    
    private func setupClearButtonLayout() {
        addSubview(clearButton)
        
        clearButton.addConstraints([
            equal(self, \.safeAreaLayoutGuide.topAnchor, constant: layout.defaultInset),
            equal(self, \.trailingAnchor, constant: -layout.defaultInset)
        ])
    }
    
    private func setupCenterDotViewLayout() {
        addSubview(centerDotView)
        
        centerDotView.addConstraints([
            equal(self, \.centerXAnchor),
            equal(self, \.centerYAnchor)
        ])
    }
    
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
        addButton.addConstraints([
            equal(self, \.centerXAnchor),
            equal(self, \.safeAreaLayoutGuide.bottomAnchor, constant: -(2 * layout.defaultInset))
        ])
    }
    
    private func addIndicatorNode() {
        let geometry = SCNPlane(width: 0.05, height: 0.05)
        let material = SCNMaterial()
        
        material.diffuse.contents = UIImage(named: "icon-plane-indicator")
        indicatorNode.geometry = geometry
        indicatorNode.geometry?.firstMaterial = material
        
        scene.rootNode.addChildNode(indicatorNode)
    }
    
    private func removeIndicatorNode() {
        indicatorNode.removeFromParentNode()
    }
}

// MARK: - Actions

extension MeasurementView {
    @objc
    private func notifyDelegateUndoButtonDidTap() {
        guard let delegate = delegate as? MeasureViewDelegate else {
            return
        }
        
        delegate.measurementViewDidTapUndo(self)
    }
    
    @objc
    private func notifyDelegateClearButtonDidTap() {
        guard let delegate = delegate as? MeasureViewDelegate else {
            return
        }
        
        delegate.measurementViewDidTapClear(self)
    }
    
    @objc
    private func notifyDelegateAddButtonDidTap() {
        guard let delegate = delegate as? MeasureViewDelegate else {
            return
        }

        delegate.measurementViewDidTapAdd(self)
    }
}

// MARK: - Constants

extension MeasurementView {
    private struct LayoutConstants {
        let defaultInset: CGFloat = 16.0
        let clearButtonContentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}

// MARK: Public

extension MeasurementView {
    func runSession() {
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [ .horizontal /*, .vertical */]
        configuration.isLightEstimationEnabled = true
        
        session.run(configuration)
    }

    func pauseSession() {
        session.pause()
    }
}

extension MeasurementView {
    func addChildNode(_ node: SCNNode) {
        scene.rootNode.addChildNode(node)
    }
    
    func updateIndicatorPosition(with alignment: ARPlaneAnchor.Alignment) {
        DispatchQueue.main.async {
            if self.indicatorNode.parent == nil {
               self.addIndicatorNode()
            }

            guard let centerRealWorldPosition = self.realWorldPosition(for: self.center) else {
                self.removeIndicatorNode()
                return
            }
            
            if alignment == .horizontal {
                self.indicatorNode.eulerAngles.x = -.pi / 2
            } else {
                self.indicatorNode.eulerAngles.x = 0
            }
            
            self.indicatorNode.position = centerRealWorldPosition
        }
    }
}
