//
//  SvrfSearchResponse.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

struct SvrfSearchResponse: Codable {

    /** If the request was successful */
    let success: Bool?
    /** Message */
    let message: String?
    /** The next page to query to see more results, whether or not the next page actually exists. */
    let nextPageNum: Int?
    /** The current page number */
    let pageNum: Int?
    /** The search results */
    let media: [SvrfMedia]?
    /** The number of milliseconds the request took */
    let tookMs: Int?
    /** The number of total results for query */
    let totalNum: Int?
}
