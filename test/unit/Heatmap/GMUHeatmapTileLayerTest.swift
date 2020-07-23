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

class GMUHeatmapTileLayerTest: XCTestCase {
  
  private var startPoints: [NSNumber]!
  private var colorMapSize: UInt!
  private var gradientColor: [UIColor]!
  private var firstTestCoordinate: CLLocationCoordinate2D!
  private var secondTestCoordinate: CLLocationCoordinate2D!
  private var intensity: Float!
  private var cameraLatitude: Double!
  private var cameraLongitude: Double!
  private var mapsAPIKey: String!
  private var radius: UInt!
  private var minimumZoomIntensity: UInt!
  private var maximumZoomIntensity: UInt!
  
  override func setUp() {
    super.setUp()
    startPoints = [NSNumber(value: 0.2), NSNumber(value: 1.0)]
    colorMapSize = 3
    gradientColor = [
      UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
      UIColor(red: 1.0, green: 0, blue: 0, alpha: 1)
    ]
    firstTestCoordinate = CLLocationCoordinate2DMake(10.456, 98.122)
    secondTestCoordinate = CLLocationCoordinate2DMake(10.556, 98.422)
    intensity = 10.0
    cameraLatitude = -33.8
    cameraLongitude = 151.2
    radius = 20
    minimumZoomIntensity = 5
    maximumZoomIntensity = 10
    //Please provide your GMAP API Key here.
    mapsAPIKey = ""
  }
  
  override func tearDown() {
    gradientColor = nil
    startPoints = nil
    colorMapSize = nil
    firstTestCoordinate = nil
    secondTestCoordinate = nil
    intensity = nil
    cameraLatitude = nil
    cameraLongitude = nil
    mapsAPIKey = nil
    radius = nil
    minimumZoomIntensity = nil
    maximumZoomIntensity = nil
    super.tearDown()
  }
  
  func testInitWithValidGradientColorCount() {
    let heatmapTileLayer = GMUHeatmapTileLayer()
    heatmapTileLayer.gradient = GMUGradient(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
    XCTAssertEqual(heatmapTileLayer.gradient.colors.count, gradientColor.count)
  }
  
  func testHeatMapTileLayerDataPoints() {
    //Please provide your GMAP API key, to run the test case.
    guard let key = mapsAPIKey, !key.isEmpty else { return }
    GMSServices.provideAPIKey(mapsAPIKey)
    let heatmapTileLayer = GMUHeatmapTileLayer()
    heatmapTileLayer.gradient = GMUGradient(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
    heatmapTileLayer.weightedData = [GMUWeightedLatLng(coordinate: firstTestCoordinate, intensity: intensity), GMUWeightedLatLng(coordinate: secondTestCoordinate, intensity: intensity)]
    let camera = GMSCameraPosition.camera(withLatitude: cameraLatitude, longitude: cameraLongitude, zoom: 4)
    heatmapTileLayer.map = GMSMapView.map(withFrame: .zero, camera: camera)
    XCTAssertEqual(heatmapTileLayer.weightedData.count, 2)
    XCTAssertEqual(heatmapTileLayer.gradient.colors.count, 2)
    XCTAssertEqual(heatmapTileLayer.radius, radius)
    XCTAssertEqual(heatmapTileLayer.minimumZoomIntensity, minimumZoomIntensity)
    XCTAssertEqual(heatmapTileLayer.maximumZoomIntensity, maximumZoomIntensity)
  }
  
  func testTileLayerForMinXLessThanMinusOneWithNotNilUIImage() {
    let heatmapTileLayer = GMUHeatmapTileLayer()
    XCTAssertEqual(heatmapTileLayer.tileFor(x: UInt(0.1), y: UInt(0.1), zoom: 0), UIImage())
  }
  
  func testTileLayerForMaxXGreaterThanOneWithNotNilUIImage() {
    let heatmapTileLayer = GMUHeatmapTileLayer()
    XCTAssertEqual(heatmapTileLayer.tileFor(x: 10, y: 10, zoom: 0), UIImage())
  }
  
}
