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
    
    //MARK: public functions
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
    
    public static func getNodeFromMedia(media: Media) -> SCNNode? {
        
        if media.type == ._3d {
            if let scene = getSceneFromMedia(media: media) {
                return scene.rootNode
            }
            
            print(SvrfError.GetNode.GetScene.rawValue)
        } else {
            print(SvrfError.GetNode.IncorrectMediaType.rawValue)
        }
        
        return nil
    }
    
    public static func setBlendshapes(blendShapes: [ARFaceAnchor.BlendShapeLocation : NSNumber], for node: SCNNode) {
        
        node.enumerateHierarchy { (childNode, _) in
            
            for (blendShape, weight) in blendShapes {
                let targetName = blendShape.rawValue
                node.morpher?.setWeight(CGFloat(weight.floatValue), forTargetNamed: targetName)
            }
        }
    }
    
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
    
    //MARK: private functions
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
    
    private static func needUpdateToken() -> Bool {
        
        if let tokenExpirationDate = UserDefaults.standard.object(forKey: svrfAuthTokenExpireDateKey) as? Date {
            
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
