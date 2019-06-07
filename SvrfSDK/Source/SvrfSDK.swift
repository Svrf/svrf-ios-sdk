//
//  SvrfSDK.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 12/11/2018.
//  Copyright © 2018 Svrf, Inc. All rights reserved.
//

import Foundation
import Alamofire
import SvrfGLTFSceneKit
import Analytics
import SceneKit
import ARKit

private enum ChildNode: String {
    case head = "Head"
    case occluder = "Occluder"
}

public class SvrfSDK: NSObject {

    private static let dispatchGroup = DispatchGroup()

    private static let svrfAnalyticsKey = "J2bIzgOhVGqDQ9ZNqVgborNthH6bpKoA"
    private static let svrfApiKeyKey = "SVRF_API_KEY"
    private static let svrfAuthTokenExpireDateKey = "SVRF_AUTH_TOKEN_EXPIRE_DATE"
    private static let svrfAuthTokenKey = "SVRF_AUTH_TOKEN"

    // MARK: public functions
    /**
     Authenticate your API Key with the Svrf API.
     
     - Parameters:
        - apiKey: Svrf API Key.
        - success: Success closure.
        - failure: Error closure.
        - error: A *SvrfError*.
     */
    public static func authenticate(apiKey: String? = nil,
                                    onSuccess success: (() -> Void)? = nil,
                                    // swiftlint:disable:next syntactic_sugar
                                    onFailure failure: Optional<((_ error: SvrfError) -> Void)> = nil) {

        dispatchGroup.enter()

        setupAnalytics()

        if !needUpdateToken() {
            let authToken = String(data: (SvrfKeyChain.load(key: svrfAuthTokenKey))!, encoding: .utf8)!
            SvrfAPIManager.setToken(authToken)

            if let success = success {
                success()
            }

            dispatchGroup.leave()

            return
        } else {

            var key = apiKey

            if key == nil,
                let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
                let dict = NSDictionary(contentsOfFile: path) {

                key = dict[svrfApiKeyKey] as? String
            }

            if let key = key {
                SvrfAPIManager.authenticate(with: key, onSuccess: { authenticationResponse in
                    if let authToken = authenticationResponse.token, let expireIn = authenticationResponse.expiresIn {
                        SvrfAPIManager.setToken(authToken)
                        _ = SvrfKeyChain.save(key: svrfAuthTokenKey, data: Data(authToken.utf8))
                        UserDefaults.standard.set(getTokenExpireDate(expireIn: expireIn),
                                                  forKey: svrfAuthTokenExpireDateKey)

                        if let success = success {
                            success()
                        }

                        dispatchGroup.leave()

                        return
                    } else {
                        if let failure = failure {
                            failure(SvrfError(svrfDescription: SvrfErrorDescription.Auth.responseNoToken.rawValue))
                        }

                        dispatchGroup.leave()

                        return
                    }
                }, onFailure: { error in
                    if let failure = failure, var error = error as? SvrfError {
                        error.svrfDescription = SvrfErrorDescription.response.rawValue
                        failure(error)
                    }

                    dispatchGroup.leave()

                    return
                })
            }
        }
    }

    /**
     The Svrf Search Endpoint brings the power of immersive search found on [Svrf.com](https://www.svrf.com)
     to your app or project.
     Svrf's search engine enables your users to instantly find the immersive experience they're seeking.
     Content is sorted by the Svrf rating system, ensuring that the highest quality content and most
     prevalent search results are returned.

     - Parameters:
        - query: Url-encoded search query.
        - options: Search query options.
        - success: Success closure.
        - mediaArray: An array of *Media* from the Svrf API.
        - nextPageNum: The page number of the next page.
        - failure: Error closure.
        - error: A *SvrfError*.
     - Returns: DataRequest? for the in-flight request
     */
    public static func search(query: String,
                              options: SvrfOptions,
                              onSuccess success: @escaping (_ mediaArray: [SvrfMedia],
                                                            _ nextPageNum: Int?) -> Void,
                              // swiftlint:disable:next syntactic_sugar
                              onFailure failure: Optional<((_ error: SvrfError) -> Void)> = nil) -> DataRequest? {

        dispatchGroup.notify(queue: .main) {

            return _ = SvrfAPIManager.search(query: query, options: options, onSuccess: { searchResponse in
                if let mediaArray = searchResponse.media {
                    success(mediaArray, searchResponse.nextPageNum)
                } else if let failure = failure {
                    failure(SvrfError(svrfDescription: SvrfErrorDescription.responseNoMediaArray.rawValue))
                }
            }, onFailure: { error in
                if let failure = failure, var svrfError = error as? SvrfError {
                    svrfError.svrfDescription = SvrfErrorDescription.response.rawValue
                    failure(svrfError)
                }

            })
        }

        return nil
    }

