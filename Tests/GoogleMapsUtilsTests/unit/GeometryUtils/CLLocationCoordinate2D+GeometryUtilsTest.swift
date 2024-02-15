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

  func testHeadingIdentical() {
    let test = CLLocationCoordinate2D(latitude: -1, longitude: -2)
    let zero = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    XCTAssertEqual(0, zero.heading(to: zero))
    XCTAssertEqual(0, test.heading(to: test))
  }

  func testHeading() {
    let from = CLLocationCoordinate2D(latitude: -1, longitude: -2)
    let to = CLLocationCoordinate2D(latitude: -1, longitude: 3)
    let to2 = CLLocationCoordinate2D(latitude: 3, longitude: -2)
    let expectedHeading = 90.0436587178452
    XCTAssertEqual(expectedHeading, from.heading(to: to), accuracy: accuracy)
    XCTAssertEqual(360 - expectedHeading, to.heading(to: from), accuracy: accuracy)
    XCTAssertEqual(0, from.heading(to: to2))
    XCTAssertEqual(180, to2.heading(to: from))
  }
}

extension CLLocationCoordinate2DTest {
  func testOffset() {
    let from = CLLocationCoordinate2D(latitude: -80, longitude: -90)
    let to = CLLocationCoordinate2D(latitude: -70, longitude: -85)
    let distance = from.distance(to: to)
    let heading = from.heading(to: to)

    let offsetCoord = from.offset(distance: distance, heading: heading)
    assertCoordsEqual(to, offsetCoord, accuracy: accuracy)
  }

  func assertCoordsEqual(_ left: CLLocationCoordinate2D, _ right: CLLocationCoordinate2D, accuracy: Double) {
    XCTAssertEqual(left.latitude, left.latitude, accuracy: accuracy)
    XCTAssertEqual(left.longitude, left.longitude, accuracy: accuracy)
  }
}

extension CLLocationCoordinate2DTest {
  func testInterpolateEquatorCrossingAntimeridian() {
    let from = CLLocationCoordinate2D(latitude: 0, longitude: 95)
    let to = CLLocationCoordinate2D(latitude: 0, longitude: -90)
    let mid = CLLocationCoordinate2D(latitude: 0, longitude: -177.5)
    assertInterpolate(from: from, to: to, mid: mid, accuracy: 1e-14)
  }

  func testInterpolateLAToNYC() {
    let from = CLLocationCoordinate2D(latitude: 34.122222, longitude: 118.4111111)
    let to = CLLocationCoordinate2D(latitude: 40.66972222, longitude: 73.94388889)
    let mid = CLLocationCoordinate2D(latitude: 39.5470786039, longitude: 97.2015133919)
    assertInterpolate(from: from, to: to, mid: mid, accuracy: 1e-11)
  }

  func testInterpolateConstantLongitude() {
    let from = CLLocationCoordinate2D(latitude: -10, longitude: 20)
    let to = CLLocationCoordinate2D(latitude: 30, longitude: 20)
    let mid = CLLocationCoordinate2D(latitude: 10, longitude: 20)
    assertInterpolate(from: from, to: to, mid: mid, accuracy: 1e-14)
  }

  func testInterpolateAcrossPole() {
    let from = CLLocationCoordinate2D(latitude: 60, longitude: 20)
    let to = CLLocationCoordinate2D(latitude: 80, longitude: -160)
    let mid = CLLocationCoordinate2D(latitude: 80, longitude: 20)
    assertInterpolate(from: from, to: to, mid: mid, accuracy: 1e-14)
  }

  private func assertInterpolate(
    from: CLLocationCoordinate2D,
    to: CLLocationCoordinate2D,
    mid: CLLocationCoordinate2D, accuracy: Double
  ) {
    assertCoordsEqual(mid, from.interpolate(to: to, fraction: 0.5), accuracy: accuracy)
    assertCoordsEqual(from, from.interpolate(to: to, fraction: 0), accuracy: accuracy)
    assertCoordsEqual(to, from.interpolate(to: to, fraction: 1), accuracy: accuracy)
    assertCoordsEqual(to, from.interpolate(to: mid, fraction: 2), accuracy: accuracy)
    assertCoordsEqual(from, to.interpolate(to: mid, fraction: 2), accuracy: accuracy)
  }
}
