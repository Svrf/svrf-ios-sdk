//
//  SvrfFaceFilter.swift
//  SvrfSDK
//
//  Created by Jesse Boyes on 6/11/19.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

import Foundation
import ARKit
import SvrfGLTFSceneKit

/**
 Contains the face filter *SCNNode*, ability to manage face filter animations, and 2D scene overlays.
*/
public class SvrfFaceFilter: NSObject, GLTFAnimationManager {

    /**
     When set to *true* (default), face filter animations are repeated indefinitely.

     - Note: If set to *false* while an animation is playing, animation will play through to completion.
    */
    public var looping: Bool = true

    /**
     Whether animations should play. Set to *false* to pause the animation.
     */
    public var animating: Bool = true {
        didSet {
            for (_, node) in animations {
                node.isPaused = !animating
            }
        }
    }

    /**
     2D face filter overlay included with this *SvrfFaceFilter*. Some filters provide a 2D component to be overlaid on
     the *SCNScene*.
     
     - Example:
     
     Set this as your scene's *overlaySKScene*:
     
     ```swift
     sceneView.overlaySKScene = faceFilter.sceneOverlay
     sceneView.overlaySKScene?.size = sceneView.bounds.size
     ```
     */
    public var sceneOverlay: SvrfSceneOverlay?

    /**
     Root node for the face filter.
     */
    public var node: SCNNode?

    private var animations: [(CAAnimation, SCNNode)] = []

    /**
     Blend shape mapping allows Svrf's ARKit compatible face filters to have animations that
     are activated by your user's facial expressions.

     - Attention: This method enumerates through the node's hierarchy. Any children nodes with morph targets that follow
     the [ARKit blend shape naming](https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation)
     will be affected.
     - Note: The 3D animation terms "blend shapes", "morph targets", and "pose morphs" are often used interchangeably.
     - Parameters:
        - blendShapes: A dictionary of *ARFaceAnchor* blend shape locations and weights.
     */
    public func setBlendShapes(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {

        DispatchQueue.main.async {
            if let faceNode = self.node {
                faceNode.enumerateHierarchy({ (node, _) in
                    if node.morpher?.targets != nil {
                        node.enumerateHierarchy { (childNode, _) in
                            for (blendShape, weight) in blendShapes {
                                let targetName = blendShape.rawValue
                                childNode.morpher?.setWeight(CGFloat(weight.floatValue), forTargetNamed: targetName)
                            }
                        }
                    }
                })
            }
        }
    }

    // MARK: - GLTFAnimationManager

    public func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        // Find the node for this animation and restart it if we're still looping
        if (looping) {
            for (anim, node) in animations {
                if (animation == anim) {
                    node.addAnimation(animation, forKey: nil)
                    break
                }
            }

        }
    }

    public func addAnimation(_ animation: CAAnimation, node: SCNNode) {
        animations.append((animation, node))
    }

}
