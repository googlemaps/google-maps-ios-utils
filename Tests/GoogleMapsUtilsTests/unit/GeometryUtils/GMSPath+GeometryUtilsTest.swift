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

class GMSPathGeometryUtilsTest : XCTestCase {
  private let smallDiff = 5e-7 // About 5 cm on equator, half the default tolerance of defaultTolerance
  private let bigDiff = 2e-6 // About 10 cm on equator, double the default tolerance of defaultTolerance
  private let up = CLLocationCoordinate2D(latitude: 90, longitude: 0)
  private let down = CLLocationCoordinate2D(latitude: -90, longitude: 0)
  private let front = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  private let right = CLLocationCoordinate2D(latitude: 0, longitude: 90)
  private let back = CLLocationCoordinate2D(latitude: 0, longitude: -180)
  private let left = CLLocationCoordinate2D(latitude: 0, longitude: -90)
}

/// Tests for `area` and `signedArea`
extension GMSPathGeometryUtilsTest {
  func testArea() {
    let accuracy = 0.4
    XCTAssertEqual(
      .pi * pow(kGMSEarthRadius, 2),
      [right, up, front, down, right].gmsMutablePath.area(),
      accuracy: accuracy
    )
    XCTAssertEqual(
      .pi * pow(kGMSEarthRadius, 2),
      [right, down, front, up, right].gmsMutablePath.area(),
      accuracy: accuracy
    )
  }


  func testSignedArea() {
    let accuracy = 1e-6

    let path1 = [
      CLLocationCoordinate2D(latitude: 0, longitude: 0),
      CLLocationCoordinate2D(latitude: 0, longitude: 0.1),
      CLLocationCoordinate2D(latitude: 0.1, longitude: 0.1)
    ].gmsMutablePath
    XCTAssertEqual((pow(0.1.radians, 2) / 2), path1.signedArea(radius: 1), accuracy: accuracy)

    let path2 = [right, up, front].gmsMutablePath
    XCTAssertEqual(.pi / 2, path2.signedArea(radius: 1), accuracy: accuracy)

    let path3 = [front, up, right].gmsMutablePath
    XCTAssertEqual(-.pi / 2, path3.signedArea(radius: 1), accuracy: accuracy)

    XCTAssertEqual(
      -[right, up, front, down, right].gmsMutablePath.signedArea(),
      [right, down, front, up, right].gmsMutablePath.signedArea(),
      accuracy: 0
    )
  }
}

/// Tests for `contains(coordinate:, geodesic:)`
extension GMSPathGeometryUtilsTest {

  func testContainsEmptyPath() {
    let path = GMSMutablePath()
    let testPoint = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    path.shouldContain(expected: false, coordinate: testPoint)
  }

  func testContainsOnePoint() {
    let path = GMSMutablePath()
    let testPoint = CLLocationCoordinate2D(latitude: 1, longitude: 2)
    path.add(testPoint)
    path.shouldContain(expected: true, coordinate: testPoint)
    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
  }

  func testContainsTwoPoints() {
    let path = GMSMutablePath()
    let point1 = CLLocationCoordinate2D(latitude: 1, longitude: 2)
    let point2 = CLLocationCoordinate2D(latitude: 3, longitude: 5)
    path.add(point1)
    path.add(point2)

    path.shouldContain(expected: true, coordinate: point1)
    path.shouldContain(expected: true, coordinate: point2)

    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 40, longitude: 4))
  }

  func testContainsTriangle() {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 10, longitude: 12))
    path.add(CLLocationCoordinate2D(latitude: 20, longitude: 5))

    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 12))
    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 11))
    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 19, longitude: 5))

    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 1))
    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 11, longitude: 12))
    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 30, longitude: 5))
    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: -180))
    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 90))
  }

  func testContainsNorthPole() {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 89, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 89, longitude: 120))
    path.add(CLLocationCoordinate2D(latitude: 89, longitude: -120))

    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 90, longitude: 0))
    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 90, longitude: 180))
    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 90, longitude: -90))

    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: -90, longitude: 0))
    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
  }

  func testContainsSouthPole() {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: -89, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: -89, longitude: 120))
    path.add(CLLocationCoordinate2D(latitude: -89, longitude: -120))

    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 90, longitude: 0))
    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 90, longitude: 180))
    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 90, longitude: -90))
    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))

    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: -90, longitude: 0))
    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: -90, longitude: 90))
  }

  func testContainsMeridianEquator() {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 5, longitude: 10))
    path.add(CLLocationCoordinate2D(latitude: 10, longitude: 10))
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 20))
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: -10))

    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 2.5, longitude: 10))
    path.shouldContain(expected: true, coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 0))

    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 15, longitude: 10))
    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: -15))
    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 25))
    path.shouldContain(expected: false, coordinate: CLLocationCoordinate2D(latitude: -1, longitude: 0))
  }
}

