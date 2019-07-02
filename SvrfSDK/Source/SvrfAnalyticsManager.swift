//
//  SvrfAnalyticsManager.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 19/06/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

import Foundation
import Analytics

class SvrfAnalyticsManager {

    private static let svrfAnalyticsKey = "J2bIzgOhVGqDQ9ZNqVgborNthH6bpKoA"
    private static let svrfAuthTokenKey = "SVRF_AUTH_TOKEN"

    // MARK: public functions
    /**
     Setup Segment analytic event tracking.
     */
    public static func setupAnalytics() {

        let configuration = SEGAnalyticsConfiguration(writeKey: svrfAnalyticsKey)
        configuration.trackApplicationLifecycleEvents = true
        configuration.recordScreenViews = false

        // Use middleware middleware blocks
        configuration.middlewares = getMiddlewareBlocks()

        SEGAnalytics.setup(with: configuration)

        if let receivedData = SvrfKeyChain.load(key: svrfAuthTokenKey),
            let authToken = String(data: receivedData, encoding: .utf8) {

            let body = SvrfJWTDecoder.decode(jwtToken: authToken)
            if let appId = body["appId"] as? String {
                SEGAnalytics.shared().identify(appId)
            }
        }
    }

    public static func track3dNodeRequested(id: String?) {
        SEGAnalytics.shared().track("3D Node Requested",
                                    properties: ["media_id": id as Any])
    }

    public static func trackFaceFilterNodeRequested(id: String?) {
        SEGAnalytics.shared().track("Face Filter Node Requested",
                                    properties: ["media_id": id as Any])
    }

    // MARK: private functions
    private static func getSDKVersion() -> String? {

        // if SvrfSDK installed via cocoapods
        var bundle = Bundle(identifier: "org.cocoapods.SvrfSDK")
        if bundle == nil {
            // if SvrfSDK installed not via cocoapodsˆ
            bundle = Bundle(identifier: "svrf.SvrfSDK")
        }

        return bundle?.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    private static func getMiddlewareBlocks() -> [SEGMiddleware] {

        var middlewareBlocks: [SEGMiddleware] = []

        // Middleware Block that adds custom attributes in all calls
        let customizeAllTrackCalls = SEGBlockMiddleware { (context, next) in
            if context.eventType == .track {
                next(context.modify { context in
                    guard let track = context.payload as? SEGTrackPayload else {
                        return
                    }

                    // Property for tracking version of the SDK
                    var newProperties = track.properties ?? [:]
                    newProperties["sdk_version"] = getSDKVersion()

                    context.payload = SEGTrackPayload(
                        event: track.event,
                        properties: newProperties,
                        context: track.context,
                        integrations: track.integrations
                    )
                })
            } else {
                next(context)
            }
        }

        middlewareBlocks.append(customizeAllTrackCalls)

        return middlewareBlocks
    }
}
