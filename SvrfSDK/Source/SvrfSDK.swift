//
//  SvrfSDK.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 12/11/2018.
//  Copyright © 2018 SVRF, Inc. All rights reserved.
//

import Foundation
import SVRFClientSwift
import SvrfGLTFSceneKit
import Analytics
import SceneKit
import ARKit

public typealias SvrfMedia = Media

private enum ChildNode: String {
    case Head = "Head"
    case Occluder = "Occluder"
}

public class SvrfSDK: NSObject {
    
    private static let svrfApiKeyKey = "SVRF_API_KEY"
    private static let svrfXAppTokenKey = "x-app-token"
    private static let svrfAuthTokenKey = "SVRF_AUTH_TOKEN"
    private static let svrfAuthTokenExpireDateKey = "SVRF_AUTH_TOKEN_EXPIRE_DATE"
    private static let svrfAnalyticsKey = "J2bIzgOhVGqDQ9ZNqVgborNthH6bpKoA"
    
    private static let dispatchGroup = DispatchGroup()
    
    // MARK: public functions
    /**
     Authenticate your API Key with the Svrf API.
     
     - parameters:
       - onSuccess: Success closure.
       - onFailure: Failure closure.
       - error: Error message.
    */
    public static func authenticate(onSuccess success: @escaping () -> Void, onFailure failure: @escaping (_ error: SvrfError) -> Void) {
        
        dispatchGroup.enter()
        
        setupAnalytics()
        
        if !needUpdateToken() {
            if let authToken = UserDefaults.standard.string(forKey: svrfAuthTokenKey) {
                SVRFClientSwiftAPI.customHeaders = [svrfXAppTokenKey: authToken]
                print(SvrfSuccess.Auth.rawValue)
                success()
                dispatchGroup.leave()
                
                return
            }
            
            failure(SvrfError.AuthResponse)
            dispatchGroup.leave()
        } else if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path), let apiKey = dict[svrfApiKeyKey] as? String {
            
            let body = Body(apiKey: apiKey)
            AuthenticateAPI.authenticate(body: body) { (authResponse, error) in
                
                if error != nil {
                    print(SvrfError.AuthResponse.rawValue)
                    failure(SvrfError.AuthResponse)
                    dispatchGroup.leave()
                    
                    return
                }
                
                if let authToken = authResponse?.token, let expireIn = authResponse?.expiresIn {
                    UserDefaults.standard.set(authToken, forKey: svrfAuthTokenKey)
                    UserDefaults.standard.set(getTokenExpireDate(expireIn: expireIn), forKey: svrfAuthTokenExpireDateKey)
                    
                    SVRFClientSwiftAPI.customHeaders = [svrfXAppTokenKey: authToken]
                    
                    print(SvrfSuccess.Auth.rawValue)
                    success()
                    dispatchGroup.leave()
                    
                    return
                }
                
                print(SvrfError.AuthResponse.rawValue)
                failure(SvrfError.AuthResponse)
                dispatchGroup.leave()
            }
        } else {
            print(SvrfError.ApiKey.rawValue)
            failure(SvrfError.ApiKey)
            dispatchGroup.leave()
        }
    }
    
    /**
     The Svrf Search Endpoint brings the power of immersive search found on [Svrf.com](https://www.svrf.com) to your app or project. Svrf's search engine enables your users to instantly find the immersive experience they're seeking. Content is sorted by the Svrf rating system, ensuring that the highest quality content and most prevalent search results are returned.
     
     - parameters:
       - query: Url-encoded search query.
       - type: The type(s) of *Media* to be returned (comma separated).
       - stereoscopicType: Search only for *Media* with a particular stereoscopic type.
       - category: Search only for *Media* with a particular category.
       - size: The number of results to return per-page, from 1 to 100.
       - pageNum: Pagination control to fetch the next page of results, if applicable.
       - onSuccess: Success closure.
       - mediaArray: An array of *Media* from the Svrf API.
       - onFailure: Error closure.
       - error: Error message.
     */
    public static func search(query: String,
                              type: [MediaType]?,
                              stereoscopicType: String?,
                              category: String?,
                              size: Int?,
                              pageNum: Int?,
                              onSuccess success: @escaping (_ mediaArray: [Media]) -> Void,
                              onFailure failure: @escaping (_ error: SvrfError) -> Void) {
        
        dispatchGroup.notify(queue: .main) {
            
            MediaAPI.search(q: query, type: type, stereoscopicType: stereoscopicType, category: category, size: size, pageNum: pageNum) { (searchMediaResponse, error) in
                
                if let _ = error {
                    print(SvrfError.SearchResponse.rawValue)
                    failure(SvrfError.SearchResponse)
                } else {
                    if let mediaArray = searchMediaResponse?.media {
                        print(SvrfSuccess.Search.rawValue)
                        success(mediaArray)
                    } else {
                        print(SvrfError.SearchResponse.rawValue)
                        failure(SvrfError.SearchResponse)
                    }
                }
            }
        }
    }
    
    /**
     The Svrf Trending Endpoint provides your app or project with the hottest immersive content curated by real humans. The experiences returned mirror the [Svrf homepage](https://www.svrf.com), from timely cultural content to trending pop-culture references. The trending experiences are updated regularly to ensure users always get fresh updates of immersive content.
     
     - parameters:
       - type: The type(s) of *Media* to be returned (comma separated).
       - stereoscopicType: Search only for *Media* with a particular stereoscopic type.
       - category: Search only for *Media* with a particular category.
       - size: The number of results to return per-page, from 1 to 100.
       - nextPageCursor: Pass this cursor ID to get the next page of results.
       - onSuccess: Success closure.
       - mediaArray: An array of *Media* from the Svrf API.
       - onFailure: Error closure.
       - error: Error message.
     */
    public static func getTrending(type: [MediaType]?,
                                   stereoscopicType: String?,
                                   category: String?,
                                   size: Int?,
                                   nextPageCursor: String?,
                                   onSuccess success: @escaping (_ mediaArray: [Media]) -> Void,
                                   onFailure failure: @escaping (_ error: SvrfError) -> Void) {
        
        dispatchGroup.notify(queue: .main) {
            
            MediaAPI.getTrending(type: type, stereoscopicType: stereoscopicType, category: category, size: size, nextPageCursor: nextPageCursor, completion: { (trendingResponse, error) in
                
                if let _ = error {
                    print(SvrfError.TrendingResponse.rawValue)
                    failure(SvrfError.TrendingResponse)
                } else {
                    if let mediaArray = trendingResponse?.media {
                        print(SvrfSuccess.GetTrending.rawValue)
                        success(mediaArray)
                    } else {
                        print(SvrfError.TrendingResponse.rawValue)
                        failure(SvrfError.TrendingResponse)
                    }
                }
            })
        }
    }
    
    /**
     Fetch SVRF media by its ID.
     
     - parameters:
       - id: ID of *Media* to fetch.
       - onSuccess: Success closure.
       - media: *Media* from the Svrf API.
       - onFailure: Error closure.
       - error: Error message.
     */
    public static func getMedia(id: String, onSuccess success: @escaping (_ media: Media) -> Void, onFailure failure: @escaping (_ error: SvrfError) -> Void) {
        
        dispatchGroup.notify(queue: .main) {
            
            MediaAPI.getById(id: id, completion: { (singleMediaResponse, error) in
                
                if let _ = error {
                    print(SvrfError.MediaResponse.rawValue)
                    failure(SvrfError.MediaResponse)
                } else {
                    if let media = singleMediaResponse?.media {
                        print(SvrfSuccess.GetMedia.rawValue)
                        success(media)
                    } else {
                        print(SvrfError.MediaResponse.rawValue)
                        failure(SvrfError.MediaResponse)
                    }
                }
            })
        }
    }
    
    /**
     Generates a *SCNNode* for a *Media* with a *type* `_3d`. This method can used to generate the whole 3D model, but is not recommended for face filters.
     
     - attention: Face filters should be retrieved using the `getFaceFilter` method.
     - parameters:
       - media: The *Media* to generate the *SCNNode* from. The *type* must be `_3d`.
     - returns: SCNNode?
     */
    public static func getNodeFromMedia(media: Media) -> SCNNode? {
        
        if let scene = getSceneFromMedia(media: media) {
            return scene.rootNode
        }
        
        print(SvrfError.GetNode.rawValue)
        return nil
    }
    
    /**
     Blend shape mapping allows SVRF's ARKit compatible face filters to have animations that are activated by your user's facial expressions.
     
     - Attention: This method enumerates through the node's hierarchy. Any children nodes with morpher targets that follow the [ARKit blend shape naming conventions](https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation) will be affected.
     - Note: The 3D animation terms "blend shapes", "morph targets", and "pose morphs" are often used interchangably.
     - parameters:
       - blendShapes: A dictionary of *ARFaceAnchor* blend shape locations and weights.
       - for: The node with morpher targets.
     */
    public static func setBlendShapes(blendShapes: [ARFaceAnchor.BlendShapeLocation : NSNumber], for node: SCNNode) {
        
        node.enumerateHierarchy { (childNode, _) in
            
            for (blendShape, weight) in blendShapes {
                let targetName = blendShape.rawValue
                node.morpher?.setWeight(CGFloat(weight.floatValue), forTargetNamed: targetName)
            }
        }
    }
    
    /**
     The SVRF API allows you to access all of SVRF's ARKit compatible face filters and stream them directly to your app. Use the `getFaceFilter` method to stream a face filter to your app and convert it into a *SCNNode* in runtime.
     
     - parameters:
       - with: The device to fetch the face geometry from.
       - media: The *Media* to generate the face filter from. The *type* must be `_3d`.
     - returns: SCNNode
     */
    public static func getFaceFilter(with device: MTLDevice, media: Media) -> SCNNode {
        
        let faceFilter = SCNNode()
        
        if media.type == ._3d, let glbUrlString = media.files?.glb, let glbUrl = URL(string: glbUrlString) {
            let modelSource = GLTFSceneSource(url: glbUrl)
            
            do {
                let node = try modelSource.scene().rootNode
                
                if let occluderNode = node.childNode(withName: ChildNode.Occluder.rawValue, recursively: true) {
                    faceFilter.addChildNode(occluderNode)
                    
                    let faceGeometry = ARSCNFaceGeometry(device: device)
                    faceFilter.geometry = faceGeometry
                    faceFilter.geometry?.firstMaterial?.colorBufferWriteMask = []
                    faceFilter.renderingOrder = -1
                }
                
                if let headNode = node.childNode(withName: ChildNode.Head.rawValue, recursively: true) {
                    faceFilter.addChildNode(headNode)
                }
                
                faceFilter.morpher?.calculationMode = SCNMorpherCalculationMode.normalized
                
                SEGAnalytics.shared().track("Face Filter Node Requested", properties: ["media_id" : media.id ?? "unknown"])
            } catch {
                print(SvrfError.CreateScene)
            }
        }
        
        return faceFilter
    }
    
    // MARK: private functions
    /**
     Renders a *SCNScene* from a *Media*'s glb file using *SvrfGLTFSceneKit*.

     - parameters:
        - media: The *Media* to return a *SCNScene* from.
     - returns: SCNScene?
     */
    private static func getSceneFromMedia(media: Media) -> SCNScene? {
        
        if let glbUrlString = media.files?.glb {
            if let glbUrl = URL(string: glbUrlString) {
                
                let modelSource = GLTFSceneSource(url: glbUrl)
                
                do {
                    let scene = try modelSource.scene()
                    return scene
                } catch {
                    print(SvrfError.GetScene.rawValue)
                }
            }
        }
        
        print(SvrfError.GetScene.rawValue)
        
        return nil
    }
    
    /**
     Checks if the Svrf authentication token has expired.

     - returns: Bool
     */
    private static func needUpdateToken() -> Bool {
        
        if let tokenExpirationDate = UserDefaults.standard.object(forKey: svrfAuthTokenExpireDateKey) as? Date {
            
            let twoDays = 172800
            if Int(Date().timeIntervalSince(tokenExpirationDate)) < twoDays {
                return false
            }
        }
        
        return true
    }
    
    /**
     Takes the `expireIn` value returned by the Svrf authentication endpoint and returns the expiration date.

     - parameters:
       - expireIn: The time until token expiration in seconds.
     - returns: Date
     */
    private static func getTokenExpireDate(expireIn: Int) -> Date {
        
        guard let timeInterval = TimeInterval(exactly: expireIn) else {
            return Date()
        }
        
        return Date().addingTimeInterval(timeInterval)
    }
    
    /**
     Setup Segment analytic event tracking.
     */
    private static func setupAnalytics() {
        
        let configuration = SEGAnalyticsConfiguration(writeKey: svrfAnalyticsKey)
        configuration.trackApplicationLifecycleEvents = true
        configuration.recordScreenViews = false
        
        SEGAnalytics.setup(with: configuration)
        
        if let authToken = UserDefaults.standard.string(forKey: svrfAuthTokenKey) {
            
            let body = SvrfJWTDecoder.decode(jwtToken: authToken)
            if let appId = body["appId"] as? String {
                SEGAnalytics.shared().identify(appId)
            }
            
        }
    }
}
