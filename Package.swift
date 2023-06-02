// swift-tools-version:5.3

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
  products: [
    .library(name: "GoogleMapsUtils", targets: ["GoogleMapsUtils"])
  ],
  targets: [
    .binaryTarget(
      name: "GoogleMapsUtils",
      url: "https://github.com/googlemaps/google-maps-ios-utils/releases/download/v4.2.0/GoogleMapsUtils.xcframework.zip",
      checksum: "ec4614718329e1f240bc2d3ded0858e430310722f3c36f70600cdbe3e589a95b"
    )
  ]
)
