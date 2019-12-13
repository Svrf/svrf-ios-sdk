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
import SceneKit
import ARKit

private enum ChildNode: String {
    case head = "Head"
    case occluder = "Occluder"
}

public class SvrfSDK: NSObject {

    private static let dispatchGroup = DispatchGroup()

    private static let svrfApiKeyKey = "SVRF_API_KEY"
    private static let svrfAuthTokenExpireDateKey = "SVRF_AUTH_TOKEN_EXPIRE_DATE"
    private static let svrfAuthTokenKey = "SVRF_AUTH_TOKEN"

    private static var occluder: SCNNode?

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

        SvrfAnalyticsManager.setupAnalytics()

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
                            failure(SvrfError(svrfDescription: authenticationResponse.message))
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
     to your app or project. Svrf's search engine enables your users to instantly find the immersive experience they're
     seeking. Content is sorted by the Svrf rating system, ensuring that the highest quality content and most prevalent
     search results are returned.

     - Parameters:
        - query: Url-encoded search query.
        - options: Search query options.
        - success: Success closure.
        - mediaArray: An array of *Media* from the Svrf API.
        - nextPageNum: The page number of the next page.
        - failure: Error closure.
        - error: A *SvrfError*.
     - Returns: `SvrfRequest` for the in-flight request
     */
    public static func search(query: String,
                              options: SvrfOptions,
                              onSuccess success: @escaping (_ mediaArray: [SvrfMedia],
                                                            _ nextPageNum: Int?) -> Void,
                              // swiftlint:disable:next syntactic_sugar
                              onFailure failure: Optional<((_ error: SvrfError) -> Void)> = nil) -> SvrfRequest {

        return queuedRequest { svrfRequest in
            return SvrfAPIManager.search(query: query, options: options, onSuccess: { searchResponse in
                svrfRequest.state = .completed

                if let mediaArray = searchResponse.media {
                    success(mediaArray, searchResponse.nextPageNum)
                } else if let failure = failure {
                    failure(SvrfError(svrfDescription: searchResponse.message))
                }
            }, onFailure: { error in
                svrfRequest.state = .completed

                if let failure = failure, var svrfError = error as? SvrfError {
                    svrfError.svrfDescription = SvrfErrorDescription.response.rawValue
                    failure(svrfError)
                }

            })
        }
    }

    /**
     The Svrf Trending Endpoint provides your app or project with the hottest immersive content curated by real humans.
     The experiences returned mirror the [Svrf homepage](https://www.svrf.com), from timely cultural content to trending
     pop-culture references. The trending experiences are updated regularly to ensure users always get fresh updates of
     immersive content.
     
     - Parameters:
        - options: Trending request options.
        - success: Success closure.
        - mediaArray: An array of *Media* from the Svrf API.
        - nextPageNum: Number of the next page.
        - failure: Error closure.
        - error: A *SvrfError*.
     - Returns: `SvrfRequest` for the in-flight request
     */
    public static func getTrending( options: SvrfOptions?,
                                    onSuccess success: @escaping (_ mediaArray: [SvrfMedia],
                                                                  _ nextPageNum: Int?) -> Void,
                                    // swiftlint:disable:next syntactic_sugar
                                    onFailure failure: Optional<((_ error: SvrfError) -> Void)> = nil) -> SvrfRequest {

        return queuedRequest { svrfRequest in

            return SvrfAPIManager.getTrending(options: options, onSuccess: { trendingResponse in
                svrfRequest.state = .completed

                if let mediaArray = trendingResponse.media {
                    success(mediaArray, trendingResponse.nextPageNum)
                } else if let failure = failure {
                    failure(SvrfError(svrfDescription: trendingResponse.message))
                }
            }, onFailure: { error in
                svrfRequest.state = .completed

                if let failure = failure, var svrfError = error as? SvrfError {
                    svrfError.svrfDescription = SvrfErrorDescription.response.rawValue
                    failure(svrfError)
                }
            })
        }
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
                                onFailure failure: Optional<((_ error: SvrfError) -> Void)> = nil) -> SvrfRequest {

        return queuedRequest { svrfRequest in

            return SvrfAPIManager.getMedia(by: id, onSuccess: { mediaResponse in
                svrfRequest.state = .completed

                if let media = mediaResponse.media {
                    success(media)
                } else if let failure = failure {
                    failure(SvrfError(svrfDescription: mediaResponse.message))
                }
            }, onFailure: { error in
                svrfRequest.state = .completed

                if let failure = failure, var svrfError = error as? SvrfError {
                    svrfError.svrfDescription = SvrfErrorDescription.response.rawValue
                    failure(svrfError)
                }

            })
        }
    }

    public static func request(endPoint: String,
                               parameters: [String: Any?],
                               onSuccess success: @escaping (_ data: Data) -> Void,
                               // swiftlint:disable:next syntactic_sugar
                               onFailure failure: Optional<((_ error: SvrfError) -> Void)> = nil) -> SvrfRequest {

        return queuedRequest { svrfRequest in
            return SvrfAPIManager.request(endPoint: endPoint,
                                          parameters: parameters,
                                          onSuccess: { data in
                                            svrfRequest.state = .completed
                                            success(data)
            }, onFailure: { error in
                svrfRequest.state = .completed
                if let failure = failure, let svrfError = error as? SvrfError {
                    failure(svrfError)
                }
            })
        }
    }

