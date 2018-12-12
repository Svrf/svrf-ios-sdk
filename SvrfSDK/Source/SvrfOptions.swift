//
//  SvrfOptions.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 12/12/2018.
//  Copyright © 2018 Svrf, Inc. All rights reserved.
//

import Foundation
import SVRFClient

public struct SearchOptions {
    let query: String
    let type: [MediaType]?
    let stereoscopicType: String?
    let category: String?
    let size: Int?
    let pageNum: Int?
}

public struct TrendingOptions {
    let type: [MediaType]?
    let stereoscopicType: String?
    let category: String?
    let size: Int?
    let nextPageCursor: String?
}
