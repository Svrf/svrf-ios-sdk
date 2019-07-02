//
//  SvrfMediaResponse.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

/** If the request was successful */
struct SvrfMediaResponse: Codable {

    /** If the request was successful */
    let success: Bool?
    /** Message */
    let message: String?
    /** SvrfMedia */
    let media: SvrfMedia?
}
