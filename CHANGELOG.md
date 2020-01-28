# Changelog

## [Unreleased](https://github.com/googlemaps/google-maps-ios-utils/compare/v3.0.0...HEAD)

## [Version 3.0.0](https://github.com/googlemaps/google-maps-ios-utils/compare/v2.1.0...v3.0.0) - January 2020
### BREAKING CHANGES

* update GMUFeature interface to conform to spec #rfc7946 ([4a562be](https://github.com/googlemaps/google-maps-ios-utils/commit/4a562be73ddd6f7181428f1d71d8930322e559a0)), closes [#229](https://github.com/googlemaps/google-maps-ios-utils/issues/229)

### Bug Fixes
* Fix for wrong icons when using multiple Cluster Managers. Fixes [#158](https://github.com/googlemaps/google-maps-ios-utils/issues/158)
* If cluster is expanded and an item is visible, show cluster. Fixes [#150](https://github.com/googlemaps/google-maps-ios-utils/issues/150) ([9e20f39bb94675b22d1913d843a8ae57c4b59354](https://github.com/googlemaps/google-maps-ios-utils/commit/9e20f39bb94675b22d1913d843a8ae57c4b59354))
* Fix no animation when kGMSMaxClusterZoom is reached. Fixes [#131](https://github.com/googlemaps/google-maps-ios-utils/issues/131)([25826831dabdbdb1b0887fda3aea91a0d8872929](https://github.com/googlemaps/google-maps-ios-utils/commit/25826831dabdbdb1b0887fda3aea91a0d8872929))
* Fix typo in Heatmap/GMUGradient.h import of UIKit header ([#175](https://github.com/googlemaps/google-maps-ios-utils/pull/175))
* Add Heatmap .m files into the GoogleMapsUtils target. ([341e508](https://github.com/googlemaps/google-maps-ios-utils/commit/341e5082bedef0426b314ccb0a35293c532fdf4a))
* Crash when tapping on cluster. Fixes [#250](https://github.com/googlemaps/google-maps-ios-utils/issues/250). ([#255](https://github.com/googlemaps/google-maps-ios-utils/issues/255)) ([d0ad212](https://github.com/googlemaps/google-maps-ios-utils/commit/d0ad2122e602d0a5a5601b0f4cfdfeaf455f9f9e))
* fix unit-tests ([ff07b98](https://github.com/googlemaps/google-maps-ios-utils/commit/ff07b98677c3a8832e0e00c266b06a8a14c65470))
* increase stale bot window ([b8152e5](https://github.com/googlemaps/google-maps-ios-utils/commit/b8152e5e18dab83730e0f6cf081f9600fd754737))
* resolve all Xcode 10 warnings ([7d1a6e8](https://github.com/googlemaps/google-maps-ios-utils/commit/7d1a6e82571709b106b11522d1fa64df9b386064))
* typo in documentation ([#233](https://github.com/googlemaps/google-maps-ios-utils/issues/233)) ([9e79caf](https://github.com/googlemaps/google-maps-ios-utils/commit/9e79caf9eb2cc728d0cc724da51725badd36438a))

### Features
* Make heat-map zoom intensities customizable ([#186](https://github.com/googlemaps/google-maps-ios-utils/pull/186))
* Adds support for StyleMap ([#202](https://github.com/googlemaps/google-maps-ios-utils/pull/202))
* **cluster:** expose private cluster configuration to public API, resolve Xcode 10 warnings ([#220](https://github.com/googlemaps/google-maps-ios-utils/pull/220))
* **cluster:** expose cluster-config properties ([4c50c88](https://github.com/googlemaps/google-maps-ios-utils/commit/4c50c886b7064c9e2aa131b98b35b12ef8a11032))
* **GoogleMapsUtils:** framework cleanup ([#261](https://github.com/googlemaps/google-maps-ios-utils/issues/261)) ([a33e821](https://github.com/googlemaps/google-maps-ios-utils/commit/a33e821fdbbbf77401a2738c69024613c38ca5fa))
* Update Swift demo to use Swift 4.2 ([#256](https://github.com/googlemaps/google-maps-ios-utils/issues/256)) ([2f4fd4a](https://github.com/googlemaps/google-maps-ios-utils/commit/2f4fd4a76276823aaa73cf4538ba27c7e4a6a796))

## [Version 2.1.0](https://github.com/googlemaps/google-maps-ios-utils/compare/v2.0.0...v2.1.0) - September 2017
### Features:
- Added Heatmaps rendering.
- Added a constructor for setting custom background colors of cluster icons.

### Resolved Issues:
- Forwarded mapView:didTapPOIWithPlaceID:name:location to underlying mapDelegate.
- Fixed a minor Swift compatibility issue.

## [Version 2.0.0](https://github.com/googlemaps/google-maps-ios-utils/compare/v1.1.1...v2.0.0) - May 2017
### Features:
- KML and GeoJSON rendering.
- Changed GMUClusterManagerDelegate's methods to return a BOOL to indicate
whether the event should pass through to other handlers. This will give
applications the ability to allow the default info window to be shown
when tapping on a marker. Please note this is a breaking change so existing
code needs to be updated.

## [Version 1.1.2](https://github.com/googlemaps/google-maps-ios-utils/compare/v1.1.1...v1.1.2) - October 2016
### Resolved Issues:
- Fixed include paths to work properly with cocoapods.

## [Version 1.1.1](https://github.com/googlemaps/google-maps-ios-utils/compare/v1.1.0...v1.1.1) - October 2016
### Resolved Issues:
- Added missing CHANGELOG.

## [Version 1.1.0](https://github.com/googlemaps/google-maps-ios-utils/compare/v1.0.1...v1.1.0) - October 2016
### Features:
- Allowed easy customization of markers by introducing GMUClusterRendererDelegate
delegate on GMUDefaultClusterRenderer.

## [Version 1.0.1](https://github.com/googlemaps/google-maps-ios-utils/compare/v1.0.0...v1.0.1) - July 2016
### Resolved Issues:
- Added a workaround for cocoapods issue with GoogleMaps 2.0.0.

## [Version 1.0.0](https://github.com/googlemaps/google-maps-ios-utils/compare/94919ae...v1.0.0) - July 2016
Initial release of Marker Clustering.
