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
  
  override func setUp() {
    super.setUp()
    startPoints = [NSNumber(value: 0.2), NSNumber(value: 1.0)]
    colorMapSize = 3
    gradientColor = [
      UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
      UIColor(red: 1.0, green: 0, blue: 0, alpha: 1)
    ]
    firstTestCoordinate = CLLocationCoordinate2D(latitude: 10.456, longitude: 98.122)
    secondTestCoordinate = CLLocationCoordinate2D(latitude: 10.556, longitude: 98.422)
  }
  
  override func tearDown() {
    gradientColor = nil
    startPoints = nil
    colorMapSize = nil
    firstTestCoordinate = nil
    secondTestCoordinate = nil
    super.tearDown()
  }
  
  func testInitWithValidGradientColorCount() {
    let heatmapTileLayer = GMUHeatmapTileLayer()
    heatmapTileLayer.gradient = GMUGradient(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
    XCTAssertEqual(gradientColor, heatmapTileLayer.gradient.colors)
  }
  
  func testHeatMapTileLayerDataPoints() {
    let intensity: Float = 10.0
    let radius: UInt = 20
    let minimumZoomIntensity: UInt = 5
    let maximumZoomIntensity: UInt = 10
    let mapsAPIKey: String = "randomGoogleMapsAPIKey"
    let cameraLatitude: Double = -33.8
    let cameraLongitude: Double = 151.2
    let weightedData: [GMUWeightedLatLng] = [GMUWeightedLatLng(coordinate: secondTestCoordinate, intensity: intensity), GMUWeightedLatLng(coordinate: firstTestCoordinate, intensity: intensity)]
    GMSServices.provideAPIKey(mapsAPIKey)
    let heatmapTileLayer = GMUHeatmapTileLayer()
    heatmapTileLayer.gradient = GMUGradient(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
    heatmapTileLayer.weightedData = [GMUWeightedLatLng(coordinate: firstTestCoordinate, intensity: intensity), GMUWeightedLatLng(coordinate: secondTestCoordinate, intensity: intensity)]
    heatmapTileLayer.radius = 20
    heatmapTileLayer.minimumZoomIntensity = 5
    heatmapTileLayer.maximumZoomIntensity = 10
    let camera = GMSCameraPosition.camera(withLatitude: cameraLatitude, longitude: cameraLongitude, zoom: 4)
    heatmapTileLayer.map = GMSMapView.map(withFrame: .zero, camera: camera)
    XCTAssertEqual(gradientColor, heatmapTileLayer.gradient.colors)
    XCTAssertNotEqual(weightedData, heatmapTileLayer.weightedData)
    XCTAssertEqual(radius, heatmapTileLayer.radius)
    XCTAssertEqual(minimumZoomIntensity, heatmapTileLayer.minimumZoomIntensity)
    XCTAssertEqual(maximumZoomIntensity, heatmapTileLayer.maximumZoomIntensity)
  }
  
  func testTileLayerForMinXLessThanMinusOneWithNotNilUIImage() {
    let heatmapTileLayer = GMUHeatmapTileLayer()
    XCTAssertNotNil(heatmapTileLayer.tileFor(x: UInt(0.1), y: UInt(0.1), zoom: 0))
  }
  
  func testTileLayerForMaxXGreaterThanOneWithNotNilUIImage() {
    let heatmapTileLayer = GMUHeatmapTileLayer()
    XCTAssertNotNil(heatmapTileLayer.tileFor(x: 10, y: 10, zoom: 0))
  }
  
}
