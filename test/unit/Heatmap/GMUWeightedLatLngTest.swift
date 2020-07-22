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
  
  private var coordinate: CLLocationCoordinate2D!
  private var intensity: Float!
  
  override func setUp() {
    super.setUp()
    coordinate = CLLocationCoordinate2DMake(10.456, 98.122)
    intensity = 11.0
  }
  
  override func tearDown() {
    coordinate = nil
    intensity = nil
    super.tearDown()
  }
  
  func testInitWithCoordinate() {
    let weightedLatLng = GMUWeightedLatLng(coordinate: coordinate, intensity: intensity)
    let mapPoint: GMSMapPoint = GMSProject(coordinate)
    XCTAssertEqual(weightedLatLng.intensity, intensity)
    XCTAssertEqual(weightedLatLng.point().x, mapPoint.x)
    XCTAssertEqual(weightedLatLng.point().y, mapPoint.y)
  }
  
}
