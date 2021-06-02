# Location-Based Augmented Reality

Combines most powerful and modern Augmented Reality tools for iOS devices with Location-Based Services to provide a unique experience of virtual items placing and tracking with respect to their real-world positions.


# Requirements

* iOS 14
* Swift 5.3
* XCode 12+

The package is build on top of `ARKit 4.0` and `RealityKit 2.0`, so hardware requirements are the same as for these Frameworks.

**Note:** It is higly recommended to use device equipped with `LiDAR` as it significantly improves the overall AR experience as well as allows continuous tracking without spending extra time for environment processing.

**Note (2):** Although the package can be used on devices without GPS module (e.g. iPad Wi-Fi only models), the performance of library can be reduced due to unstable location updates provided by CoreLocation service.

# Installation

## Swift Package Manager

Add the URL of this repository to your Xcode 12+ Project under `File > Swift Packages`.

`https://github.com/Mist3r-R/location-based-ar.git`

# Usage

The library contains a Demo App, which covers most of use cases.

## Setting Up the Project

Firstly, add `NSLocationWhenInUseUsageDescription`, `NSLocationUsageDescription` and `NSLocationTemporaryUsageDescriptionDictionary` keys with descriptions to your `Info.plist` to be able to use CoreLocation. Note that library requires full accuracy mode (new in iOS 14), so the third key should be provided. Secondly, add `NSCameraUsageDescription` key which is required by ARKit. Finally, import this library: `import LocationBasedAR`.

## Quick Start Guide

`LBARView` can be used both with SwiftUI and UIKit frameworks. First, one should declare it as a property:

```swift

func makeUIView(context: Context) -> LBARView {
    let arView = LBARView(frame: .zero)
    
    // perform view's configuration
    
    return arView
}

```

Once the app is ready for AR experience, a native method for running a session should be called:

```swift

let configuration: ARWorldTrackingConfiguration = LBARView.defaultConfiguration()
let options: ARSession.RunOptions = [
    // options to run session
]
arView.session.run(configuration, options: options)

```

`LBARView` expects to operate with its default or similar configurations. It can be specified based on application needs, however, the `.worldAlignment` property of session config should always be set to `.gravityAndHeading`. It also important to mention that `LBARView` **does not** listen to location updates by default and expects them to be provided externaly.

`LBARView` comes with a special class which represents Location-Based anchors: `LBAnchor`. It is a custom subclass of `ARAnchor`, which inherits all the properties and behaviour of ARAnchor and can be further subclassed too. The class containes containes geolocation data and supports `SecureCoding`, which means it can be used in tasks related to sharing experience among different devices as it would be serialized with `ARWorldMap` object automatically.

`LBARView` supports several approaches of location anchors creation:

```swift

let location = CLLocation(/* params for initialization */)
arView.add(location: location) // CoreLocation's object

let placemark = Placemark(/* params for initialization */)
arView.add(placemark: placemark) // Custom object for location with associated name

let anchor = LBAnchor(/* params for initialization */)
arView.add(anchor: anchor) // Location-based anchor

let anchorEntity = AnchorEntity(/* params for initialization */)
arView.add(entity: anchorEntity) // RealityKit's Anchor Entity object

```

`LBAnchor` should not be added to `ARSession` manually as in such case `LBARView` won't be able to properly process location data and manage it during further tracking. However, when anchor is added via special methods, it can be further used as anchoring target for RealityKit's entities:

```swift

let anchor: LBAnchor!
let anchorEntity = AnchorEntity(anchor: anchor)
let sphere = ModelEntity.sphereModel(radius: 0.1, color: anchor.locationEstimation.color, isMetallic: true)
anchorEntity.addChild(sphere)
arView.scene.addAnchor(anchorEntity)

```

Finally, `LBARView` provides a set of tools for conversion between real-world coordinates to virtual world position and vice versa. 


## Additional Features

Besides a great variety of conversions and transformations that can take place in Location-Based AR projects, the library comes with `RealityKit`'s extensions for *async loading* of remote Textures and Entities. These methods can be used in a similar to native `loadAsync` approach:

```swift

let url = URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/retrotv/tv_retro.usdz")!

ModelEntity.loadModelAsync(from: url) { result in
            switch result {
            case .failure(let err): // handle downloading error
            case .success(let loadRequest):
                _ /* AnyCancellable variable */ = loadRequest.sink(receiveCompletion: { loadCompletion in

                    switch loadCompletion {
                    case .failure(let error): // handle loading from local storage error
                    case .finished: break
                    }
                    
                }, receiveValue: { modelEntity in
                    
                    // do your stuff with received USDZ model
                })
            }
        }

```

## Issues

One of the main issues is that CoreLocation does not provide reliable altitude estimations, thus the most stable approach to estimate vertical positions of model entities is to use the same altitude as the user's device has at the moment of estimation.

Second known issue is the limitation of tracking distance. Unfortunately, ARKit fails to track positions of anchors further than 100m away from the device, so the content should be placed closer in order to be rendered properly. 

Finally, sometimes CoreLocation fails to provide accurate values of device heading at the startup and thus the virtual content may appear on wrong positions which may improve over time. In addition, sometimes the direction of user movement can be estimated incorrectly and location updates will represent the moving in the opposite direction, which results in further distance from the anchor in virtual space than is should be.
