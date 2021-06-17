//
//  ProteinVC.swift
//  swifty-protein
//
//  Created by Colin Schmitt on 04/03/2021.
//


import UIKit
import SceneKit
import SwiftUI



struct ProteinVC : UIViewControllerRepresentable {
    
    var pdbFile :String?
    
    var completion : ((Bool,AtomInfo?)->())!
    let proteinVCKit = ProteinVCKit()
    
    func makeUIViewController(context: Context) -> ProteinVCKit {
       
        proteinVCKit.pdbfile = self.pdbFile
        proteinVCKit.completion = self.completion
        return proteinVCKit
    }
    
    func takeScreenShot(view: UIView){
        proteinVCKit.shareAction(view: view)
    }
    
    func updateUIViewController(_ uiViewController: ProteinVCKit, context: Context) {
   
    }
    
    
}

class ProteinVCKit: UIViewController {

    
    var completion:  ((Bool,AtomInfo?)->())!
    
    
    var stackView: UIStackView!
    var randomview : UIView!
    
    var proteinScene: SCNView!
    
    
    var oldNode: SCNNode?
    var oldColor: UIColor?
    
    var pdbfile : String?
    var name : String?
    var atoms: Elements?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.frame(forAlignmentRect:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.view.backgroundColor = UIColor(Color("bg"))

        proteinScene = SCNView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
//        proteinScene.backgroundColor = UIColor(Color("bg"))
        proteinScene.allowsCameraControl = true
        proteinScene.autoenablesDefaultLighting = true
       
        
        proteinScene.scene = ProteinScene(pdbFile: pdbfile!)
        //proteinScene.scene = SCNScene(named: "art.scnassets/ship.scn")
        atoms = getAtomInfo().getInfo()
        
        self.stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        self.stackView.backgroundColor = .red
        
        self.randomview = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        self.randomview.backgroundColor = .purple
        
       
        self.view.addSubview(proteinScene)
//        self.stackView.addSubview(randomview)
//        self.view.addSubview(stackView)
        
//        self.view.addSubview(proteinScene)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: proteinScene)
        let hitList = proteinScene.hitTest(location, options: nil)
        DispatchQueue.main.async {
            if let hitObject = hitList.first {
                if hitObject.node.name != "CONECT" && touches.count == 1 {
                    self.oldNode?.removeAllActions()
                    self.oldNode?.geometry?.firstMaterial?.diffuse.contents = self.oldColor
                    
                    for element in (self.atoms?.elements)!{
                        if (element.symbol?.lowercased() == hitObject.node.name?.lowercased()){
                            self.completion(true,element)
                            //self.initAtomLabels(element: element)
                            self.manageSphereSelection(sphere: hitObject.node)
                        }
                    }
                    
                }
            }
            else if (touches.count > 1) {
               
            }
            else if hitList.isEmpty {
                self.completion(false,nil)
                self.oldNode?.removeAllActions()
                self.oldNode?.geometry?.firstMaterial?.diffuse.contents = self.oldColor
            }
            
        }
       
    }
    
    func shareAction(view: UIView) {
   
        
       UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0.0)
        self.view.drawHierarchy(in: view.frame, afterScreenUpdates: false)
       self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: false)
       let img = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
        
       if let img = img {
           let objectsToShare = [img] as [UIImage]
           let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
           self.present(activityVC, animated: true, completion: nil)
       }
       

   }
    
    
    func manageSphereSelection(sphere: SCNNode){
        let oldColor = sphere.geometry?.firstMaterial?.diffuse.contents as! UIColor
        let newColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)
        let duration: TimeInterval = 0.5
        let act0 = SCNAction.customAction(duration: duration) { (node, elapsedTime) in
            let percentage = elapsedTime / CGFloat(duration)
            node.geometry?.firstMaterial?.diffuse.contents = self.aniColor(from: newColor, to: oldColor, percentage: percentage)
        }
        let act1 = SCNAction.customAction(duration: duration, action: { (node, elapsedTime) in
            let percentage = elapsedTime / CGFloat(duration)
            node.geometry?.firstMaterial?.diffuse.contents = self.aniColor(from: oldColor, to: newColor, percentage: percentage)
        })
        let act = SCNAction.repeatForever(SCNAction.sequence([act0, act1]))
        sphere.runAction(act)
        
        self.oldNode = sphere
        self.oldColor = oldColor
    }
    
    func aniColor(from: UIColor, to: UIColor, percentage: CGFloat) -> UIColor {
        let fromComponents = from.cgColor.components!
        let toComponents = to.cgColor.components!
        
        let color = UIColor(red: fromComponents[0] + (toComponents[0] - fromComponents[0]) * percentage,
                            green: fromComponents[1] + (toComponents[1] - fromComponents[1]) * percentage,
                            blue: fromComponents[2] + (toComponents[2] - fromComponents[2]) * percentage,
                            alpha: fromComponents[3] + (toComponents[3] - fromComponents[3]) * percentage)
        return color
    }
    

    

}


