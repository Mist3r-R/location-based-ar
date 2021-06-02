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

Steps ...

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
