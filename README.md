# HertzARKit

ARKit Image Recognition

Overview

Augmented reality (AR) describes user experiences that add 2D or 3D elements to the live view from a device's camera, in a way that makes those elements appear to inhabit the real world. ARKit combines device motion tracking, camera scene capture, advanced scene processing, and display conveniences to simplify the task of building an AR experience. You can use these technologies to create many kinds of AR experiences, using either the back camera or front camera of an iOS device.

Prerequisites
•	XCode 10.2 or higher
•	Swift 4.2 or higher 
•	iPhone 6S or above iDevice.
Building Image Detection

This example generates static AR content, image recognition could also be used as an input mechanism to trigger functionality in an app. 

Topics 
1.	Create project
2.	Provide reference images
3.	Configuration image tracking 
4.	Image Detection
5.	Load and animate Spritekit 

Creating project
First open XCode, choose the ARKit project template:
 

I.	Enabling the ARKit Framework
II.	Provide reference Images 
To provide images references, we need to add the images to the project asset catalog in XCode.  
a.	Open asset catalog in project, click left corner (+) or you can use right click to add new AR Resource folder group.
b.	Drag the images from finder to newly created folder
c.	For all individual images we need to set dimensions using inspector.
  
 
III.	Created UIViewController and global objects.
I.	@IBOutlet var sceneView: ARSCNView!

/// Convenience accessor for the session owned by ARSCNView.
II.	var session: ARSession {
	        		return sceneView.session
}

IV.	Confirmed the ARSCNView delegate and session creation on ViewDidLoad()
  
      // Setup sceneView
      sceneView.delegate = self
      sceneView.session.delegate = self
 

III.	Configuration Image Tracking 
a.	Need to create ARImageTrackingConfiguration, this will allow to track our reference images in the user’s environment. After that, create an instance of ARReferenceImage containing the reference of images from the AR Resource.  The property referenceImages will set the maximum number of tracked images in given frame, default value is one.
b.	After instantiating the ARImageTrackingConfiguration instance, assign the reference Images to the tracking images property.
// Obtain images to recognize
        
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: Constants.ARResources,
                                                                     bundle: nil) else {
                                                                        fatalError("Missing expected asset catalog resources.")
        }

// Create a session configuration
                      let configuration = ARImageTrackingConfiguration()
         configuration.trackingImages = referenceImages
         configuration.maximumNumberOfTrackedImages = 1
 
            // Start the image detection
            session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
 
IV.	Image Detection results
a.	When the reference images in found, it will trigger renderer function as below:
func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        /// Casting down ARAnchor to `ARImageAnchor`.
        if let imageAnchor =  anchor as? ARImageAnchor {
            let imageSize = imageAnchor.referenceImage.physicalSize
        } else {
            print("Error: Failed to get ARImageAnchor")
        }
}

V.	Load and animate Spritekit scene
a.	Find the detection image size and display the video based on the detected image location
     guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage

            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            let videoNode = SKVideoNode(fileNamed: "Fire.mp4")
            videoNode.play()

b.	 we need to create an object of SCNPlane which contains firstMaterial property and its sub properties. Thus pass the object aboutSpriteKitScene to aboutUsPlane.firstMaterial?.diffuse.contents to load the SpriteKitScene

            let skScene = SKScene(size: CGSize(width: 1000, height: 1000))
            skScene.addChild(videoNode)
            videoNode.position = CGPoint(x: skScene.size.width/2.0, y: skScene.size.height/2.0)
            videoNode.size = skScene.size
            plane.firstMaterial?.diffuse.contents = skScene
            plane.firstMaterial?.isDoubleSided = true
            planeNode.eulerAngles.x = .pi / 2
            node.addChildNode(planeNode)


Video Link: https://www.youtube.com/watch?v=D5xVy_PHWG8

