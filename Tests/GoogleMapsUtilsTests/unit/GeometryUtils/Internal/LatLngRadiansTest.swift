// Copyright 2024 Google LLC
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

import XCTest

@testable import GoogleMapsUtils

class LatLngRadiansTest : XCTestCase {
  let latLng1 = LatLngRadians(latitude: 1, longitude: 2)
  let latLng2 = LatLngRadians(latitude: -1, longitude: 8)
  let latLng3 = LatLngRadians(latitude: 0, longitude: 10)

  private let accuracy = 1e-15

  func testAddition() {
    let sum = latLng1 + latLng2
    XCTAssertEqual(latLng3.latitude, sum.latitude, accuracy: accuracy)
    XCTAssertEqual(latLng3.longitude, sum.longitude, accuracy: accuracy)
  }

  func testSubtraction() {
    let difference = latLng3 - latLng2
    XCTAssertEqual(latLng1.latitude, difference.latitude, accuracy: accuracy)
    XCTAssertEqual(latLng1.longitude, difference.longitude, accuracy: accuracy)
  }
}
