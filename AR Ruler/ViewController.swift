//
//  ViewController.swift
//  AR Ruler
//
//  Created by Jakub Perich on 08/01/2019.
//  Copyright © 2019 Jakub Perich. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var markerNodeArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: sceneView) else {return}
        guard let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint).first else {return}
        addMarker(at: hitTestResult)
        print(markerNodeArray.count)
    }
    
    func addMarker(at hitTestResutlt: ARHitTestResult) {
        let marker = SCNCylinder(radius: 0.003, height: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        marker.materials = [material]
        let markerNode = SCNNode(geometry: marker)
        let location = hitTestResutlt.worldTransform.columns.3
        markerNode.position = SCNVector3(location.x, location.y, location.z)
        
        markerNodeArray.append(markerNode)

        if markerNodeArray.count != 3 {
            sceneView.scene.rootNode.addChildNode(markerNode)
        }
        
        if markerNodeArray.count > 2 {
            markerNodeArray[0].removeFromParentNode()
            markerNodeArray[1].removeFromParentNode()
            markerNodeArray.removeAll()
        }
        
    }
    
    
}
