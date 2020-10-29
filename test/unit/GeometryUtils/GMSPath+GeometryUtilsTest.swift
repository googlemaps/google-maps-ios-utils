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
