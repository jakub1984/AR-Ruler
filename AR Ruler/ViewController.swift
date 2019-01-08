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
    
    @IBOutlet weak var clearLbl: UILabel!
    
    @IBOutlet var sceneView: ARSCNView!
    var markerNodeArray = [SCNNode]()
    var textNode = SCNNode()

    
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
    }
    
    func addMarker(at hitTestResutlt: ARHitTestResult) {
        let marker = SCNCylinder(radius: 0.003, height: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        marker.materials = [material]
        let markerNode = SCNNode(geometry: marker)
        let location = hitTestResutlt.worldTransform.columns.3
        markerNode.position = SCNVector3(location.x, location.y, location.z)
        
        markerNodeArray.append(markerNode)

        if markerNodeArray.count != 3 {
            sceneView.scene.rootNode.addChildNode(markerNode)
        }

        
        if markerNodeArray.count == 1 {
            clearLbl.text = "Tap again to calculate distance"
        }
        
        if markerNodeArray.count > 2 {
            markerNodeArray[0].removeFromParentNode()
            markerNodeArray[1].removeFromParentNode()
            markerNodeArray.removeAll()
            textNode.removeFromParentNode()
            clearLbl.text = "Tap to start measuring"

        }
        
        if markerNodeArray.count == 2 {
            calculateDistance()
            clearLbl.text = "Tap to clear measurement"

        }
        
    }
    
    func calculateDistance () {
        let start = markerNodeArray[0]
        let end = markerNodeArray[1]
        
        
        let pointA = SCNVector3ToGLKVector3(start.worldPosition)
        let pointB = SCNVector3ToGLKVector3(end.worldPosition)
       
        let distance = GLKVector3Distance(pointA, pointB)
        print(distance)
        
        let sum = GLKVector3Add(pointA, pointB)
        let midDistance = SCNVector3(sum.x/2, sum.y/2, sum.z/2)
        let distanceInCm = metersToCentimeters(meters: distance)
        
        addText(text: distanceInCm, location: midDistance)
        
    }
    
    func addText(text: String, location: SCNVector3){
        let distanceText = SCNText(string: text, extrusionDepth: 0.3)
        distanceText.font = UIFont(name: "futura", size: 16)
        distanceText.flatness = 0.0
        let scaleFactor = 0.025 / distanceText.font.pointSize
        textNode.geometry = distanceText
        textNode.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
//        must come AFTER the "scale"
        let (min, max) = textNode.boundingBox
        let offset = (max.x - min.x) / 2 * Float(scaleFactor)
        let textPosition = SCNVector3(location.x - offset,location.y + 0.03, location.z)
        textNode.position = textPosition
        let billboardContstraint = SCNBillboardConstraint()
//        if you want to rotate only around one axis
//        billboardContstraint.freeAxes = .Y
        textNode.constraints = [billboardContstraint]
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func metersToCentimeters(meters: Float) -> String {
        let m = Measurement(value: Double(meters), unit: UnitLength.meters)
        let centimeters = m.converted(to: .centimeters)
        let centimetersString = String(format: "%.1f cm", centimeters.value)
        return centimetersString
    }
    
    
}
