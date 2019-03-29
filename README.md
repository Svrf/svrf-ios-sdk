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

## Attribution

SVRF requires developers to provide attribution. Please read our [documentation][Docs Attribution] and [terms of service][TOS] to learn about attribution requirements.

## Rate Limits

The SVRF API has a generous rate limit. Please read our [documentation][Docs Rate Limits] to learn about API rate limits.

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

```ruby
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

Configure your `plist` with your **SVRF_API_KEY** or pass **SVRF_API_KEY** in the authenticate function. 

```plist
<plist version="1.0">
  <dict>
    <key>SVRF_API_KEY</key>
    <string>{your-api-key}</string>
  </dict>
</plist>
```

To authenticate the SvrfSDK, add the following to your `didFinishLaunchingWithOptions` function in *AppDelegate*:

```swift
SvrfSDK.authenticate()
```
or

```swift
SvrfSDK.authenticate(apiKey:**SVRF_API_KEY**)
```

## Endpoints

### Search Endpoint

[The SVRF Search Endpoint][Docs Search] brings the power of immersive search found on [SVRF.com][SVRF] to your app or project. Our search engine enables your users to instantly find the immersive experience they're seeking. Content is sorted by the SVRF rating system, ensuring that the highest quality content and most relevant search results are returned first.

| Parameter                     | Type                                            |
| :---                          | :---                                            |
| query                         | *String*                                        |
| searchOptions                 | *SearchOptions*                                 |
| onSuccess                     | *(_ mediaArray: [Media]) -> Void*               |
| onFailure                     | *((_ error: SvrfError) -> Void)?*               |

**Returns:** *[Media]?*

#### Example

Search "Five Eyes" face filter; limited by "_3d" *type* and "Face Filters" *category*.

```swift
let searchOptions = SearchOptions(type: [._3d], stereoscopicType: nil, category: nil, size: nil, pageNum: nil)

SvrfSDK.search(query: "Five Eyes", options: searchOptions, onSuccess: { mediaArray in
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
    print("\(error.title). \(error.description ?? "")")
}
```

### Trending Endpoint

[The SVRF Trending Endpoint][Docs Trending] provides your app or project with the hottest immersive content - curated by real humans. The experiences returned mirror the [SVRF homepage][SVRF], from timely cultural content to trending pop-culture references. The trending experiences are updated regularly to ensure users always get fresh updates of immersive content.

| Parameter                     | Type                                            |
| :---                          | :---                                            |
| trendingOptions               | *TrendingOptions*                               |
| onSuccess                     | *(_ mediaArray: [Media]) -> Void*               |
| onFailure                     | *((_ error: SvrfError) -> Void)?*               |

**Returns:** *[Media]?*

#### Example

Get trending *Media*; limited by "video" *type*.

```swift
let trendingOptions = TrendingOptions(type: [.video], stereoscopicType: nil, category: nil, size: nil, nextPageCursor: nil)

SvrfSDK.getTrending(options: trendingOptions, onSuccess: { mediaArray in
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
    print("\(error.title). \(error.description ?? "")")
}
```

### Media by ID Endpoint

Fetch *Media* by ID.

| Parameter                     | Type                                            |
| :---                          | :---                                            |
| id                            | *String*                                        |
| onSuccess                     | *(_ media: Media) -> Void*                      |
| onFailure                     | *((_ error: SvrfError) -> Void)?*               |

**Returns:** *Media?*

#### Example

Get *Media* with ID "547963".

```swift
SvrfSDK.getMedia(id: "547963", onSuccess: { media in
    //Do what you want with the Media
    self.mediaTitleLabel.text = media.title ?? "unknown"
}) { error in
    print("\(error.title). \(error.description ?? "")")
}
```

## Utilities

### getNodeFromMedia

Generates a *SCNNode* for a *Media* with a *type* "3d". This method can used to generate the whole 3D model, but is not recommended for face filters. **Face filters should be retrieved using the [`getFaceFilter`](#getFaceFilter) method.**

| Parameter                     | Type                                            |
| :---                          | :---                                            |
| media                         | *Media*                                         |
| onSuccess                     | *(_ node: SCNNode) -> Void*                     |
| onFailure                     | *((_ error: SvrfError) -> Void)?*               |

**Returns:** *SCNNode?*

#### Example

Get *SCNNode* from *Media* with ID "547963".

```swift
SvrfSDK.getMedia(id: "547963", onSuccess: { media in
    SvrfSDK.getNodeFromMedia(media: media, onSuccess: { node in
        // Do what you want with the SCNNode
    }, onFailure: { error in
        print("\(error.title). \(error.description ?? "")")
    })
}) { error in
    print("\(error.title). \(error.description ?? "")")
}
```

### getFaceFilter

The SVRF API allows you to access all of SVRF's ARKit compatible face filters and stream them directly to your app. Use the `getFaceFilter` method to stream a face filter to your app and convert it into a *SCNNode* in runtime. You can then attach the face filter to a *SCNScene*

| Parameter                     | Type                                            |
| :---                          | :---                                            |
| media                         | *Media*                                         |
| onSuccess                     | *(_ faceFilter: SCNNode) -> Void*               |
| onFailure                     | *((_ error: SvrfError) -> Void)?*               |

**Returns:** *SCNNode*

#### Example

Get a face filter *SCNNode* for *Media* with ID "547963".

```swift
SvrfSDK.getMedia(id: "547963", onSuccess: { media in
    SvrfSDK.getFaceFilter(with: media, onSuccess: { faceFilter in
        // Do what you want with the face filter
    }, onFailure: { error in
        print("\(error.title). \(error.description ?? "")")
    })
}) { error in
    print("\(error.title). \(error.description ?? "")")
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
            // Enumerate through all child nodes to find all morpher targets
            self.enumerateHierarchy({ (node, _) in
                if (node.morpher?.targets != nil) {
                    SvrfSDK.setBlendShapes(blendShapes: blendShapes, for: node)
                }
            })
        }
    }

    // VirtualFaceContent protocol's function
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {
        blendShapes = faceAnchor.blendShapes
    }
}
```

## Errors

Errors are returned in a custom `SvrfError`. It includes a `title` and `description` to provide you with detailed information for the error you are encountering.

```swift
print(svrfError.title)
print(svrfError.description)
```

[CocoaPods]: https://www.cocoapods.org/
[CocoaPods Install]: https://guides.cocoapods.org/using/getting-started.html#getting-started
[Demo]: https://www.github.com/SVRF/svrf-api/tree/master/examples/ARKitFaceFilterDemo
[Docs Attribution]: https://developers.svrf.com/docs#section/Attribution
[Docs Rate Limits]: https://developers.svrf.com/docs#section/Rate-Limits
[Docs Search]: https://developers.svrf.com/#tag/Media/paths/~1vr~1search?q={q}/get
[Docs Trending]: https://developers.svrf.com/#tag/Media/paths/~1vr~1trending/get
[Pod]: https://cocoapods.org/pods/SvrfSDK
[Privacy Policy]: https://www.svrf.com/privacy
[Support]: https://github.com/SVRF/svrf-api/issues/new/choose
[SVRF]: https://www.svrf.com
[SVRF Dev]: https://developers.svrf.com
[SVRF User Settings]: https://www.svrf.com/user/settings
[TOS]: https://www.svrf.com/terms
