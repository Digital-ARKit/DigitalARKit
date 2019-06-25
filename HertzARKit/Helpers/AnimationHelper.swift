//
//  AnimationHelper.swift
//  HertzARKit
//
//  Created by Vivekanandhan Sundarrajan on 4/19/19.
//  Copyright © 2019 Vivekanandhan Sundarrajan. All rights reserved.
//

import UIKit
import ARKit
import Lottie

struct lottieAnimations {
    static let loveExplosion = "love_explosion"
    static let loader = "loader"
    static let confetti = "confetti"
    static let heart = "heart"
    static let rolConnecting = "ROL_Connecting"
}

class AnimationHelper: NSObject {
    
    static func displayLottieAnimation(referenceImage: ARReferenceImage, node: SCNNode, animation: String) {
        DispatchQueue.main.async {
            // Create Lottie view
            let animationView = AnimationView(name: animation)
            //            animationView.loopAnimation = true
            animationView.play()
            animationView.backgroundColor = .clear
            
            // Create a plane to visualize the initial position of the detected image.
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = animationView
            let animationNode = SCNNode(geometry: plane)
            animationNode.eulerAngles.x = -.pi / 2
            node.addChildNode(animationNode)
        }
    }
    
}
