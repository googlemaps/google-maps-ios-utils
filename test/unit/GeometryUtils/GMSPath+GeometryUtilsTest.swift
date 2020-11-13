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

class GMSPathGeometryutilsTest : XCTestCase {

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
extension GMSPathGeometryutilsTest {
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
extension GMSPathGeometryutilsTest {

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

fileprivate extension GMSPath {
  func shouldContain(expected: Bool, coordinate: CLLocationCoordinate2D) {
    XCTAssertEqual(expected, contains(coordinate: coordinate, geodesic: true))
    XCTAssertEqual(expected, contains(coordinate: coordinate, geodesic: false))
  }
}