    /**
     The Svrf Trending Endpoint provides your app or project with the hottest immersive content curated by real humans.
     The experiences returned mirror the [Svrf homepage](https://www.svrf.com), from timely cultural content
     to trending pop-culture references.
     The trending experiences are updated regularly to ensure users always get fresh updates of immersive content.
     
     - Parameters:
        - options: Trending request options.
        - success: Success closure.
        - mediaArray: An array of *Media* from the Svrf API.
        - nextPageNum: Number of the next page.
        - failure: Error closure.
        - error: A *SvrfError*.
     - Returns: DataRequest? for the in-flight request
     */
    public static func getTrending( options: SvrfOptions?,
                                    onSuccess success: @escaping (_ mediaArray: [SvrfMedia],
                                                                  _ nextPageNum: Int?) -> Void,
                                    // swiftlint:disable:next syntactic_sugar
                                    onFailure failure: Optional<((_ error: SvrfError) -> Void)> = nil) -> DataRequest? {

        dispatchGroup.notify(queue: .main) {

            return _ = SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
                if let mediaArray = trendingResponse.media {
                    success(mediaArray, trendingResponse.nextPageNum)
                } else if let failure = failure {
                    failure(SvrfError(svrfDescription: SvrfErrorDescription.responseNoMediaArray.rawValue))
                }

            }, onFailure: { error in
                if let failure = failure, var svrfError = error as? SvrfError {
                    svrfError.svrfDescription = SvrfErrorDescription.response.rawValue
                    failure(svrfError)
                }

            })
        }

        return nil
    }

    /**
     Fetch Svrf media by its ID.
     
     - Parameters:
        - id: The ID of *Media* to fetch.
        - success: Success closure.
        - media: *Media* from the Svrf API.
        - failure: Error closure.
        - error: A *SvrfError*.
     - Returns: DataRequest? for the in-flight request
     */
    public static func getMedia(id: String,
                                onSuccess success: @escaping (_ media: SvrfMedia) -> Void,
                                // swiftlint:disable:next syntactic_sugar
                                onFailure failure: Optional<((_ error: SvrfError) -> Void)> = nil) -> DataRequest? {

        dispatchGroup.notify(queue: .main) {

            return _ = SvrfAPIManager.getMedia(by: id, onSuccess: { mediaResponse in
                if let media = mediaResponse.media {
                    success(media)
                } else if let failure = failure {
                    failure(SvrfError(svrfDescription: SvrfErrorDescription.response.rawValue))
                }
            }, onFailure: { error in
                if let failure = failure, var svrfError = error as? SvrfError {
                    svrfError.svrfDescription = SvrfErrorDescription.response.rawValue
                    failure(svrfError)
                }

            })
        }

        return nil
    }

    /**
     Generates a *SCNNode* for a *Media* with a *type* `_3d`. This method can used to generate
     the whole 3D model, but is not recommended for face filters.
     
     - Attention: Face filters should be retrieved using the `getFaceFilterNode` method.
     - Parameters:
        - media: The *Media* to generate the *SCNNode* from. The *type* must be `_3d`.
        - success: Success closure.
        - node: The *SCNNode* generated from the *Media*.
        - failure: Error closure.
        - error: A *SvrfError*.
     */
    public static func generateNode(for media: SvrfMedia,
                                    onSuccess success: @escaping (_ node: SCNNode) -> Void,
                                    // swiftlint:disable:next syntactic_sugar
                                    onFailure failure: Optional<((_ error: SvrfError) -> Void)> = nil) -> URLSessionDataTask? {

        if media.type == ._3d {

            return loadSceneFromMedia(media: media, onSuccess: { scene in
                success(scene.rootNode)
            }, onFailure: { error in
                failure?(SvrfError(svrfDescription: error.localizedDescription))
            })
        } else if let failure = failure {
            failure(SvrfError(svrfDescription: SvrfErrorDescription.incorrectMediaType.rawValue))
        }

        return nil
    }
// swiftlint:disable line_length
    /**
     Blend shape mapping allows Svrf's ARKit compatible face filters to have animations that
     are activated by your user's facial expressions.
     
     - Attention: This method enumerates through the node's hierarchy.
     Any children nodes with morph targets that follow the
     [ARKit blend shape naming conventions](https://developer.apple.com/documentation/arkit/arfaceanchor/blendshapelocation) will be affected.
     - Note: The 3D animation terms "blend shapes", "morph targets", and "pose morphs" are often used interchangeably.
     - Parameters:
        - blendShapes: A dictionary of *ARFaceAnchor* blend shape locations and weights.
        - faceFilter: The node with morph targets.
     */
