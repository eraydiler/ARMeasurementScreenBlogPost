//
//  ViewController.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 24.05.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private lazy var measurementView = MeasurementView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
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
