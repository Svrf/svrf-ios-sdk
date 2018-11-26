# SvrfSDK

**SvrfSDK** is a framework for work with [Svrf API](https://developers.svrf.com/docs#) written in Swift

## Requirements

- iOS 11.0+

## Installation

### Cocoapods

[Cocoapods](https://www.cocoapods.org/) is a dependency manager for Cocoa projects. You can install it with the following command:


`$ gem install cocoapods`

To integrate **SvrfSDK** into your Xcode project using CocoaPods, add the following lines to your Podfile::

`pod 'SvrfSDK'`

Then, run the following command:

`$ pod install`

### Manually

If you prefer not to use dependency manager, you can integrate **SvrfSDK** into your project manually.

## Example

[ARKitExampleDemo](https://www.github.com/SVRF/svrf-api/tree/master/examples/ARKitFaceFilterDemo) - example of usage **SvrfSDK**

## How to use

### Authentication

1) Put your API key into .plist file for *"SVRF_API_KEY"* key. You can get API key on [Svrf](https://www.svrf.com).
2) Put the following code into `didFinishLaunchingWithOptions` function in *AppDelegate*:

```swift
SvrfSDK.authenticate(onSuccess: {
            
}) { error in
            
}
```

### Public functions

#### *search*

input parameters:

- query: *String*
- type: *[MediaType]?*
- category: *String?*
- size: *Int?*
- pageNum: *Int?*

return *[Media]*

#### *getTrending*

input parameters:

- type: *[MediaType]?*
- stereoscopicType: *String?*
- category: *String?*
- size: *Int?*
- nextPageCursor: *String?*

return *[Media]*

#### *getMedia*

input parameters:

- id: *String*

return *Media*

#### *getNodeFromMedia*

return *SCNNode?*

#### *getFaceFilter*

input parameters:

- device: *MTLDevice*
- media: *Media*

#### *setBlendshapes*

input parameters:

- blendShapes: *[ARFaceAnchor.BlendShapeLocation : NSNumber]*
- node: *SCNNode*

return *SCNNode*

## Support

Do you have any problems? Follow this link: [svrf-api/issues](https://github.com/Svrf/svrf-api/issues) 