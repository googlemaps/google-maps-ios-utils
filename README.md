![Run unit tests](https://github.com/googlemaps/google-maps-ios-utils/workflows/Run%20unit%20tests/badge.svg)
[![pod](https://img.shields.io/cocoapods/v/Google-Maps-iOS-Utils.svg)](https://cocoapods.org/pods/Google-Maps-iOS-Utils)
![GitHub contributors](https://img.shields.io/github/contributors/googlemaps/google-maps-ios-utils)
![Apache-2.0](https://img.shields.io/badge/license-Apache-blue)

Google Maps SDK for iOS Utility Library
=======================================

## Description

This open-source library contains classes that are useful for a wide
range of applications using the [Google Maps SDK for iOS][sdk].

- **Geometry libraries** - [KML and GeoJSON rendering][geometry-rendering]
- **Geometry utilities** - Handy spherical [geometry utility][geometry-utils] functions
- **Heatmaps** - [Heatmap rendering][heatmap-rendering]
- **Marker clustering** — handles the display of a large number of points
- **Marker customization** - [display custom markers][customizing-markers]
- **Quadtree data structure** - indexes 2D geometry points and performs
2D range queries

<p align="center"><img width=“80%" vspace=“10" src="https://cloud.githubusercontent.com/assets/16808355/16646253/77feeb96-446c-11e6-9ec1-19e12a7fb3ae.png"></p>

## Requirements

* iOS 13.0+

## Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

In your `Podfile`:

```ruby
use_frameworks!

target 'TARGET_NAME' do
    pod 'Google-Maps-iOS-Utils', '~> 4.1.0'
end
```

Replace `TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

**Note**: This feature is only available with Swift 5.3 (Xcode 12) or later.

Add the following to your `dependencies` value of your `Package.swift` file.

```
dependencies: [
  .package(
    url: "https://github.com/googlemaps/google-maps-ios-utils.git",
    .upToNextMinor(from: "4.1.0")
  )
]
```

In addition to this, you will also have to include the `GoogleMaps` dependency using one of the available installation options (CocoaPods, XFFramework, or manual).

## Sample App

See the README for the Swift and Objective-C samples apps in [/samples](samples).

## Documentation

Read documentation about this utility library on [developers.google.com](https://developers.google.com/maps/documentation/ios-sdk/utility) or within the [/docs](docs) directory.

## Usage

### Displaying KML data

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

## Support

Encounter an issue while using this library?

If you find a bug or have a feature request, please file an [issue].
Or, if you'd like to contribute, please refer to our [contributing guide][contributing] and our [code of conduct].

You can also reach us on our [Discord server].

For more information, check out the detailed guide on the
[Google Developers site][devsite-guide].

[Carthage doc]: docs/Carthage.md
[Discord server]: https://discord.gg/9fwRNWg
[contributing]: CONTRIBUTING.md
[code of conduct]: CODE_OF_CONDUCT.md
[devsite-guide]: https://developers.google.com/maps/documentation/ios-sdk/utility/
[sdk]: https://developers.google.com/maps/documentation/ios-sdk
[issue]: https://github.com/googlemaps/google-maps-ios-utils/issues
[customizing-markers]: docs/CustomMarkers.md
[geometry-rendering]: docs/GeometryRendering.md
[heatmap-rendering]: docs/HeatmapRendering.md
[geometry-utils]: docs/GeometryUtils.md
