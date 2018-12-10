//
//  SvrfError.swift
//  SVRFFrameworkSetup
//
//  Created by Andrei Evstratenko on 08/11/2018.
//  Copyright © 2018 SVRF, Inc. All rights reserved.
//

import Foundation

public enum SvrfError: String {

    case plist = "SVRF: Problems with .plist file"
    case apiKey = "SVRF: Problems with API key. Please, set your API key into .plist file for SVRF_API_KEY field"
    case authResponse = "SVRF: Authentication response error"
    case searchResponse = "SVRF: Search response error"
    case trendingResponse = "SVRF: Trending response error"
    case mediaResponse = "SVRF: Media response error"
    case getScene = "SVRF: Get scene error"
    case createScene = "SVRF: Create scene error"

    enum GetNode: String {
        case incorrectMediaType = "Svrf: Incorrect media type. Media type should be equal _3d"
        case getScene = "Svrf: Can't get scene from media. Scene is equal nil"
    }
}
