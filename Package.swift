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
    .iOS(.v16),
  ],
  products: [
    .library(
      name: "GoogleMapsUtils",
      targets: ["GoogleMapsUtils", "GoogleMapsUtilsObjC"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/googlemaps/ios-maps-sdk",
      from: "10.0.0"),
    .package(
      url: "https://github.com/erikdoe/ocmock.git",
      revision: "fe1661a3efed11831a6452f4b1a0c5e6ddc08c3d"),
  ],
  targets: [
    .target(
      name: "GoogleMapsUtilsObjC",
      dependencies: [
        .product(name: "GoogleMaps", package: "ios-maps-sdk"),
      ],
      publicHeadersPath: "include",
      cSettings: [
          .headerSearchPath("."),
      ],
      linkerSettings: [
        .linkedFramework("UIKit", .when(platforms: [.iOS])),
      ]
    ),
    .target(
      name: "GoogleMapsUtils",
      dependencies: [
        .target(name: "GoogleMapsUtilsObjC"),
        .product(name: "GoogleMaps", package: "ios-maps-sdk"),
      ]
    ),
    .target(
      name: "GoogleMapsUtilsTestsHelper",
      dependencies: [
        .target(name: "GoogleMapsUtilsObjC"),
      ],
      path: "Tests/GoogleMapsUtilsTestsHelper"
    ),
    .testTarget(
      name: "GoogleMapsUtilsObjCTests",
      dependencies: [
        "GoogleMapsUtilsObjC",
        "GoogleMapsUtilsTestsHelper",
        .product(name: "OCMock", package: "ocmock"),
      ],
      path: "Tests/GoogleMapsUtilsObjCTests",
      cSettings: [
        .headerSearchPath(".")
      ]
    ),
    .testTarget(
      name: "GoogleMapsUtilsSwiftTests",
      dependencies: [
        "GoogleMapsUtils",
        "GoogleMapsUtilsObjC",
        "GoogleMapsUtilsTestsHelper",
        .product(name: "GoogleMaps", package: "ios-maps-sdk"),
      ],
      path: "Tests/GoogleMapsUtilsSwiftTests",
      resources: [.process("Resources")]
    )
  ]
)
