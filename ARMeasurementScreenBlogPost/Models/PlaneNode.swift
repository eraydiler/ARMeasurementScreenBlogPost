//
//  PlaneNode.swift
//  ARMeasurementScreenBlogPost
//
//  Created by Eray Diler on 8.06.2020.
//  Copyright © 2020 Hippo Foundry. All rights reserved.
//

import Foundation
import ARKit

// Convenience extension for colors
extension UIColor {
    static let planeColor = UIColor.yellow
}

class PlaneNode: SCNNode {
    let meshNode: SCNNode
    let extentNode: SCNNode
    
    /// - Tag: VisualizePlane
    init(anchor: ARPlaneAnchor, in sceneView: ARSCNView) {
        
        // Create a mesh to visualize the estimated shape of the plane.
        guard
            let device = sceneView.device,
            let meshGeometry = ARSCNPlaneGeometry(device: device)
            else {
                fatalError("Can't create plane geometry")
        }
        
        meshGeometry.update(from: anchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)
        
        // Create a node to visualize the plane's bounding rectangle.
        let extentPlane: SCNPlane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        extentNode = SCNNode(geometry: extentPlane)
        extentNode.simdPosition = anchor.center
        
        // `SCNPlane` is vertically oriented in its local coordinate space, so
        // rotate it to match the orientation of `ARPlaneAnchor`.
        extentNode.eulerAngles.x = -.pi / 2

        super.init()

        self.setupMeshVisualStyle()
        self.setupExtentVisualStyle()

        // Add the plane extent and plane geometry as child nodes so they appear in the scene.
        addChildNode(meshNode)
        addChildNode(extentNode)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMeshVisualStyle() {
        // Make the plane visualization semitransparent to clearly show real-world placement.
        meshNode.opacity = 0.25
        
        // Use color and blend mode to make planes stand out.
        guard let material = meshNode.geometry?.firstMaterial else {
            fatalError("ARSCNPlaneGeometry always has one material")
        }
        
        material.diffuse.contents = UIColor.planeColor
    }
    
    private func setupExtentVisualStyle() {
        // Make the extent visualization semitransparent to clearly show real-world placement.
        extentNode.opacity = 0.6

        guard let material = extentNode.geometry?.firstMaterial else {
            fatalError("SCNPlane always has one material")
        }
        
        material.diffuse.contents = UIColor.planeColor

        // Use a SceneKit shader modifier to render only the borders of the plane.
        guard let path = Bundle.main.path(forResource: "wireframe_shader", ofType: "metal", inDirectory: "Assets.scnassets") else {
            fatalError("Can't find wireframe shader")
        }
        do {
            let shader = try String(contentsOfFile: path, encoding: .utf8)
            material.shaderModifiers = [.surface: shader]
        } catch {
            fatalError("Can't load wireframe shader: \(error)")
        }
    }
}

extension SCNNode {
    func centerAlign() {
        let (min, max) = boundingBox
        let extents = SIMD3<Float>(max) - SIMD3<Float>(min)
        simdPivot = float4x4(translation: ((extents / 2) + SIMD3<Float>(min)))
    }
}

extension float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(vector.x, vector.y, vector.z, 1)
        )
    }
}
