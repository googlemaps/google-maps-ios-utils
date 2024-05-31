// swift-tools-version:5.9

// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import PackageDescription

let package = Package(
  name: "GoogleMapsUtils",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "GoogleMapsUtils",
      targets: ["GoogleMapsUtils", "GoogleMapsUtilsSwift"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/googlemaps/ios-maps-sdk",
      from: "8.3.1"),
    .package(
      url: "https://github.com/erikdoe/ocmock.git",
      revision: "fe1661a3efed11831a6452f4b1a0c5e6ddc08c3d"),
  ],
  targets: [
    .target(
      name: "GoogleMapsUtils",
      dependencies: [
        .product(name: "GoogleMaps", package: "ios-maps-sdk"),
        .product(name: "GoogleMapsCore", package: "ios-maps-sdk"),
        .product(name: "GoogleMapsBase", package: "ios-maps-sdk")
      ],
      publicHeadersPath: "include",
      linkerSettings: [
        .linkedFramework("UIKit", .when(platforms: [.iOS])),
      ]
    ),
    .target(
      name: "GoogleMapsUtilsSwift",
      dependencies: [
        .target(name: "GoogleMapsUtils"),
        .product(name: "GoogleMaps", package: "ios-maps-sdk"),
        .product(name: "GoogleMapsCore", package: "ios-maps-sdk"),
        .product(name: "GoogleMapsBase", package: "ios-maps-sdk")
      ]
    ),
    .target(
      name: "GoogleMapsUtilsTestsHelper",
      dependencies: [
        .target(name: "GoogleMapsUtils"),
      ],
      path: "Tests/GoogleMapsUtilsTestsHelper"
    ),
    .testTarget(
      name: "GoogleMapsUtilsTests",
      dependencies: [
        "GoogleMapsUtils",
        "GoogleMapsUtilsTestsHelper",
        .product(name: "OCMock", package: "ocmock")
      ],
      path: "Tests/GoogleMapsUtilsTests",
      cSettings: [
        .headerSearchPath(".")
      ]
    ),
    .testTarget(
      name: "GoogleMapsUtilsSwiftTests",
      dependencies: [
        "GoogleMapsUtils",
        "GoogleMapsUtilsSwift",
        "GoogleMapsUtilsTestsHelper",
        .product(name: "GoogleMaps", package: "ios-maps-sdk"),
        .product(name: "GoogleMapsCore", package: "ios-maps-sdk"),
        .product(name: "GoogleMapsBase", package: "ios-maps-sdk")
      ],
      path: "Tests/GoogleMapsUtilsSwiftTests",
      resources: [
        .copy("resources/GeoJSON/GeoJSON_FeatureCollection_Test.geojson"),
        .copy("resources/GeoJSON/GeoJSON_Feature_Test.geojson"),
        .copy("resources/GeoJSON/GeoJSON_GeometryCollection_Test.geojson"),
        .copy("resources/GeoJSON/GeoJSON_LineString_Test.geojson"),
        .copy("resources/GeoJSON/GeoJSON_MultiLineString_Test.geojson"),
        .copy("resources/GeoJSON/GeoJSON_MultiPoint_Test.geojson"),
        .copy("resources/GeoJSON/GeoJSON_MultiPolygon_Test.geojson"),
        .copy("resources/GeoJSON/GeoJSON_Point_Test.geojson"),
        .copy("resources/GeoJSON/GeoJSON_Polygon_Test.geojson"),
        .copy("resources/KML/KML_GroundOverlay_Test.kml"),
        .copy("resources/KML/KML_LineString_Test.kml"),
        .copy("resources/KML/KML_MultiGeometry_Test.kml"),
        .copy("resources/KML/KML_Placemark_Test.kml"),
        .copy("resources/KML/KML_Point_Test.kml"),
        .copy("resources/KML/KML_Polygon_Test.kml"),
        .copy("resources/KML/KML_StyleMap_Test.kml"),
        .copy("resources/KML/KML_Style_Test.kml"),
      ]
    )
  ]
)
