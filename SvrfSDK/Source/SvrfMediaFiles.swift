//
//  SvrfMediaFiles.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

public struct SvrfMediaFiles: Codable {

    /** This is the binary glTF format that should be used by clients if the Media
     is a 3D object. This is the preferred format to use on end-user devices. */
    public let glb: String?
    /** This is the binary glTF format, with additional DRACO compression, that should be used
     by clients if the Media is a 3D object. Your renderer must support the
     KHR_draco_mesh_compression extension to use this model. */
    public let glbDraco: String?
    /** A map of file names to urls where those files are hosted. The file names are relative
     and their name heirarchy should be respected when saving them locally. */
    public let gltf: [String: String]?
    /** SvrfMediaImages */
    public let images: SvrfMediaImages?
    /** SvrfMediaStereo */
    public let stereo: SvrfMediaStereo?
    /** SvrfMediaVideos */
    public let videos: SvrfMediaVideos?

    public init(glb: String? = nil,
                glbDraco: String? = nil,
                gltf: [String: String]? = nil,
                images: SvrfMediaImages? = nil,
                stereo: SvrfMediaStereo? = nil,
                videos: SvrfMediaVideos? = nil) {

        self.glb = glb
        self.glbDraco = glbDraco
        self.gltf = gltf
        self.images = images
        self.stereo = stereo
        self.videos = videos
    }
}
