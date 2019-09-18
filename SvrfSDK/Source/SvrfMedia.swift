//
//  SvrfMedia.swift
//  SvrfSDK
//
//  Created by Andrei Evstratenko on 28/05/2019.
//  Copyright © 2019 Svrf, Inc. All rights reserved.
//

public struct SvrfMedia: Codable {

    /** Whether the Media is adult content */
    public let adult: Bool?
    /** The Media's authors. This should be displayed when possible. */
    public let authors: [String]?
    /** The canonical page this Media can be found at via SVRF. */
    public let canonical: String?
    /** A description of the Media */
    public let description: String?
    /** The duration of the Media in seconds. */
    public let duration: Double?
    /** An <iframe> tag that embeds a player that plays the Media.. */
    public let embedHtml: String?
    /** A player that can be embedded using an <iframe> tag to play the Media. */
    public let embedUrl: String?
    /**
     * Various sizes of images and resolutions for the Media. They will never be larger than the Media source's
     * original resolution.
     */
    public let files: SvrfMediaFiles?
    /** The height, in pixels, of the Media's source */
    public let height: Double?
    /** The unique ID of this Media */
    public let id: String?
    public let metadata: SvrfMediaMetadata?
    /** The site that this Media came from. This should be displayed when possible. */
    public let site: String?
    /** The title of the Media, suitable for displaying */
    public let title: String?
    /** SvrfMediaType */
    public let type: SvrfMediaType?
    /** The original page this Media is located at. */
    public let url: String?
    /** The width, in pixels, of the Media&#39;s source */
    public let width: Double?

    public init(adult: Bool? = nil,
                authors: [String]? = nil,
                canonical: String? = nil,
                description: String? = nil,
                duration: Double? = nil,
                embedHtml: String? = nil,
                embedUrl: String? = nil,
                files: SvrfMediaFiles? = nil,
                height: Double? = nil,
                id: String? = nil,
                metadata: SvrfMediaMetadata? = nil,
                site: String? = nil,
                title: String? = nil,
                type: SvrfMediaType? = nil,
                url: String? = nil,
                width: Double? = nil) {

        self.adult = adult
        self.authors = authors
        self.canonical = canonical
        self.description = description
        self.duration = duration
        self.embedHtml = embedHtml
        self.embedUrl = embedUrl
        self.files = files
        self.height = height
        self.id = id
        self.metadata = metadata
        self.site = site
        self.title = title
        self.type = type
        self.url = url
        self.width = width
    }
}
