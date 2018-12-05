//
//  SvrfError.swift
//  SVRFFrameworkSetup
//
//  Created by Andrei Evstratenko on 08/11/2018.
//  Copyright © 2018 Svrf, Inc. All rights reserved.
//

import Foundation

public enum SvrfError: String {
    
    case Plist = "Svrf: Problems with .plist file"
    case ApiKey = "Svrf: Problems with API key. Please, set your API key into .plist file for SVRF_API_KEY field"
    case AuthResponse = "Svrf: Authentication response error"
    case SearchResponse = "Svrf: Search response error"
    case TrendingResponse = "Svrf: Trending response error"
    case MediaResponse = "Svrf: Media response error"
    case GetScene = "Svrf: Get scene error"
    case CreateScene = "Svrf: Create scene error"
    
    enum GetNode: String {
        case IncorrectMediaType = "Svrf: Incorrect media type. Media type should be equal _3d"
        case GetScene = "Svrf: Can't get scene from media. Scene is equal nil"
    }
}
