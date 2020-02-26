[![Build Status](https://travis-ci.org/googlemaps/google-maps-ios-utils.svg?branch=master)](https://travis-ci.org/googlemaps/google-maps-ios-utils)
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

<p align="center"><img width=“80%" vspace=“10" src="https://cloud.githubusercontent.com/assets/16808355/25834988/ca7c3566-34be-11e7-8f07-16c3ae9de63a.png"></p>

<p align="center"><img width=“80%" vspace=“10" src="https://user-images.githubusercontent.com/16808355/30678820-54243eb6-9ed8-11e7-81b4-c1afe3df37b3.png"></p>

For more information, check out the detailed guide on the
[Google Developers site][devsite-guide].

## Requirements

* iOS 9.0+
* CocoaPods

## Installation

### [CocoaPods]((https://guides.cocoapods.org/using/using-cocoapods.html))

In your `Podfile`:

```ruby
use_frameworks!

target 'TARGET_NAME' do
    pod 'Google-Maps-iOS-Utils', '~> 3.0.0'
end
```

Replace `TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

### [Carthage](https://github.com/Carthage/Carthage)

_Coming soon!_ See [#249].

## Support

Encounter an issue while using this library?

If you find a bug or have a feature request, please file an [issue].
Or, if you'd like to contribute, please refer to our [contributing guide][contributing] and our [code of conduct].

You can also reach us on our [Discord channel].

[#249]: https://github.com/googlemaps/google-maps-ios-utils/issues/249
[Discord channel]: https://discord.gg/9fwRNWg
[contributing]: CONTRIBUTING.md
[code of conduct]: CODE_OF_CONDUCT.md
[devsite-guide]: https://developers.google.com/maps/documentation/ios-sdk/utility/
[sdk]: https://developers.google.com/maps/documentation/ios-sdk
[issue]: https://github.com/googlemaps/google-maps-ios-utils/issues
[customizing-markers]: CustomMarkers.md
[geometry-rendering]: GeometryRendering.md
[heatmap-rendering]: HeatmapRendering.md
