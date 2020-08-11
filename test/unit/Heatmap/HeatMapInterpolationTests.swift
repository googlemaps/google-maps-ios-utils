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
@testable import HeatMapInterpolation
@testable import GoogleMapsUtils

class HeatMapInterpolationTests: XCTestCase {

    private var gradientColor: [UIColor]!
    private var startPoints: [NSNumber]!
    private var colorMapSize: UInt!
    
    private let interpolationController = HeatMapInterpolationPoints()
    private let mapView = GMSMapView()
    
    override func setUp() {
        super.setUp()
        gradientColor = [
            UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
            UIColor(red: 1.0, green: 0, blue: 0, alpha: 1)
        ]
        startPoints = [0.005, 0.7] as [NSNumber]
        colorMapSize = 3
    }
    
    func testInitWithColors() {
        let gradient = GMUGradient(
            colors: gradientColor,
            startPoints: startPoints,
            colorMapSize: colorMapSize
        )
        XCTAssertEqual(gradient.colors.count, gradient.startPoints.count)
    }
    
    func testWithTooSmallN() {
        interpolationController.setData(file: "dataset")
        interpolationController.generateHeatMaps(mapView: mapView, n: 1)
        XCTAssertEqual(0, interpolationController.heatMapPoints.count)
        interpolationController.generateHeatMaps(mapView: mapView, n: 0.5)
        XCTAssertEqual(0, interpolationController.heatMapPoints.count)
        interpolationController.generateHeatMaps(mapView: mapView, n: 1.5)
        XCTAssertEqual(0, interpolationController.heatMapPoints.count)
        interpolationController.generateHeatMaps(mapView: mapView, n: 1.99)
        XCTAssertEqual(0, interpolationController.heatMapPoints.count)
    }
    
    func testWithTooLargeN() {
        interpolationController.setData(file: "dataset")
        interpolationController.generateHeatMaps(mapView: mapView, n: 3)
        XCTAssertEqual(0, interpolationController.heatMapPoints.count)
        interpolationController.generateHeatMaps(mapView: mapView, n: 4)
        XCTAssertEqual(0, interpolationController.heatMapPoints.count)
        interpolationController.generateHeatMaps(mapView: mapView, n: 100)
        XCTAssertEqual(0, interpolationController.heatMapPoints.count)
        interpolationController.generateHeatMaps(mapView: mapView, n: 2.50000001)
        XCTAssertEqual(0, interpolationController.heatMapPoints.count)
    }
    
    func testWithAcceptableN() {
        interpolationController.setData(file: "dataset")
        interpolationController.generateHeatMaps(mapView: mapView, n: 2)
        XCTAssertLessThan(0, interpolationController.heatMapPoints.count)
        interpolationController.generateHeatMaps(mapView: mapView, n: 3)
        XCTAssertLessThan(0, interpolationController.heatMapPoints.count)
        interpolationController.generateHeatMaps(mapView: mapView, n: 4)
        XCTAssertLessThan(0, interpolationController.heatMapPoints.count)
    }
    
    func testNoDataset() {
        interpolationController.generateHeatMaps(mapView: mapView, n: 2)
        XCTAssertEqual(0, interpolationController.heatMapPoints.count)
    }
    
    func testInvalidDataset() {
        interpolationController.setData(file: "bOgUS")
        interpolationController.generateHeatMaps(mapView: mapView, n: 2)
        XCTAssertEqual(0, interpolationController.heatMapPoints.count)
    }
    
    func testManualDataInput() {
        let data = [[12.5, 18.5], [12.4, 18.4]]
        interpolationController.addPoints(pointList: data)
        interpolationController.generateHeatMaps(mapView: mapView, n: 2)
        XCTAssertLessThan(0, interpolationController.heatMapPoints.count)
    }
    
    func testMultipleCalls() {
        interpolationController.setData(file: "dataset")
        interpolationController.generateHeatMaps(mapView: mapView, n: 2)
        let first = interpolationController.heatMapPoints.count
        interpolationController.generateHeatMaps(mapView: mapView, n: 2)
        XCTAssertEqual(first, interpolationController.heatMapPoints.count)
    }
}
