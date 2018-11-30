# The SVRF SDK

[![CocoaPods](https://img.shields.io/cocoapods/v/SvrfSDK.svg?style=flat-square)][Pod] ![iOS Version](https://img.shields.io/badge/iOS-11.0%2B-lightgrey.svg?style=flat-square) ![Swift Version](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat-square)

**SVRF** allows you to supercharge your app with the first and largest search engine for immersive experiences. We make it simple for any developer to incorporate highly immersive experiences with all kinds of applications: virtual reality, augmented reality, mixed reality, mobile, and web.

The **SvrfSDK** is a framework for easy integration of the [SVRF API][SVRF Dev] and allows you to stream ARKit compatible 3D face filters into your application.

## Requirements

- iOS 11.0+
- 3D Face Filters require an iPhone X or newer

## Access and API Keys

To  generate a SVRF API Key, create an account on [www.svrf.com][SVRF] and go to the *Apps* section of the [User Settings][SVRF User Settings] page.

See our [terms of service][TOS] for restrictions on using the SVRF API, libraries, and SDKs.

If you have questions or need support, please [create a ticket][Support] in the `svrf-api` GitHub repository.

## Installation

### CocoaPods

#### 1. Install CocoaPods

[CocoaPods][] is a dependency manager for Cocoa projects. Enter the following command to install CocoaPods:

```shell
sudo gem install cocoapods
```

The process may take a long time, please wait. For further installation instructions, please check [this guide][CocoaPods Install].

#### 2. Add the SvrfSDK entry to your Podfile

Add the SvrfSDK entry to your Podfile:

```swift
target :YourTargetName do
  pod 'SvrfSDK'
end
```

#### 3. Install the SvrfSDK in the project

To install the **SvrfSDK** into your Xcode project, run the following command:

```shell
pod install
```

*Note: If you saw "Unable to satisfy the following requirements" issue during pod install, please run the following commands to update your pod repo and install the pod again:*

```shell
pod repo update
pod install
```

### Manually

If you prefer not to use dependency manager, you can integrate the **SvrfSDK** into your project manually.

## Examples

[ARKitFaceFilterDemo][Demo] - An example of the **SvrfSDK** in Swift.

## Authentication

1) Add your API key to the `Info.plist` file for *"SVRF_API_KEY"* key.
2) Add the following code into `didFinishLaunchingWithOptions` function in *AppDelegate*:

```swift
SvrfSDK.authenticate(onSuccess: {
    // Do what you want when success
}) { error in
    // Do what you want with the error
}
```

## Endpoints

#### Search Endpoint

[The SVRF Search Endpoint][Docs Search] brings the power of immersive search found on [SVRF.com][SVRF] to your app or project. Our search engine enables your users to instantly find the immersive experience they're seeking. Content is sorted by the SVRF rating system, ensuring that the highest quality content and most relevant search results are returned first.

| Parameter                     | Type                                            |
| :---                          | :---                                            |
| query                         | *String*                                        |
| type                          | *[MediaType]?*                                  |
| category                      | *String?*                                       |
| pageNum                       | *Int?*                                          |
| size                          | *Int?*                                          |
| stereoscopicType              | *String?*                                       |

**Returns:** *[Media]?*

##### Example

Search "Five Eyes" face filter; limited by "_3d" *type* and "Face Filters" *category*.

```swift
SvrfSDK.search(query: "Five Eyes", type: [._3d], stereoscopicType: nil, category: "Face Filters", size: nil, pageNum: nil, onSuccess: { mediaArray in
    if !mediaArray.isEmpty {
        // Do what you want with the Media[]
        self.searchCollectionView.setupWith(mediaArray: mediaArray)
        self.searchCollectionView.reloadData()
    } else {
        let alertController = UIAlertController(title: "Empty Array", message: "No results found...", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
}) { error in
    // Do what you want with the error
}
```

### Trending Endpoint

[The SVRF Trending Endpoint][Docs Trending] provides your app or project with the hottest immersive content - curated by real humans. The experiences returned mirror the [SVRF homepage][SVRF], from timely cultural content to trending pop-culture references. The trending experiences are updated regularly to ensure users always get fresh updates of immersive content.

| Parameter                     | Type                                            |
| :---                          | :---                                            |
| type                          | *[MediaType]?*                                  |
| category                      | *String?*                                       |
| nextPageCursor                | *String?*                                       |
| size                          | *Int?*                                          |
| stereoscopicType              | *String?*                                       |

**Returns:** *[Media]?*

#### Example

Get trending *Media*; limited by "video" *type*.

