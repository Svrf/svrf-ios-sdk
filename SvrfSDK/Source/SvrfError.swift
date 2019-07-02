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

    case response = "Unable to make a request to the server. Check your internet connection"
    case getScene = "Can't get scene from the media."
    case incorrectMediaType = "Media type should equal _3d."
}
