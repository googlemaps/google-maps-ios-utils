![Run unit tests](https://github.com/googlemaps/google-maps-ios-utils/workflows/Run%20unit%20tests/badge.svg)
[![pod](https://img.shields.io/cocoapods/v/Google-Maps-iOS-Utils.svg)](https://cocoapods.org/pods/Google-Maps-iOS-Utils)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![GitHub contributors](https://img.shields.io/github/contributors/googlemaps/google-maps-ios-utils)
![Apache-2.0](https://img.shields.io/badge/license-Apache-blue)

Google Maps SDK for iOS Utility Library
=======================================

## Description

This open-source library contains classes that are useful for a wide
range of applications using the [Google Maps SDK for iOS][sdk].

- **Marker clustering** — handles the display of a large number of points
- **Marker customization** - [display custom markers][customizing-markers]
- **Quadtree data structure** - indexes 2D geometry points and performs
2D range queries
- **Geometry libraries** - [KML and GeoJSON rendering][geometry-rendering]
- **Heatmaps** - [Heatmap rendering][heatmap-rendering]

<p align="center"><img width=“80%" vspace=“10" src="https://cloud.githubusercontent.com/assets/16808355/16646253/77feeb96-446c-11e6-9ec1-19e12a7fb3ae.png"></p>

## Requirements

* iOS 9.0+
* CocoaPods

## Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

In your `Podfile`:

```ruby
use_frameworks!

target 'TARGET_NAME' do
    pod 'Google-Maps-iOS-Utils', '~> 3.4.0'
end
```

Replace `TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

In your `Cartfile`:

```
github "googlemaps/google-maps-ios-utils" ~> 3.4.0
```

See the [Carthage doc] for further installation instructions.

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

**Note**: This feature is only available with Swift 5.3 (Xcode 12) or later.

Add the following to your `dependencies` value of your `Package.swift` file.

```
dependencies: [
  .package(
    url: "https://github.com/googlemaps/google-maps-ios-utils.git",
    .upToNextMinor(from: "3.4.0")
  )
]
```

## Samples and Example Usage

e.g. Displaying KML data

```swift
import GoogleMapsUtils

func renderKml() {
    // Parse KML
    let path: String = // Path to your KML file...
    let kmlUrl = URL(fileURLWithPath: path)
    let kmlParser = GMUKmlParser(url: kmlUrl)
    kmlParser.parse()

    // Render parsed KML
    let renderer = GMUGeometryRenderer(
        map: mapView,
        geometries: kmlParser.placemarks,
        styles: kmlParser.styles,
        styleMaps: kmlParser.styleMaps
    )
    renderer.render()
}
```

You can see more example usages in our [sample][samples] projects.

## Support

Encounter an issue while using this library?

If you find a bug or have a feature request, please file an [issue].
Or, if you'd like to contribute, please refer to our [contributing guide][contributing] and our [code of conduct].

You can also reach us on our [Discord channel].

For more information, check out the detailed guide on the
[Google Developers site][devsite-guide].

[Carthage doc]: Carthage.md
[Discord channel]: https://discord.gg/9fwRNWg
[contributing]: CONTRIBUTING.md
[code of conduct]: CODE_OF_CONDUCT.md
[devsite-guide]: https://developers.google.com/maps/documentation/ios-sdk/utility/
[sdk]: https://developers.google.com/maps/documentation/ios-sdk
[issue]: https://github.com/googlemaps/google-maps-ios-utils/issues
[customizing-markers]: CustomMarkers.md
[geometry-rendering]: GeometryRendering.md
[heatmap-rendering]: HeatmapRendering.md
[samples]: https://github.com/googlemaps/google-maps-ios-utils/tree/master/samples