// swiftlint:enable line_length
    public static func setBlendShapes(blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber],
                                      for faceFilter: SCNNode) {

        DispatchQueue.main.async {
            faceFilter.enumerateHierarchy({ (node, _) in
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

    /**
     The SVRF API allows you to access all of SVRF's ARKit compatible face filters and
     stream them directly to your app.
     Use the `generateFaceFilterNode` method to stream a face filter to your app and
     convert it into a *SCNNode* in runtime.
     
     - Parameters:
        - media: The *Media* to generate the face filter node from. The *type* must be `_3d`.
        - useOccluder: Use the occluder provided with the 3D model, otherwise it will be removed. 
        - success: Success closure.
        - faceFilter: The *SCNNode* that contains face filter content.
        - failure: Error closure.
        - error: A *SvrfError*.
     - Returns: URLSessionDataTask? for the in-flight request
     */
    public static func generateFaceFilterNode(for media: SvrfMedia,
                                              useOccluder: Bool = true,
                                              onSuccess success: @escaping (_ faceFilterNode: SCNNode) -> Void,
                                              // swiftlint:disable:next syntactic_sugar
                                              onFailure failure: Optional<((_ error: SvrfError) -> Void)> = nil) -> URLSessionDataTask? {

        guard media.type == ._3d, let glbUrlString = media.files?.glb, let glbUrl = URL(string: glbUrlString) else {
            failure?(SvrfError(svrfDescription: "Invalid media sent to generateFaceFilterNode: \(media)"))
            return nil
        }

        return GLTFSceneSource.load(remoteURL: glbUrl, onSuccess: { modelSource in
            do {
                let faceFilterNode = SCNNode()
                let sceneNode = try modelSource.scene().rootNode

                if useOccluder,
                    let occluderNode = sceneNode.childNode(withName: ChildNode.occluder.rawValue,
                                                           recursively: true) {
                    faceFilterNode.addChildNode(occluderNode)
                    setOccluderNode(node: occluderNode)
                }

                if let headNode = sceneNode.childNode(withName: ChildNode.head.rawValue, recursively: true) {
                    faceFilterNode.addChildNode(headNode)
                }

                faceFilterNode.morpher?.calculationMode = SCNMorpherCalculationMode.normalized

                success(faceFilterNode)

                SEGAnalytics.shared().track("Face Filter Node Requested",
                                            properties: ["media_id": media.id ?? "unknown"])
            } catch {
                failure?(SvrfError(svrfDescription: SvrfErrorDescription.getScene.rawValue))
            }
        }, onFailure: { error in
            failure?(SvrfError(svrfDescription: error.localizedDescription))
        })
    }

    // MARK: private functions
    /**
     Renders a *SCNScene* from a *Media*'s glb file using *SvrfGLTFSceneKit*.
     
     - Parameters:
     - media: The *Media* to return a *SCNScene* from.
     - success: The success block that returns the *SCNScene*, if loaded.
     - Returns: URLSessionDataTask? for the in-flight request
     */
    private static func loadSceneFromMedia(media: SvrfMedia,
                                           onSuccess success: @escaping (_ scene: SCNScene) -> Void,
                                           onFailure failure: Optional<(_ error: Error) -> Void> = nil) -> URLSessionDataTask? {

        if let glbUrlString = media.files?.glb {
            if let glbUrl = URL(string: glbUrlString) {

                return GLTFSceneSource.load(remoteURL: glbUrl, onSuccess: { modelSource in

                    do {
                        let scene = try modelSource.scene()

                        SEGAnalytics.shared().track("3D Node Requested",
                                                    properties: ["media_id": media.id ?? "unknown"])

                        success(scene)
                    } catch {

                    }
                }, onFailure: { error in
                    failure?(error)
                })
            }
        }

        return nil
    }

    /**
     Checks if the Svrf authentication token has expired.

     - Returns: Bool
     */
    private static func needUpdateToken() -> Bool {

        if let tokenExpirationDate = UserDefaults.standard.object(forKey: svrfAuthTokenExpireDateKey) as? Date,
            let receivedData = SvrfKeyChain.load(key: svrfAuthTokenKey),
            String(data: receivedData, encoding: .utf8) != nil {

            let twoDays = 172800
            if Int(Date().timeIntervalSince(tokenExpirationDate)) < twoDays {
                return false
            }
        }

        return true
    }

    /**
     Takes the `expireIn` value returned by the Svrf authentication endpoint and returns the expiration date.

     - Parameters:
        - expireIn: The time until token expiration in seconds.
     - Returns: Date
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

        if let receivedData = SvrfKeyChain.load(key: svrfAuthTokenKey),
            let authToken = String(data: receivedData, encoding: .utf8) {

            let body = SvrfJWTDecoder.decode(jwtToken: authToken)
            if let appId = body["appId"] as? String {
                SEGAnalytics.shared().identify(appId)
            }

        }
    }

    /**
     Sets a node to have all of its children set as an occluder.
     - Parameters:
        - node: A *SCNNode* likely named *Occluder*.
     */
    private static func setOccluderNode(node: SCNNode) {

        // Any child of this node should be occluded
        node.enumerateHierarchy { (childNode, _) in
            childNode.geometry?.firstMaterial?.colorBufferWriteMask = []
            childNode.renderingOrder = -1
        }
    }
}
