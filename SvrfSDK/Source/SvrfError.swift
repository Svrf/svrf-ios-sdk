//
//  SvrfError.swift
//  SVRFFrameworkSetup
//
//  Created by Andrei Evstratenko on 08/11/2018.
//  Copyright © 2018 Svrf, Inc. All rights reserved.
//

import Foundation

public struct SvrfError {
    public let title: String
    public let description: String?
}

public enum SvrfErrorTitle: String {
    
    enum Auth: String {
        case ResponseNoToken = "There is no token in the server response."
        case ApiKey = "There is no API key in the Info.plist file. Please, set your API key into Info.plist file for SVRF_API_KEY field."
    }
    
    case Response = "Server response error."
    case ResponseNoMediaArray = "There is no mediaArray in the server response."
    case GetScene = "Can't get scene from the media."
    case IncorrectMediaType = "Media type should equal _3d."
}
