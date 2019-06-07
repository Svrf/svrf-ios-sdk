//
//  SvrfMediaMetadata.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

public struct SvrfMediaMetadata: Codable {

    /** For 3D Media, denotes that this model contains blend shapes, but having to calculate and apply weights
     to them is not required. These are models like glasses, hats, and billboards that do not react to face movement. */
    public let hasBlendShapes: Bool?
    /** For 3D Media, denotes that this model can be applied as a Face Filter overlay on a video of a face. */
    public let isFaceFilter: Bool?
    /** For 3D Media, denotes that calculating and applying blend shape weights to this model is _required_
     for the correct experience. If your platform cannot detect and calculate blend shape weights you
     MUST NOT present these models to your users. */
    public let requiresBlendShapes: Bool?
}
