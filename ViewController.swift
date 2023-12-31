//
//  ViewController.swift
//  ARDicee
//
//  Created by Eren lifetime on 30.10.2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var diceArray = [SCNNode]()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation,types:.existingPlaneUsingExtent)
            if let hitResult = results.first{
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
    if let diceNode = diceScene.rootNode.childNode(withName:"Dice",recursively:true){
                    diceNode.position = SCNVector3(
    x: hitResult.worldTransform.columns.3.x,
    y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
    z: hitResult.worldTransform.columns.3.z
    )
     
        roll(dice:diceNode)
                }
            }
        }
    }
    func rollAll(){
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(dice:dice)
            }
        }
    }
    func roll(dice:SCNNode){
        diceArray.append(dice)
        sceneView.scene.rootNode.addChildNode(dice)
        let randomX = Float(arc4random_uniform(4) + 1)*(Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1)*(Float.pi/2)
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX * 5), y:0 , z:CGFloat(randomZ * 5),duration:0.5)
        )
    }
    // IBAction func rollAgain(_ sender:UIBarButtonItem){}
    // override func motionEnded(_ sender:UIEvenSubType,with event:UIEvent?)
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor){
        if anchor is ARPlaneAnchor{
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width:CGFloat(planeAnchor.extent.x),height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x,y:0 , z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
        }else{
            return
            //        }
        }
        
    }
}
