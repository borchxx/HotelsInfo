//
//  ViewController+ARSCNViewDelegate.swift
//  AugmentedCard
//
//  Created by admin on 3/10/20.
//  Copyright © 2020 admin. All rights reserved.
//

import AVFoundation
import SpriteKit
import UIKit
import SceneKit
import ARKit
import WebKit


extension ViewController: ARSCNViewDelegate {
    
    
   
    
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        updateQueue.async {
   
            let physicalWidth = imageAnchor.referenceImage.physicalSize.width
            let physicalHeight = imageAnchor.referenceImage.physicalSize.height
            
            let mainPlane = SCNPlane(width: physicalWidth, height: physicalHeight)
            mainPlane.firstMaterial?.colorBufferWriteMask = .alpha
            
            // Create a SceneKit root node with the plane geometry to attach to the scene graph
            // This node will hold the virtual UI in place
            let mainNode = SCNNode(geometry: mainPlane)
            mainNode.eulerAngles.x = -.pi / 2
            mainNode.renderingOrder = -1
            mainNode.opacity = 1
            
           
            func createObj(nameObj: String, zPosition: Float){
                
                
                let hotelScene = SCNScene(named: nameObj)!
                let hotelNode = hotelScene.rootNode.childNodes.first!
                hotelNode.position = SCNVector3Zero
                hotelNode.position.z -= zPosition
                mainNode.addChildNode(hotelNode)
                // Add the plane visualization to the scene
                node.addChildNode(mainNode)
            }
            
            
            switch imageAnchor.referenceImage.name{
            case "hiltonTarget":
                self.tempNameOdj = "hiltonTarget"
                createObj(nameObj: "hilton.scn", zPosition: -0.5)
                print(self.tempNameOdj)
            case "mariotTarget":
                self.tempNameOdj = "mariotTarget"
                createObj(nameObj: "marioo.scn", zPosition: -1.5)
                print(self.tempNameOdj)
            case "nightCapTarget":
                self.tempNameOdj = "nightCapTarget"
                createObj(nameObj: "hotel.scn", zPosition: -0.5)
                print(self.tempNameOdj)
            default:
                break
            }

                
            
            // Perform a quick animation to visualize the plane on which the image was detected.
            // We want to let our users know that the app is responding to the tracked image.
                self.highlightDetection(on: mainNode, width: physicalWidth, height: physicalHeight, completionHandler: {
                
//                 Introduce virtual content
                self.displayDetailView(on: mainNode, xOffset: physicalWidth)
                
//                // Animate the WebView to the right
                self.displayWebView(on: mainNode, xOffset: physicalWidth)
//                
                self.displayVideoView(on: mainNode, xOffset: physicalWidth)
                
            })
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - SceneKit Helpers
    
    func displayDetailView(on rootNode: SCNNode, xOffset: CGFloat) {
            
        func createDetailScene(detailNameScene: String){
        let detailPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
        detailPlane.cornerRadius = 0.25
        
        let detailNode = SCNNode(geometry: detailPlane)
        detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: detailNameScene) //"DetailScene"
    
        detailNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        detailNode.position.z -= 0.5
        detailNode.opacity = 0
        
        rootNode.addChildNode(detailNode)
        detailNode.runAction(.sequence([
            .wait(duration: 1.0),
            .fadeOpacity(to: 1.0, duration: 1.5),
            .moveBy(x: xOffset * -1.1, y: 0, z: -0.05, duration: 1.5),
            .moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
            ])
        )
    }
        
        switch tempNameOdj {
             case "hiltonTarget":
                 createDetailScene(detailNameScene: "DetailSceneHilton")
             case "mariotTarget":
               createDetailScene(detailNameScene: "DetailSceneMarriott")
             case "nightCapTarget":
               createDetailScene(detailNameScene: "DetailScene")
             default:
                 break
             }
        
    }
    
    func displayVideoView(on rootNode: SCNNode, xOffset: CGFloat){
        
        
        
        func createDetailScene(detailNameScene: String){
               
         let videoNode = SKVideoNode(fileNamed: detailNameScene)
         
         videoNode.play()
         
         let videoScene = SKScene(size: CGSize(width: 640.0, height: 640.0))
         videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
         videoScene.addChild(videoNode)
         
         let videoPlane = SCNPlane(width: xOffset, height: xOffset)
         videoPlane.cornerRadius = 0.25
         
         
         let videoARNode = SCNNode(geometry: videoPlane)
         videoARNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
         videoARNode.geometry?.firstMaterial?.diffuse.contents = videoScene
         videoARNode.position.z -= 0.5
         videoARNode.opacity = 0
         
         rootNode.addChildNode(videoARNode)
         videoARNode.runAction(.sequence([
             .wait(duration: 2.0),
             .fadeOpacity(to: 1.0, duration: 1.5),
             .moveBy(x: 0, y: 7.0, z: -0.05, duration: 1.5),
             .moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
             ])
         )
    }
        
        switch tempNameOdj {
            case "hiltonTarget":
                createDetailScene(detailNameScene: "video.mp4")
            case "mariotTarget":
                createDetailScene(detailNameScene: "Marriott.mp4")
            case "nightCapTarget":
                createDetailScene(detailNameScene: "Hilton.mp4")
            default:
                break
            }

    }
    
    func displayWebView(on rootNode: SCNNode, xOffset: CGFloat) {
     
        
        func createComment(URL: URLRequest){
            DispatchQueue.main.async {
                let request = URL
                let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 672))
                //let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 672))
                webView.load(request)

                let webViewPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
                webViewPlane.cornerRadius = 0.25

                let webViewNode = SCNNode(geometry: webViewPlane)
                webViewNode.geometry?.firstMaterial?.diffuse.contents = webView
                webViewNode.position.z -= 0.5
                webViewNode.opacity = 0

                rootNode.addChildNode(webViewNode)
                webViewNode.runAction(.sequence([
                    .wait(duration: 3.0),
                    .fadeOpacity(to: 1.0, duration: 1.5),
                    .moveBy(x: xOffset * 1.1, y: 0, z: -0.05, duration: 1.5),
                    .moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
                    ])
                )
            }
        }
        
        switch tempNameOdj {
           case "hiltonTarget":
               createComment(URL:  URLRequest(url: URL(string: "https://www.booking.com/reviews/by/hotel/doubletree-by-hilton-minsk.ru.html")!))
           case "mariotTarget":
               createComment(URL:  URLRequest(url: URL(string: "https://www.booking.com/reviews/by/hotel/minsk-marriott.ru.html")!))
           case "nightCapTarget":
               createComment(URL:  URLRequest(url: URL(string: "https://www.tripadvisor.ru/Hotel_Review-g16718697-d1634305-Reviews-Nightcap_at_Coolaroo_Hotel-Coolaroo_Greater_Melbourne_Victoria.html")!))
           default:
               break
           }


    }
    
    func highlightDetection(on rootNode: SCNNode, width: CGFloat, height: CGFloat, completionHandler block: @escaping (() -> Void)) {
        let planeNode = SCNNode(geometry: SCNPlane(width: width, height: height))
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        planeNode.position.z += 0.1
        planeNode.opacity = 0
        
        rootNode.addChildNode(planeNode)
        planeNode.runAction(self.imageHighlightAction) {
            block()
        }
    }
    
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
