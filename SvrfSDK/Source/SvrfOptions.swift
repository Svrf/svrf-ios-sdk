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
                stereoscopicType: MediaAPI.StereoscopicType_search? = nil,
                category: MediaAPI.Category_search? = nil,
                size: Int? = nil,
                pageNum: Int? = nil) {
        self.type = type
        self.stereoscopicType = stereoscopicType
        self.category = category
        self.size = size
        self.pageNum = pageNum
    }

    let type: [MediaType]?
    let stereoscopicType: MediaAPI.StereoscopicType_search?
    let category: MediaAPI.Category_search?
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
                stereoscopicType: MediaAPI.StereoscopicType_getTrending? = nil,
                category: MediaAPI.Category_getTrending? = nil,
                size: Int? = nil,
                minimumWidth: Int? = nil,
                pageNum: Int? = nil) {
        self.type = type
        self.stereoscopicType = stereoscopicType
        self.category = category
        self.size = size
        self.minimumWidth = minimumWidth
        self.pageNum = pageNum
    }
    let type: [MediaType]?
    let stereoscopicType: MediaAPI.StereoscopicType_getTrending?
    let category: MediaAPI.Category_getTrending?
    let size: Int?
    let minimumWidth: Int?
    let pageNum: Int?
}
