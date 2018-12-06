//
//  SvrfSDK.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 12/11/2018.
//  Copyright © 2018 Svrf, Inc. All rights reserved.
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
    
    //MARK: public functions
    public static func authenticate(onSuccess success: @escaping () -> Void, onFailure failure: @escaping (_ error: SvrfError) -> Void) {
        
        dispatchGroup.enter()
        
        setupAnalytics()
        
        if !needUpdateToken() {
            let authToken = UserDefaults.standard.string(forKey: svrfAuthTokenKey)!
            SVRFClientSwiftAPI.customHeaders = [svrfXAppTokenKey: authToken]
            success()
            dispatchGroup.leave()
            
            return
        } else if let path = Bundle.main.path(forResource: "Info", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path), let apiKey = dict[svrfApiKeyKey] as? String {
            
            let body = Body(apiKey: apiKey)
            AuthenticateAPI.authenticate(body: body) { (authResponse, error) in
                
                if error != nil {
                    failure(SvrfError(title: SvrfErrorTitle.Auth.Response.rawValue, description: error?.localizedDescription))
                    dispatchGroup.leave()
                    
                    return
                }
                
                if let authToken = authResponse?.token, let expireIn = authResponse?.expiresIn {
                    UserDefaults.standard.set(authToken, forKey: svrfAuthTokenKey)
                    UserDefaults.standard.set(getTokenExpireDate(expireIn: expireIn), forKey: svrfAuthTokenExpireDateKey)
                    
                    SVRFClientSwiftAPI.customHeaders = [svrfXAppTokenKey: authToken]
                    
                    success()
                    dispatchGroup.leave()
                    
                    return
                } else {
                    failure(SvrfError(title: SvrfErrorTitle.Auth.ResponseNoToken.rawValue, description: nil))
                    dispatchGroup.leave()
                    
                    return
                }
            }
        } else {
            failure(SvrfError(title: SvrfErrorTitle.Auth.ApiKey.rawValue, description: nil))
            dispatchGroup.leave()
        }
    }
    
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
                
                if let error = error {
                    failure(SvrfError(title: SvrfErrorTitle.Search.Response.rawValue, description: error.localizedDescription))
                } else {
                    if let mediaArray = searchMediaResponse?.media {
                        success(mediaArray)
                    } else {
                        failure(SvrfError(title: SvrfErrorTitle.Search.ResponseNoMediaArray.rawValue, description: nil))
                    }
                }
            }
        }
    }
    
    public static func getTrending(type: [MediaType]?,
                                   stereoscopicType: String?,
                                   category: String?,
                                   size: Int?,
                                   nextPageCursor: String?,
                                   onSuccess success: @escaping (_ mediaArray: [Media]) -> Void,
                                   onFailure failure: @escaping (_ error: SvrfError) -> Void) {
        
        dispatchGroup.notify(queue: .main) {
            
            MediaAPI.getTrending(type: type, stereoscopicType: stereoscopicType, category: category, size: size, nextPageCursor: nextPageCursor, completion: { (trendingResponse, error) in
                
                if let error = error {
                    failure(SvrfError(title: SvrfErrorTitle.Trending.Response.rawValue, description: error.localizedDescription))
                } else {
                    if let mediaArray = trendingResponse?.media {
                        success(mediaArray)
                    } else {
                        failure(SvrfError(title: SvrfErrorTitle.Trending.ResponseNoMediaArray.rawValue, description: ""))
                    }
                }
            })
        }
    }
    
    public static func getMedia(id: String, onSuccess success: @escaping (_ media: Media) -> Void, onFailure failure: @escaping (_ error: SvrfError) -> Void) {
        
        dispatchGroup.notify(queue: .main) {
            
            MediaAPI.getById(id: id, completion: { (singleMediaResponse, error) in
                
                if let error = error {
                    failure(SvrfError(title: SvrfErrorTitle.Media.Response.rawValue, description: error.localizedDescription))
                } else {
                    if let media = singleMediaResponse?.media {
                        success(media)
                    } else {
                        failure(SvrfError(title: SvrfErrorTitle.Media.Response.rawValue, description: nil))
                    }
                }
            })
        }
    }
    
    public static func getNodeFromMedia(media: Media, onSuccess success: @escaping (_ node: SCNNode) -> Void, onFailure failure: @escaping (_ error: SvrfError) -> Void) {
        
        if media.type == ._3d {
            if let scene = getSceneFromMedia(media: media) {
                success(scene.rootNode)
            }
            
            failure(SvrfError(title: SvrfErrorTitle.GetNode.GetScene.rawValue, description: nil))
        } else {
            failure(SvrfError(title: SvrfErrorTitle.GetNode.IncorrectMediaType.rawValue, description: nil))
        }
    }
    
    public static func setBlendShapes(blendShapes: [ARFaceAnchor.BlendShapeLocation : NSNumber], for node: SCNNode) {
        
        node.enumerateHierarchy { (childNode, _) in
            
            for (blendShape, weight) in blendShapes {
                let targetName = blendShape.rawValue
                node.morpher?.setWeight(CGFloat(weight.floatValue), forTargetNamed: targetName)
            }
        }
    }

    public static func getFaceFilter(with device: MTLDevice, media: Media, onSuccess success: @escaping (_ faceFilter: SCNNode) -> Void, onFailure failure: @escaping (_ error: SvrfError) -> Void) {
        
        if media.type == ._3d, let glbUrlString = media.files?.glb, let glbUrl = URL(string: glbUrlString) {
            let modelSource = GLTFSceneSource(url: glbUrl)
            
            do {
                let faceFilter = SCNNode()
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
                
                success(faceFilter)
                
                SEGAnalytics.shared().track("Face Filter Node Requested", properties: ["media_id" : media.id ?? "unknown"])
            } catch {
                failure(SvrfError(title: SvrfErrorTitle.GetFaceFilter.GetScene.rawValue, description: error.localizedDescription))
            }
        }
    }
    
    //MARK: private functions
    private static func getSceneFromMedia(media: Media) -> SCNScene? {
        
        if let glbUrlString = media.files?.glb {
            if let glbUrl = URL(string: glbUrlString) {
                
                let modelSource = GLTFSceneSource(url: glbUrl)
                
                do {
                    let scene = try modelSource.scene()
                    return scene
                } catch {
                    
                }
            }
        }
        
        return nil
    }
    
    private static func needUpdateToken() -> Bool {
        
        if let tokenExpirationDate = UserDefaults.standard.object(forKey: svrfAuthTokenExpireDateKey) as? Date, let _ = UserDefaults.standard.string(forKey: svrfAuthTokenKey) {
            
            let twoDays = 172800
            if Int(Date().timeIntervalSince(tokenExpirationDate)) < twoDays {
                return false
            }
        }
        
        return true
    }
    
    private static func getTokenExpireDate(expireIn: Int) -> Date {
        
        guard let timeInterval = TimeInterval(exactly: expireIn) else {
            return Date()
        }
        
        return Date().addingTimeInterval(timeInterval)
    }
    
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
