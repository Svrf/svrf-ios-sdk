//
//  SvrfError.swift
//  SVRFFrameworkSetup
//
//  Created by Andrei Evstratenko on 08/11/2018.
//  Copyright © 2018 Svrf, Inc. All rights reserved.
//

import Foundation

public struct SvrfError: Error {
    public var svrfDescription: String?
}

public enum SvrfErrorDescription: String {

    enum Auth: String {
        case responseNoToken = "There is no token in the server response."
        case apiKey = "Missing API key. Add your API key to Info.plist for the field SVRF_API_KEY."
    }

    case response = "Server response error."
    case responseNoMediaArray = "There is no mediaArray in the server response."
    case getScene = "Can't get scene from the media."
    case incorrectMediaType = "Media type should equal _3d."
}