/// Tests for `isOnPath(coordinate:, geodesic:, tolerance: )`
extension GMSPathGeometryUtilsTest {

  func testIsOnPathEmpty() {
    let path = GMSMutablePath()
    path.shouldBeOnPath(expected: false, CLLocationCoordinate2D(latitude: 0, longitude: 0))
  }

  func testIsOnPathSinglePoint() {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 1, longitude: 2))

    path.shouldBeOnPath(expected: true, CLLocationCoordinate2D(latitude: 1, longitude: 2))
    path.shouldBeOnPath(expected: false, CLLocationCoordinate2D(latitude: 3, longitude: 5))
  }

  func testIsOnPathEndpoints() {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 1, longitude: 2))
    path.add(CLLocationCoordinate2D(latitude: 3, longitude: 5))

    path.shouldBeOnPath(expected: true, CLLocationCoordinate2D(latitude: 1, longitude: 2))
    path.shouldBeOnPath(expected: true, CLLocationCoordinate2D(latitude: 3, longitude: 5))

    path.shouldBeOnPath(expected: false, CLLocationCoordinate2D(latitude: 0, longitude: 0))
  }

  func testIsOnPathEquator() {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 90))
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 180))

    path.shouldBeOnPath(
      expected: true,
      CLLocationCoordinate2D(latitude: 0, longitude: 90 - smallDiff),
      CLLocationCoordinate2D(latitude: 0, longitude: 90 + smallDiff),
      CLLocationCoordinate2D(latitude: 0 - smallDiff, longitude: 90),
      CLLocationCoordinate2D(latitude: 0, longitude: 135),
      CLLocationCoordinate2D(latitude: smallDiff, longitude: 135)
    )

    path.shouldBeOnPath(
      expected: false,
      CLLocationCoordinate2D(latitude: 0, longitude: 90 - bigDiff),
      CLLocationCoordinate2D(latitude: 0, longitude: 0),
      CLLocationCoordinate2D(latitude: 0, longitude: -90),
      CLLocationCoordinate2D(latitude: bigDiff, longitude: 135)
    )
  }

  func testIsOnPathEndsOnSameLatitude() {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: -45, longitude: -180))
    path.add(CLLocationCoordinate2D(latitude: -45, longitude: -smallDiff))

    path.shouldBeOnPath(
      expected: true,
      CLLocationCoordinate2D(latitude: -45, longitude: 180 + smallDiff),
      CLLocationCoordinate2D(latitude: -45, longitude: 180 - smallDiff),
      CLLocationCoordinate2D(latitude: -45 - smallDiff, longitude: 180 - smallDiff),
      CLLocationCoordinate2D(latitude: -45, longitude: 0)
    )

    path.shouldBeOnPath(
      expected: false,
      CLLocationCoordinate2D(latitude: -45, longitude: bigDiff),
      CLLocationCoordinate2D(latitude: -45, longitude: 180 - bigDiff),
      CLLocationCoordinate2D(latitude: -45 + bigDiff, longitude: -90),
      CLLocationCoordinate2D(latitude: -45, longitude: 90)
    )
  }

  func testIsOnPathMeridian() {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: -10, longitude: 30))
    path.add(CLLocationCoordinate2D(latitude: 45, longitude: 30))

    path.shouldBeOnPath(
      expected: true,
      CLLocationCoordinate2D(latitude: 10, longitude: 30 - smallDiff),
      CLLocationCoordinate2D(latitude: 20, longitude: 30 + smallDiff),
      CLLocationCoordinate2D(latitude: -10 - smallDiff, longitude: 30 + smallDiff)
    )

    path.shouldBeOnPath(
      expected: false,
      CLLocationCoordinate2D(latitude: -10 - bigDiff, longitude: 30),
      CLLocationCoordinate2D(latitude: 10, longitude: -150),
      CLLocationCoordinate2D(latitude: 0, longitude: 30 - bigDiff)
    )
  }

  func testIsOnPathSlantedCloseToMeridian() {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 90 - smallDiff, longitude: 0 + bigDiff))

    path.shouldBeOnPath(
      expected: true,
      CLLocationCoordinate2D(latitude: 1, longitude: smallDiff),
      CLLocationCoordinate2D(latitude: 2, longitude: -smallDiff),
      CLLocationCoordinate2D(latitude: 90 - smallDiff, longitude: -90),
      CLLocationCoordinate2D(latitude: 90 - smallDiff, longitude: 10)
    )

    path.shouldBeOnPath(
      expected: false,
      CLLocationCoordinate2D(latitude: -bigDiff, longitude: 0),
      CLLocationCoordinate2D(latitude: 90 - bigDiff, longitude: 180),
      CLLocationCoordinate2D(latitude: 10, longitude: bigDiff)
    )
  }

  func testIsOnPathArcGreaterThan120Degrees() {
    let path1 = GMSMutablePath()
    path1.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path1.add(CLLocationCoordinate2D(latitude: 0, longitude: 179.999))

    path1.shouldBeOnPath(
      expected: true,
      CLLocationCoordinate2D(latitude: 0, longitude: 90),
      CLLocationCoordinate2D(latitude: 0, longitude: smallDiff),
      CLLocationCoordinate2D(latitude: 0, longitude: 179),
      CLLocationCoordinate2D(latitude: smallDiff, longitude: 90)
    )

    path1.shouldBeOnPath(
      expected: false,
      CLLocationCoordinate2D(latitude: 0, longitude: -90),
      CLLocationCoordinate2D(latitude: smallDiff, longitude: -100),
      CLLocationCoordinate2D(latitude: 0, longitude: 180),
      CLLocationCoordinate2D(latitude: 0, longitude: -bigDiff),
      CLLocationCoordinate2D(latitude: 90, longitude: 0),
      CLLocationCoordinate2D(latitude: -90, longitude: 180)
    )

    let path2 = GMSMutablePath()
    path2.add(CLLocationCoordinate2D(latitude: 10, longitude: 5))
    path2.add(CLLocationCoordinate2D(latitude: 30, longitude: 15))

    // Test slanted. The test-points below are on the lat/long line not Rhumb, but it approximates
    // the Rhumb segment well enough close to the edges.
    path2.shouldBeOnPath(
      expected: true,
      CLLocationCoordinate2D(latitude: 10 + 2 * bigDiff, longitude: 5 + bigDiff),
      CLLocationCoordinate2D(latitude: 10 + bigDiff, longitude: 5 + bigDiff / 2),
      CLLocationCoordinate2D(latitude: 30 - 2 * bigDiff, longitude: 15 - bigDiff)
    )

    path2.shouldBeOnPath(
      expected: false,
      CLLocationCoordinate2D(latitude: 20, longitude: 10),
      CLLocationCoordinate2D(latitude: 10 - bigDiff, longitude: 5 - bigDiff / 2),
      CLLocationCoordinate2D(latitude: 30 + 2 * bigDiff, longitude: 15 + bigDiff),
      CLLocationCoordinate2D(latitude: 10 + 2 * bigDiff, longitude: 5),
      CLLocationCoordinate2D(latitude: 10, longitude: 5 + bigDiff)
    )

    let path3 = GMSMutablePath()
    path3.add(CLLocationCoordinate2D(latitude: 90 - smallDiff, longitude: 0))
    path3.add(CLLocationCoordinate2D(latitude: 0, longitude: 180 - smallDiff / 2))

    // Tricky. Almost vertical segment in Rhumb-space, with the point close to the segment
    // "over the 180 edge", but not closest to the end.
    // The point is close to equator so that the "vertical distance" is not compressed by the
    // inverse mercator transform.
    path3.shouldBeOnPath(
      expected: true,
      CLLocationCoordinate2D(latitude: bigDiff, longitude: -180 - smallDiff / 2),
      CLLocationCoordinate2D(latitude: bigDiff, longitude: 180 - smallDiff / 4),
      CLLocationCoordinate2D(latitude: bigDiff, longitude: 180 - smallDiff)
    )

    path3.shouldBeOnPath(
      expected: false,
      CLLocationCoordinate2D(latitude: -bigDiff, longitude: -180 + smallDiff / 2),
      CLLocationCoordinate2D(latitude: -bigDiff, longitude: 180),
      CLLocationCoordinate2D(latitude: -bigDiff, longitude: 180 - smallDiff)
    )
  }

  func testIsOnPathCloseToNorthPole() {
    // Reaching close to North pole.
    let path1 = GMSMutablePath()
    path1.add(CLLocationCoordinate2D(latitude: 80, longitude: 0))
    path1.add(CLLocationCoordinate2D(latitude: 80, longitude: 180 - smallDiff))

    XCTAssertTrue(
      path1.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 90 - smallDiff, longitude: -90), geodesic: true)
    )
    XCTAssertTrue(
      path1.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 90, longitude: -135), geodesic: true)
    )
    XCTAssertTrue(
      path1.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 80 - smallDiff, longitude: 0), geodesic: true)
    )
    XCTAssertTrue(
      path1.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 80 + smallDiff, longitude: 0), geodesic: true)
    )

    XCTAssertFalse(
      path1.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 80, longitude: 90), geodesic: true)
    )
    XCTAssertFalse(
      path1.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 79, longitude: bigDiff), geodesic: true)
    )

    let path2 = GMSMutablePath()
    path2.add(CLLocationCoordinate2D(latitude: 80, longitude: 0))
    path2.add(CLLocationCoordinate2D(latitude: 80, longitude: 180 - smallDiff))

    XCTAssertTrue(
      path2.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 80 - smallDiff, longitude: 0), geodesic: false)
    )
    XCTAssertTrue(
      path2.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 80 + smallDiff, longitude: 0), geodesic: false)
    )
    XCTAssertTrue(
      path2.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 80, longitude: 90), geodesic: false)
    )

    XCTAssertFalse(
      path2.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 79, longitude: bigDiff), geodesic: false)
    )
    XCTAssertFalse(
      path2.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 90 - smallDiff, longitude: -90), geodesic: false)
    )
    XCTAssertFalse(
      path2.isOnPath(coordinate: CLLocationCoordinate2D(latitude: 90, longitude: -135), geodesic: false)
    )
  }
}

fileprivate extension GMSPath {
  func shouldContain(expected: Bool, coordinate: CLLocationCoordinate2D) {
    XCTAssertEqual(expected, contains(coordinate: coordinate, geodesic: true))
    XCTAssertEqual(expected, contains(coordinate: coordinate, geodesic: false))
  }

  func shouldBeOnPath(
    expected: Bool,
    _ coordinates: CLLocationCoordinate2D...,
    tolerance: Double = defaultToleranceInMeters
  ) {
    // TODO need to add a test case where coordinate is on path only when geodesic is true, and vice versa.
    for coord in coordinates {
      XCTAssertEqual(expected, isOnPath(coordinate: coord, geodesic: true, tolerance: tolerance))
      XCTAssertEqual(expected, isOnPath(coordinate: coord, geodesic: false, tolerance: tolerance))
    }
  }
}
