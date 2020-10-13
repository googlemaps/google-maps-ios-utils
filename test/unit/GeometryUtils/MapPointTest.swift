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

import CoreLocation
import XCTest
@testable import GoogleMapsUtils

class MapPointTest : XCTestCase {

  private let westCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: -180)
  private let eastCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 180)
  private let northCoordinate = CLLocationCoordinate2D(latitude: 80, longitude: 0)
  private let southCoordinate = CLLocationCoordinate2D(latitude: -80, longitude: 0)

  private let westMapPoint = MapPoint(x: -1, y: 0)
  private let eastMapPoint = MapPoint(x: 1, y: 0)
  private let northMapPoint = MapPoint(x: 0, y: 0.7754812)
  private let southMapPoint = MapPoint(x: 0, y: -0.7754812)

  private let mapPointPrecision = 1e-6
  private let latLngPrecision = 1e-6

  func testLocationMapPoint() {
    XCTAssertEqual(westMapPoint.x, westCoordinate.mapPoint.x, accuracy: mapPointPrecision)
    XCTAssertEqual(eastMapPoint.x, eastCoordinate.mapPoint.x, accuracy: mapPointPrecision)
    XCTAssertEqual(northMapPoint.y, northCoordinate.mapPoint.y, accuracy: mapPointPrecision)
    XCTAssertEqual(southMapPoint.y, southCoordinate.mapPoint.y, accuracy: mapPointPrecision)
  }

  func testMapPointLocation() {
    let westLocation = westMapPoint.location
    XCTAssertEqual(westCoordinate.latitude, westLocation.latitude, accuracy: latLngPrecision)
    XCTAssertEqual(westCoordinate.longitude, westLocation.longitude, accuracy: latLngPrecision)

    let eastLocation = eastMapPoint.location
    XCTAssertEqual(eastCoordinate.latitude, eastLocation.latitude, accuracy: latLngPrecision)
    XCTAssertEqual(eastCoordinate.longitude, eastLocation.longitude, accuracy: latLngPrecision)

    let northLocation = northMapPoint.location
    XCTAssertEqual(northCoordinate.latitude, northLocation.latitude, accuracy: latLngPrecision)
    XCTAssertEqual(northCoordinate.longitude, northLocation.longitude, accuracy: latLngPrecision)

    let southLocation = southMapPoint.location
    XCTAssertEqual(southCoordinate.latitude, southLocation.latitude, accuracy: latLngPrecision)
    XCTAssertEqual(southCoordinate.longitude, southLocation.longitude, accuracy: latLngPrecision)
  }

  func testDistance() {
    let a = MapPoint(x: -0.7, y: 1)
    let b = MapPoint(x: 0.9, y: 1)
    XCTAssertEqual(a.distance(to: b), 2 - (b.x - a.x), accuracy: mapPointPrecision)
  }

  func testInterpolate() {
    let a = MapPoint(x: -0.7, y: 1)
    let b = MapPoint(x: 0.9, y: 1)
    let c = MapPoint(x: -0.7, y: 0)
    XCTAssertEqual(
      a.x, MapPoint.interpolate(from: a, to: b, fraction: 0).x, accuracy: mapPointPrecision
    )
    XCTAssertEqual(
      b.x, MapPoint.interpolate(from: a, to: b, fraction: 1).x, accuracy: mapPointPrecision
    )
    XCTAssertEqual(
      (a.x + b.x - 2) / 2, MapPoint.interpolate(from: a, to: b, fraction: 0.5).x, accuracy: mapPointPrecision
    )
    XCTAssertEqual(
      (a.y + c.y) / 2, MapPoint.interpolate(from: a, to: c, fraction: 0.5).y, accuracy: mapPointPrecision
    )
  }
}