```swift
SvrfSDK.getTrending(type: [.video], stereoscopicType: nil, category: nil, size: nil, nextPageCursor: nil, onSuccess: { mediaArray in

    if !mediaArray.isEmpty {
        //Do what you want with the media array
        self.searchCollectionView.setupWith(mediaArray: mediaArray)
        self.searchCollectionView.reloadData()
    } else {
        let alertController = UIAlertController(title: "Empty Array", message: "No results found...", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
}) { error in
    // Do what you want with the error
}
```

### Media by ID Endpoint

Fetch *Media* by ID.

| Parameter                     | Type                                            |
| :---                          | :---                                            |
| id                            | *String*                                        |

**Returns:** *Media?*

#### Example

Get *Media* with ID "547963".

```swift
SvrfSDK.getMedia(id: "547963", onSuccess: { media in
    //Do what you want with the media
    self.mediaTitleLabel.text = media.title ?? "unknown"
}) { error in
    // Do what you want with the error
}
```

## Utilities

### getNodeFromMedia

For Media with 3D Fetches from *Media*.

| Parameter                     | Type                                            |
| :---                          | :---                                            |
| media                         | *Media*                                         |

**Returns:** *SCNNode?*

#### Example

Get *SCNNode* from *Media*.

```swift
SvrfSDK.getMedia(id: "547963", onSuccess: { media in
    let scnNode = SvrfSDK.getNodeFromMedia(media: media)
    // Do what you want with the SCNNode
}) { error in
    // Do what you want with the error
}
```

### getFaceFilter

The SVRF API allows you to access all of SVRF's ARKit compatible face filters and stream then directly to your app. Use the `getFaceFilter` method to stream a face filter to your app and convert it into a *SCNNode* in runtime.

| Parameter                     | Type                                            |
| :---                          | :---                                            |
| device                        | *MTLDevice*                                     |
| media                         | *Media*                                         |

**Returns:** *SCNNode?*

#### Example

Get a face filter *SCNNode* from *Media*.

```swift
SvrfSDK.getMedia(id: "547963", onSuccess: { media in
    let faceFilter = SvrfSDK.getFaceFilter(with: self.mtlDevice, media: media)
    // Do what you want with the face filter
}) { error in
    // Do what you want with the error
}
```

### setBlendShapes

Blend shape mapping allows SVRF's ARKit compatible face filters to have animations that are activated by your user's facial expressions.

| Parameter                     | Type                                            |
| :---                          | :---                                            |
| blendShapes                   | *[ARFaceAnchor.BlendShapeLocation : NSNumber]*  |
| node                          | *SCNNode*                                       |

#### Example

Map blend shapes to a *SCNNode*'s morpher.

```swift
class FaceFilter: SCNNode, VirtualFaceContent {

    var blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber] = [:] {
        didSet {
            self.enumerateHierarchy({ (node, _) in
                if (node.morpher?.targets != nil) {
                    SvrfSDK.setBlendShapes(blendShapes: blendShapes, for: node)
                }
            })
        }
    }

    func update(withFaceAnchor faceAnchor: ARFaceAnchor, andMTLDevice device: MTLDevice ) {
        self.device = device
        blendShapes = faceAnchor.blendShapes
    }
}
```

## Attribution

### Authors and Site Credit

At SVRF, we believe in giving credit where credit is due. Do your best to provide attribution to the `authors` and `site` where the content originated. We suggest using the format: __by {authors} via {site}__

If possible, please provide a way for users to discover and visit the page the content originally came from (`url`).

### Powered By SVRF

As per section 5 A of the [terms of service][TOS], __we require all apps that use the SVRF API to conspicuously display "Powered By SVRF" attribution marks where the API is utilized.__

## Rate Limits

The SVRF API has a generous rate limit to ensure the best experience for your users. We rate limit by IP address with a maximum of 100 requests per 10 seconds. If you exceed the rate limit, requests from the requesting IP address will be blocked for 60 seconds.

[CocoaPods]: https://www.cocoapods.org/
[CocoaPods Install]: https://guides.cocoapods.org/using/getting-started.html#getting-started
[Demo]: https://www.github.com/SVRF/svrf-api/tree/master/examples/ARKitFaceFilterDemo
[Docs Search]: https://developers.svrf.com/#tag/Media/paths/~1vr~1search?q={q}/get
[Docs Trending]: https://developers.svrf.com/#tag/Media/paths/~1vr~1trending/get
[Pod]: https://cocoapods.org/pods/SvrfSDK
[Support]: https://github.com/SVRF/svrf-api/issues/new/choose 
[SVRF]: https://www.svrf.com
[SVRF Dev]: https://developers.svrf.com
[SVRF User Settings]: https://www.svrf.com/user/settings
[TOS]: https://www.svrf.com/terms
