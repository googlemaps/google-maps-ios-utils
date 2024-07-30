![Run unit tests](https://github.com/googlemaps/google-maps-ios-utils/workflows/Build%20and%20Test/badge.svg)
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

<p align="center"><img width=“80%" vspace=“10" src="https://cloud.githubusercontent.com/assets/4.2.2feeb4.2.2c-4.2.2ec4.2.2a7fb3ae.png"></p>

## Requirements

- iOS 15.0+
- Xcode 15.0+
- [Maps SDK for iOS][sdk] (see [Releases](https://github.com/googlemaps/google-maps-ios-utils/releases) for minimum compatible version)
- A Google Maps Platform [API key](https://developers.google.com/maps/documentation/ios-sdk/get-api-key) from a project with the **Maps SDK for iOS** enabled.

## Installation

1. [Include the `GoogleMaps` dependency](https://developers.google.com/maps/documentation/ios-sdk/config#download-sdk) using one of the available installation options (Swift Package Manager, CocoaPods, or manual).

1. Add this utility library using one of the options below:

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

1. Follow the instructions for
    [adding package dependencies to your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).

2. In the "Enter Package URL" field, enter this GitHub repository:

  ```
  https://github.com/googlemaps/google-maps-ios-utils
  ```

> [!IMPORTANT]
> You also need to install the Maps SDK for iOS, which is also supported in Swift Package Manager at the URL `https://github.com/googlemaps/ios-maps-sdk`

3. Select the
    [version](https://github.com/googlemaps/google-maps-ios-utils/releases)
    of the Maps SDK for iOS Utility Library that you want to use. For new projects, we recommend specifying the latest version and using the "Exact Version" option. See Release Notes for [this library](https://github.com/googlemaps/google-maps-ios-utils/releases) and the [Maps SDK for iOS](https://developers.google.com/maps/documentation/ios-sdk/release-notes) to select the correct version for you.

    - (Recommended) Version 6.x supports the Maps SDK for iOS v9.x
    - Version 5.0 supports the Maps SDK for iOS v8.x
    - Version 4.2.2 supports the Maps SDK for iOS v7.x

4. Follow the
    [instructions](https://developers.google.com/maps/documentation/ios-sdk/config#get-key) to add your API key to your app.

5. See the [Importing](#importing) section for import statements specific to SPM installation.

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

1. In your `Podfile`:

<!-- x-release-please-start-version -->
  ```ruby
  use_frameworks!

  target 'TARGET_NAME' do
    pod 'GoogleMaps', '8.0.0'
    pod 'Google-Maps-iOS-Utils', '5.0.0'
  end
  ```
<!-- x-release-please-end -->

  Replace `TARGET_NAME` and save the `Podfile`.

2. At the command line in directory containing your `Podfile`, run:

  ```bash
  pod install
  ```

3. Open the `.xcworkspace` file that is created.

4. Follow the
    [instructions](https://developers.google.com/maps/documentation/ios-sdk/config#get-key) to add your API key to your app.

5. See the [Importing](#importing) section for import statements specific to CocoaPods installation.

### [Carthage](https://github.com/Carthage/Carthage)

<details>
<summary>Only supported if using Maps SDK v6.2.1 or earlier</summary>

In your `Cartfile`:

```
github "googlemaps/google-maps-ios-utils" ~> 4.1.0
```

See the [Carthage doc] for further installation instructions.
</details>

## Sample App

See the README for the Swift and Objective-C samples apps in [/samples](samples).

## Documentation

Read documentation about this utility library on [developers.google.com][devsite-guide] or within the [/docs](docs) directory.

## Usage

### Importing

You may also need to `import GoogleMaps`.

Swift:

```swift
import GoogleMapsUtils
```

Objective-C:

```objective-c
@import GoogleMapsUtils;
```

### Clustering markers

```swift
import GoogleMaps
import GoogleMapsUtils

class MarkerClustering: UIViewController, GMSMapViewDelegate {
  private var mapView: GMSMapView!
  private var clusterManager: GMUClusterManager!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up the cluster manager with the supplied icon generator and
    // renderer.
    let iconGenerator = GMUDefaultClusterIconGenerator()
    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                clusterIconGenerator: iconGenerator)
    clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
                                                      renderer: renderer)

    // Register self to listen to GMSMapViewDelegate events.
    clusterManager.setMapDelegate(self)
    // ...
  }
  // ...
}

let markerArray = [marker1, marker2, marker3, marker4] // define your own markers
clusterManager.add(markerArray)

clusterManager.cluster()
```

### Displaying KML data

```swift
import GoogleMaps
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

## Contributing

Contributions are welcome and encouraged. Please see the [contributing guide][contributing] for guidance.

## Terms of Service

This library uses Google Maps Platform services. Use of Google Maps Platform services through this library is subject to the Google Maps Platform [Terms of Service](https://cloud.google.com/maps-platform/terms).

This library is not a Google Maps Platform Core Service. Therefore, the Google Maps Platform Terms of Service (e.g. Technical Support Services, Service Level Agreements, and Deprecation Policy) do not apply to the code in this library.

## Support

This library is offered via an open source [license]. It is not governed by the Google Maps Platform Support [Technical Support Services Guidelines](https://cloud.google.com/maps-platform/terms/tssg), the [SLA](https://cloud.google.com/maps-platform/terms/sla), or the [Deprecation Policy](https://cloud.google.com/maps-platform/terms) (however, any Google Maps Platform services used by the library remain subject to the Google Maps Platform Terms of Service).

This library adheres to [semantic versioning](https://semver.org/) to indicate when backwards-incompatible changes are introduced. Accordingly, while the library is in version 0.x, backwards-incompatible changes may be introduced at any time.

If you find a bug, or have a feature request, please file an [issue] on GitHub. If you would like to get answers to technical questions from other Google Maps Platform developers, ask through one of our [developer community channels](https://developers.google.com/maps/developer-community). If you'd like to contribute, please check the [contributing] guide.

You can also discuss this library on our [Discord server].

[Discord server]: https://discord.gg/hYsWbmk
[Carthage doc]: docs/Carthage.md
[contributing]: CONTRIBUTING.md
[code of conduct]: CODE_OF_CONDUCT.md
[devsite-guide]: https://developers.google.com/maps/documentation/ios-sdk/utility/
[sdk]: https://developers.google.com/maps/documentation/ios-sdk
[issue]: https://github.com/googlemaps/google-maps-ios-utils/issues
[license]: LICENSE
[customizing-markers]: docs/CustomMarkers.md
[geometry-rendering]: docs/GeometryRendering.md
[heatmap-rendering]: docs/HeatmapRendering.md
[geometry-utils]: docs/GeometryUtils.md
