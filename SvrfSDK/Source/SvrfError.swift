//
//  SvrfError.swift
//  SVRFFrameworkSetup
//
//  Created by Andrei Evstratenko on 08/11/2018.
//  Copyright © 2018 Svrf, Inc. All rights reserved.
//

import Foundation

public enum SvrfError {
    
    enum Auth: String {
        case GetTokenFromUserDefaults = "Svrf: There is no token."
        case Response = "Svrf: Authentication. Server response error."
        case ResponseNoToken = "Svrf: Authentication. There is no token in the server response."
        case ApiKey = "Svrf: There is no API key in the Info.plist file. Please, set your API key into Info.plist file for SVRF_API_KEY field."
    }
    
    enum Search: String {
        case Response = "Svrf: Search. Server response error."
        case ResponseNoMediaArray = "Svrf: Search. There is no mediaArray in the server response."
    }
    
    enum Trending: String {
        case Response = "Svrf: Trending. Server response error."
        case ResponseNoMediaArray = "Svrf: Trending. There is no mediaArray in the server response."
    }
    
    enum Media: String {
        case Response = "Svrf: Media. Server response error."
        case ResponseNoMedia = "Svrf: Media. There is no media in the server response."
    }
    
    enum GetNode: String {
        case IncorrectMediaType = "Svrf: GetNode. Incorrect media type. Media type should be equal _3d."
        case GetScene = "Svrf: GetNode. Can't get scene from the medi.a"
    }
    
    enum GetFaceFilter: String {
        case GetScene = "Svrf: GetFaceFilter. Can't get scene from the media."
    }
}
