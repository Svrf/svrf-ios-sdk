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
    public init(type: [MediaType]?,
                stereoscopicType: String?,
                category: String?,
                size: Int?,
                pageNum: Int?) {
        self.type = type
        self.stereoscopicType = stereoscopicType
        self.category = category
        self.size = size
        self.pageNum = pageNum
    }

    let type: [MediaType]?
    let stereoscopicType: String?
    let category: String?
    let size: Int?
    let pageNum: Int?
}

public struct TrendingOptions {
    public init(type: [MediaType]?,
                stereoscopicType: String?,
                category: String?,
                size: Int?,
                nextPageCursor: String?) {
        self.type = type
        self.stereoscopicType = stereoscopicType
        self.category = category
        self.size = size
        self.nextPageCursor = nextPageCursor
    }
    let type: [MediaType]?
    let stereoscopicType: String?
    let category: String?
    let size: Int?
    let nextPageCursor: String?
}
