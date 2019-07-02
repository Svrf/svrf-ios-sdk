//
//  SvrfTrendingResponse.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

struct SvrfTrendingResponse: Codable {

    /** If the request was successful */
    let success: Bool?
    /** Message */
    let message: String?
    /** The next page to query to see more results, whether or not the next page actually exists. */
    let nextPageNum: Int?
    /** The current page number */
    let pageNum: Int?
    /** Trending media */
    let media: [SvrfMedia]?
}
