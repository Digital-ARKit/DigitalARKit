//
//  ViewController.swift
//  HertzARKit
//
//  Created by Vivekanandhan Sundarrajan on 4/18/19.
//  Copyright © 2019 Vivekanandhan Sundarrajan. All rights reserved.
//

import ARKit
import SceneKit
import UIKit
import PopupDialog

struct referenceImages {
    static let hertz = "Temp1_1"
    static let hertz_logo1 = "Hertz_logo5"
    static let hertz_logo2 = "Hertz_logo6"
    static let hertz_logo3 = "Hertz_logo3"
    static let hertz_logo4 = "Hertz_logo4"
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    private struct Constants {
        static let ARResources = "AR Resources"
    }
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIVisualEffectView!
   
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    

    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup sceneView
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the AR experience
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
    }
    
    // MARK: - Session management (Image detection setup)
    
    var isRestartAvailable = true
    
    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
    func resetTracking() {
        
        // Obtain images to recognize
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: Constants.ARResources,
                                                                     bundle: nil) else {
                                                                        fatalError("Missing expected asset catalog resources.")
        }
        
        // Setup ARSession configuration
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
//        configuration.detectionImages = referenceImages
        
        // Start the image detection
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        // Remove all nodes from the scene
        removeAllNodes()
        
        // Show look around to detect images message
        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
    }
    
    // MARK: - Remove all nodes from ARSCNView
    
    func removeAllNodes() {
        // Remove all nodes from the scene
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
    }
    
    // MARK: - ARSCNViewDelegate (Image detection results)
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            let referenceImage = imageAnchor.referenceImage
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.25
            planeNode.eulerAngles.x = -.pi / 2
            
            planeNode.runAction(self.imageHighlightAction, completionHandler: {
                if referenceImage.name == referenceImages.hertz_logo1 || referenceImage.name == referenceImages.hertz || referenceImage.name == referenceImages.hertz_logo2 || referenceImage.name == referenceImages.hertz_logo3 || referenceImage.name == referenceImages.hertz_logo4 {

                    VideoHelper.displayVideo(referenceImage: referenceImage,
                                             node: node,
                                             video: videos.fire,
                                             videoExtension: videoExtension.mp4)
                }
                self.showPopup()
            })
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
            
            // Detected Image Message
            showDetectedImageMessage(referenceImage: referenceImage)
        }
    }
    
    // Popup
    
    func showPopup() {
        let popupAlert = UIAlertController(title: "Please use the PROMO code for 10% discount", message: "PROMO1234$", preferredStyle: UIAlertController.Style.alert)
        let subview = popupAlert.view.subviews.first! as UIView
        let alertContentView = subview.subviews.first! as UIView
        alertContentView.backgroundColor = UIColor.clear
        popupAlert.view.backgroundColor = UIColor.clear
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
            self.resetTracking()
        }
        
        popupAlert.addAction(okAction)
        popupAlert.view.alpha = 0
        self.present(popupAlert, animated: true) {
            switch UIDevice.current.orientation {
            case .landscapeLeft:
                popupAlert.view.transform=CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            case .landscapeRight:
                popupAlert.view.transform=CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
            default:
                popupAlert.view.transform=CGAffineTransform.identity
            }
            
            popupAlert.view.alpha = 1
        }
    }
    
    
    // MARK : - Detected Image Message
    
    func showDetectedImageMessage(referenceImage: ARReferenceImage) {
        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }
    
    // MARK: - Image Highlight
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }
}


