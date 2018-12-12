//
//  SvrfOptions.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 12/12/2018.
//  Copyright © 2018 Svrf, Inc. All rights reserved.
//

import Foundation
import SVRFClient

/**
 Search endpoint parameters.
 - parameters:
 - type: The type(s) of *Media* to be returned (comma separated).
 - stereoscopicType: Search only for *Media* with a particular stereoscopic type.
 - category: Search only for *Media* with a particular category.
 - size: The number of results to return per-page, from 1 to 100.
 - pageNum: Pagination control to fetch the next page of results, if applicable.
 */
public struct SearchOptions {
    public init(type: [MediaType]? = nil,
                stereoscopicType: String? = nil,
                category: String? = nil,
                size: Int? = nil,
                pageNum: Int? = nil) {
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

/**
 Trending endpoint parameters.
 - parameters:
 - type: The type(s) of *Media* to be returned (comma separated).
 - stereoscopicType: Search only for *Media* with a particular stereoscopic type.
 - category: Search only for *Media* with a particular category.
 - size: The number of results to return per-page, from 1 to 100.
 - nextPageCursor: Pass this cursor ID to get the next page of results.
 */
public struct TrendingOptions {
    public init(type: [MediaType]? = nil,
                stereoscopicType: String? = nil,
                category: String? = nil,
                size: Int? = nil,
                nextPageCursor: String? = nil) {
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
