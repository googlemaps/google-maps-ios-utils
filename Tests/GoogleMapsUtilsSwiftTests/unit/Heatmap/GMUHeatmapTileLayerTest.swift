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
import GoogleMaps

@testable import GoogleMapsUtils

class GMUHeatmapTileLayerTest: XCTestCase {
  
  private var startPoints: [CGFloat]!
  private var colorMapSize: Int!
  private var gradientColor: [UIColor]!
  private var firstTestCoordinate: CLLocationCoordinate2D!
  private var secondTestCoordinate: CLLocationCoordinate2D!

  override func setUp() {
    super.setUp()
    startPoints = [0.2, 1.0]
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
    let heatmapTileLayer = GMUHeatmapTileLayer1()
    heatmapTileLayer.gradient = try! GMUGradient1(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
    XCTAssertEqual(gradientColor, heatmapTileLayer.gradient.colors)
  }
  
  func testHeatMapTileLayerDataPoints() {
    let intensity: Float = 10.0
    let radius: Int = 20
    let minimumZoomIntensity: Int = 5
    let maximumZoomIntensity: Int = 10
    let mapsAPIKey: String = "randomGoogleMapsAPIKey"
    let cameraLatitude: Double = -33.8
    let cameraLongitude: Double = 151.2
    let weightedData: [GMUWeightedLatLng1] = [GMUWeightedLatLng1(coordinate: secondTestCoordinate, intensity: intensity), GMUWeightedLatLng1(coordinate: firstTestCoordinate, intensity: intensity)]
    GMSServices.provideAPIKey(mapsAPIKey)
    let heatmapTileLayer = GMUHeatmapTileLayer1()
    heatmapTileLayer.gradient = try! GMUGradient1(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
    heatmapTileLayer.weightedData = [GMUWeightedLatLng1(coordinate: firstTestCoordinate, intensity: intensity), GMUWeightedLatLng1(coordinate: secondTestCoordinate, intensity: intensity)]
    heatmapTileLayer.radius = 20
    heatmapTileLayer.minimumZoomIntensity = 5
    heatmapTileLayer.maximumZoomIntensity = 10
    let camera = GMSCameraPosition.camera(withLatitude: cameraLatitude, longitude: cameraLongitude, zoom: 4)
    let options = GMSMapViewOptions()
    options.camera = camera
    heatmapTileLayer.map = nil
    XCTAssertEqual(gradientColor, heatmapTileLayer.gradient.colors)
    XCTAssertNotEqual(weightedData, heatmapTileLayer.weightedData!)
    XCTAssertEqual(radius, heatmapTileLayer.radius)
    XCTAssertEqual(minimumZoomIntensity, heatmapTileLayer.minimumZoomIntensity)
    XCTAssertEqual(maximumZoomIntensity, heatmapTileLayer.maximumZoomIntensity)
  }
  
  func testTileLayerForMinXLessThanMinusOneWithNotNilUIImage() {
    let heatmapTileLayer = GMUHeatmapTileLayer1()
      /// Set the bounds in the data.
      let bounds: GQTBounds1 = heatmapTileLayer.calculateBounds()
      /// Calculate bounds and initialize the QuadTree with those bounds.
      let quadTree = GQTPointQuadTree1(bounds: bounds)

      /// Add all weighted data points to the QuadTree.
      if let weightedData = heatmapTileLayer.weightedData {
          for dataPoint in weightedData {
              _ = quadTree.add(item: dataPoint)
          }
      }
      let data = GMUHeatmapTileCreationData1(bounds: bounds, radius: heatmapTileLayer.radius, colorMap: heatmapTileLayer.gradient.generateColorMap(), maxIntensities: heatmapTileLayer.calculateIntensities(), kernel: heatmapTileLayer.generateKernel())
    heatmapTileLayer.tileCreationData = data
      heatmapTileLayer.prepare()
    XCTAssertNotNil(heatmapTileLayer.tileFor(x: 0.1, y: 0.1, zoom: 0))
  }
  
  func testTileLayerForMaxXGreaterThanOneWithNotNilUIImage() {
    let heatmapTileLayer = GMUHeatmapTileLayer1()
      XCTAssertNotNil(heatmapTileLayer.tileFor(x: 10.0, y: 10.0, zoom: 0.0))
  }
  
}
