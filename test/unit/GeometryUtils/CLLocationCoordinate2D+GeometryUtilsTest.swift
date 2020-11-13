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


import XCTest
@testable import GoogleMapsUtils

class CLLocationCoordinate2DTest : XCTestCase {
  let accuracy = 1e-8

  func testDistanceSamePoint() {
    let point = CLLocationCoordinate2D(latitude: 1, longitude: 2)
    XCTAssertEqual(0.0, point.distance(to: point), accuracy: accuracy)
  }

  func testDistance() {
    let up = CLLocationCoordinate2D(latitude: 90, longitude: 0)
    let down = CLLocationCoordinate2D(latitude: -90, longitude: 0)
    XCTAssertEqual(.pi * kGMSEarthRadius, up.distance(to: down), accuracy: accuracy)
  }
}
