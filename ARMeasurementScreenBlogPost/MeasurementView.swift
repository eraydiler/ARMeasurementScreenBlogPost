//
//  MeasurementView.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 29.05.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import Foundation
import ARKit

protocol MeasureViewDelegate: ARSCNViewDelegate {
    func measurementViewDidTapCloseButton(_ view: MeasurementView)
    func measurementViewDidTapUndoButton(_ view: MeasurementView)
    func measurementViewDidTapClearButton(_ view: MeasurementView)
    func measurementViewDidTapAddButton(_ view: MeasurementView)
}

final class MeasurementView: ARSCNView {
        
    // MARK: - Properties
    
    private let layout = LayoutConstants()
    
    // MARK: - Subviews
    
    private lazy var undoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon-undo"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setBackgroundImage(UIImage(named: "btn-rectangle-rounded-gray"), for: .normal)
        button.addTarget(self, action: #selector(notifyDelegateUndoButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setBackgroundImage(UIImage(named: "btn-rectangle-rounded-gray"), for: .normal)
        button.addTarget(self, action: #selector(notifyDelegateClearButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var indicatorNode = SCNNode()
    private lazy var centerDotView = UIImageView(image: UIImage(named: "icon-dot"))
    private lazy var addButton: UIButton = {
        let button = UIButton()
        
        button.setBackgroundImage(UIImage(named: "btn-add"), for: .normal)
        button.addTarget(self, action: #selector(notifyDelegateAddButtonDidTap), for: .touchUpInside)

        return button
    }()
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: CGRect.zero, options: [:])
        
        setupScene()
        setListeners()
        prepareLayout()
        runSession()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setupScene() {
        scene = SCNScene()
        showsStatistics = false // Shows fps and timing information
        autoenablesDefaultLighting = true
        debugOptions = [
            ARSCNDebugOptions.showFeaturePoints,
            ARSCNDebugOptions.showWorldOrigin
        ]
    }
    
    private func prepareLayout() {
        setupUndoButtonLayout()
        setupClearButtonLayout()
        setupCenterDotViewLayout()
        setupAddButtonLayout()
    }
    
    private func setListeners() {
    }

    // MARK: - Layout Setup
        
    private func setupUndoButtonLayout() {
        addSubview(undoButton)
        
//        undoButton.snp.makeConstraints { make in
//            make.centerY.equalTo(closeButton)
//            make.left.equalTo(closeButton.snp.right).offset(layout.current.defaultHorizontalInset)
//            make.size.equalTo(layout.current.defaultButtonSize)
//        }
    }
    
    private func setupClearButtonLayout() {
        addSubview(clearButton)
        
//        clearButton.snp.makeConstraints { make in
//            make.centerY.equalTo(undoButton)
//            make.right.equalToSuperview().inset(layout.current.defaultHorizontalInset)
//            make.size.equalTo(layout.current.defaultButtonSize)
//        }
    }
        
    private func setupCenterDotViewLayout() {
        addSubview(centerDotView)
        
//        centerDotView.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }
    }
        
    private func setupAddButtonLayout() {
        addSubview(addButton)
        
//        addButton.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.bottom
//                .equalTo(safeAreaLayoutGuide.snp.bottom)
//                .inset(layout.current.addButtonBottomInset)
//        }
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
            
    // MARK: - Actions
    
    @objc
    private func notifyDelegateCloseButtonDidTap() {
        guard let delegate = delegate as? MeasureViewDelegate else {
            return
        }
        
        delegate.measurementViewDidTapCloseButton(self)
    }
    
    @objc
    private func notifyDelegateUndoButtonDidTap() {
        guard let delegate = delegate as? MeasureViewDelegate else {
            return
        }
        
        delegate.measurementViewDidTapUndoButton(self)
    }
    
    @objc
    private func notifyDelegateClearButtonDidTap() {
        guard let delegate = delegate as? MeasureViewDelegate else {
            return
        }
        
        delegate.measurementViewDidTapClearButton(self)
    }
    
    @objc
    private func notifyDelegateAddButtonDidTap() {
        guard let delegate = delegate as? MeasureViewDelegate else {
            return
        }

        delegate.measurementViewDidTapAddButton(self)
    }
}

// MARK: API - Session

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

// MARK: API - Node addition

extension MeasurementView {
    func addChildNode(_ node: SCNNode) {
        scene.rootNode.addChildNode(node)
    }
}

// MARK: Public

extension MeasurementView {
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

// MARK: - Constants

extension MeasurementView {
    private struct LayoutConstants {
        let closeButtonLeftInset: CGFloat = 5.0
        let stepInfoLabelTopOffset: CGFloat = 20.0
        let closeButtonSize = CGSize(width: 42.0, height: 42.0)
        let undoButtonLeftOffset: CGFloat = 5.0
        let addButtonBottomInset: CGFloat = 20.0
        let tipViewHorizontalInset: CGFloat = 30.0
        let tipViewTopInset: CGFloat = 25.0
        let contentBottomInset: CGFloat = 10.0
        let defaultHorizontalInset: CGFloat = 15.0
        let defaultVerticalInset: CGFloat = 15.0
        let defaultButtonSize = CGSize(width: 72.9, height: 42.0)
    }
}