    /**
     Generates a *SCNNode* for a *Media* with a *type* `_3d`. This method can used to generate
     the whole 3D model, but is not recommended for face filters.
     
     - Attention: Face filters should be generated using the `getFaceFilter` method.
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
                                    onFailure failure: Optional<(
                                        (_ error: SvrfError) -> Void
                                    )> = nil) -> URLSessionDataTask? {

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

    /**
     Using a *Media* from a Svrf API response, stream a face filter to your app and convert it into a *SCNNode* at
     runtime. This function returns a class *SvrfFaceFilter* that contains the face filter *SCNNode*.
     
     - Parameters:
        - media: The *Media* to generate the face filter node from. The *type* must be `_3d`.
        - useOccluder: Use the occluder provided with the 3D model, otherwise it will be removed.
        - success: Success closure.
        - faceFilter: A *SvrfFaceFilter* class that contains the face filter *SCNNode*, ability to manage face filter
        animations, and 2D scene overlays.
        - failure: Error closure.
        - error: A *SvrfError*.
     - Returns: URLSessionDataTask? for the in-flight request
     */
    public static func generateFaceFilter(for media: SvrfMedia,
                                          useOccluder: Bool = true,
                                          onSuccess success: @escaping (_ faceFilter: SvrfFaceFilter) -> Void,
                                          // swiftlint:disable:next syntactic_sugar
                                          onFailure failure: Optional<(
                                              (_ error: SvrfError) -> Void
                                          )> = nil) -> URLSessionDataTask? {

        guard media.type == ._3d, let glbUrlString = media.files?.glb, let glbUrl = URL(string: glbUrlString) else {
            failure?(SvrfError(svrfDescription: "Invalid media sent to generateFaceFilter: \(media)"))
            return nil
        }

        let faceFilter = SvrfFaceFilter()

        return GLTFSceneSource.load(remoteURL: glbUrl,
                                    animationManager: faceFilter,
                                    onSuccess: { modelSource in
            do {
                let faceFilterNode = SCNNode()
                let sceneNode = try modelSource.scene().rootNode

                if useOccluder {
                    if let occluderNode = sceneNode.childNode(withName: ChildNode.occluder.rawValue,
                                                           recursively: true) {
                        occluderNode.removeFromParentNode()
                    }

                    let occluder = try occluderNode()
                    faceFilterNode.addChildNode(occluder)

                    setOccluderNode(node: occluder)
                }

                if let headNode = sceneNode.childNode(withName: ChildNode.head.rawValue, recursively: true) {
                    faceFilterNode.addChildNode(headNode)
                }

                faceFilterNode.morpher?.calculationMode = SCNMorpherCalculationMode.normalized

                faceFilter.node = faceFilterNode
                faceFilter.sceneOverlay = modelSource.sceneOverlay()

                success(faceFilter)

                SvrfAnalyticsManager.trackFaceFilterNodeRequested(id: media.id)
            } catch {
                failure?(SvrfError(svrfDescription: SvrfErrorDescription.getScene.rawValue))
            }
        }, onFailure: { error in
            failure?(SvrfError(svrfDescription: error.localizedDescription))
        })
    }

    /**
     Loads or returns the single instance of the Svrf occluder node for use with face filters loaded from the API.
    - Returns: Svrf's Occluder *SCNNode*.
     */
    public static func occluderNode() throws -> SCNNode {
        if occluder == nil {
            let bundle = Bundle(for: self)
            let path = bundle.path(forResource: "Occluder", ofType: "glb", inDirectory: "")
            let modelSource = try GLTFSceneSource(path: path!)
            occluder = try modelSource.scene().rootNode
        }

        return occluder!
    }

    // MARK: private functions

    /**
     Runs a request on the dispatchGroup.

     - Note:  `requestBlock` is responsible for setting the `svrfRequest` to .completed once finished.
     - Returns: a `SvrfRequest` most likely in `.queued` state.
     */
    private static func queuedRequest(_ requestBlock: @escaping (SvrfRequest) -> DataRequest?) -> SvrfRequest {
        let request = SvrfRequest()
        request.state = .queued

        dispatchGroup.notify(queue: .main) {
            // Kick off the request if we are in the queued state.
            switch request.state {
            case .queued:
                let dataRequest = requestBlock(request)
                request.state = .active(dataRequest)
            case .canceled: break
            case .completed: print("Error: Trying to run a completed request")
            default: print("Unhandled state \(request.state)")
            }
        }

        return request
    }

    /**
     Renders a *SCNScene* from a *Media*'s glb file using *SvrfGLTFSceneKit*.
     
     - Parameters:
     - media: The *Media* to return a *SCNScene* from.
     - success: The success block that returns the *SCNScene*, if loaded.
     - Returns: URLSessionDataTask? for the in-flight request
     */
    private static func loadSceneFromMedia(media: SvrfMedia,
                                           onSuccess success: @escaping (_ scene: SCNScene) -> Void,
                                           // swiftlint:disable:next syntactic_sugar
                                           onFailure failure: Optional<(
                                               (_ error: Error) -> Void
                                           )> = nil) -> URLSessionDataTask? {

        if let glbUrlString = media.files?.glb {
            if let glbUrl = URL(string: glbUrlString) {

                return GLTFSceneSource.load(remoteURL: glbUrl, onSuccess: { modelSource in

                    do {
                        let scene = try modelSource.scene()

                        SvrfAnalyticsManager.track3dNodeRequested(id: media.id)

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
