//
//  SvrfMediaStereo.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

public struct SvrfMediaStereo: Codable {

    /** 848px wide video with a 1.3MBps video rate, 96KBps audio rate.
     Only included if the Media is a video. */
    public let _848: String?
    /** 1440px wide video with a 4.4MBps video rate, 128KBps audio rate.
     Only included if the Media is a video. */
    public let _1440: String?
    /** 2160px wide video with a 10MBps video rate, 192KBps audio rate.
     Only included if the Media is a video. */
    public let _2160: String?
    /** 4096px wide image. This image should be used on mobile devices,
     as larger images may cause some devices to crash. Only included if the Media is a video. */
    public let _4096: String?
    /** URL for an HLS master playlist containing streams in all of
     the above resolutions which are no wider than the original Media.
     Only included if the Media is a video. */
    public let hls: String?
    /** The Media in its largest available size (the original size). */
    public let max: String?

    private enum CodingKeys: String, CodingKey {
        case _848 = "848"
        case _1440 = "1440"
        case _2160 = "2160"
        case _4096 = "4096"
        case hls
        case max
    }
}
