/* Copyright (c) 2020 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import XCTest
@testable import GoogleMapsUtils

class GMUWeightedLatLngTest: XCTestCase {

  var weightedLatLng    : GMUWeightedLatLng!
  var kCoordinate       : CLLocationCoordinate2D!
  var kIntensity        : Float!
  
  override func setUp() {
    weightedLatLng = GMUWeightedLatLng()
    kCoordinate = CLLocationCoordinate2DMake(10.456, 98.122)
    kIntensity = 10.0
  }
  
  override func tearDown() {
    weightedLatLng = nil
    kCoordinate = nil
    kIntensity = nil
  }
  
  func testInitWithCoordinate() {
    weightedLatLng = GMUWeightedLatLng(coordinate: kCoordinate, intensity: kIntensity)
    let mapPoint: GMSMapPoint = GMSProject(kCoordinate)
    XCTAssertEqual(weightedLatLng.intensity, kIntensity)
    XCTAssertEqual(weightedLatLng.point().x, mapPoint.x)
    XCTAssertEqual(weightedLatLng.point().y, mapPoint.y)
  }
  
}
