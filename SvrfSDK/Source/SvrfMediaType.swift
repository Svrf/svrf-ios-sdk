//
//  SvrfMediaType.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

/** The type of the Media. This should influence the media controls displayed to the user. */
public enum SvrfMediaType: String, Codable {
    /** A photo file (png or jpeg). */
    case photo = "photo"
    /** A video file (mp4 and HLS). */
    case video = "video"
    /** A 3D model (fbx, gltf, glb, and/or glb-draco). */
    case _3d = "3d"
}
