//
//  SvrfAuthenticationResponse.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

struct SvrfAuthenticationResponse: Codable {

    /** If the request was successful */
    let success: Bool?
    /** Message */
    let message: String?
    /** Token to be used in the x-app-token */
    let token: String?
    /** How many seconds this token will be valid for */
    let expiresIn: Int?
}
