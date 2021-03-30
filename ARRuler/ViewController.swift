//
//  ViewController.swift
//  ARRuler
//
//  Created by John Ellie Go on 3/30/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotaNodes = [SCNNode]()
    
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
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
        if dotaNodes.count >= 2 {
            dotaNodes.forEach { (node) in
                node.removeFromParentNode()
            }
            
            dotaNodes.removeAll()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) else {
               return
            }
            
            let results = sceneView.session.raycast(query)
            
            if let hitResult = results.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARRaycastResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        let columns = hitResult.worldTransform.columns.3
        
        dotNode.position = SCNVector3(x: columns.x, y: columns.y, z: columns.z)
        
        dotaNodes.append(dotNode)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        if dotaNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotaNodes[0]
        let end = dotaNodes[1]
        
        let x = end.position.x - start.position.x
        let y = end.position.y - start.position.y
        let z = end.position.z - start.position.z
        
        let distance = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
        
        updateText(text: "\(abs(distance))", at: end.position)
    }
    
    func updateText(text: String, at position: SCNVector3) {
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.1, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
}
