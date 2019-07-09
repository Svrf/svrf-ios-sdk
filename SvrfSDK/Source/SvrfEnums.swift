//
//  SvrfEnums.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

/**
 Types of stereoscopic content Svrf supports.
 
 - Note: If you want to request both stereoscopic and monoscopic content do not set *stereoscopicType* in your requests.
 */
public enum SvrfStereoscopicType: String {

    /**
     Sets stereoscopic type to *none*.
     
     - Note:For API requests, a stereoscopic type of *none* returns monoscopic content only.
     */
    case none = "none"

    /** Sets stereoscopic type to *top-bottom*. */
    case topBottom = "top-bottom"

    /** Sets stereoscopic type to *left-right*. */
    case leftRight = "left-right"
}

/** Categories available on Svrf. */
public enum SvrfCategory: String {

    /** A category for 3D face filters */
    case filters = "Face Filters"
}
