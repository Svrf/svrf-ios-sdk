//
//  SvrfMediaVideos.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

public struct SvrfMediaVideos: Codable {

    /** 848px wide video with a 1.3MBps video rate, 96KBps audio rate. */
    public let _848: String?
    /** 1440px wide video with a 4.4MBps video rate, 128KBps audio rate. */
    public let _1440: String?
    /** 2160px wide video with a 10MBps video rate, 192KBps audio rate. */
    public let _2160: String?
    /** 4096px wide video with a 20MBps video rate, 256KBps audio rate. */
    public let _4096: String?
    /** A 6-second, 1440px wide clip, with a 2MBps video rate, no audio. */
    public let clip: String?
    /** URL for an HLS master playlist containing streams in all of the above
     resolutions which are no wider than the original Media.
     This should be used for streaming unless the platform does not support HLS. */
    public let hls: String?
    /** Maximum resolution video (original source video),
     &#x60;width&#x60; pixels wide at unspecified video and audio rates. */
    public let max: String?

    private enum CodingKeys: String, CodingKey {
        case _848 = "848"
        case _1440 = "1440"
        case _2160 = "2160"
        case _4096 = "4096"
        case clip
        case hls
        case max
    }
}
