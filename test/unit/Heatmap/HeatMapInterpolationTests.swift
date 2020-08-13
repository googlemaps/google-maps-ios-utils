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
        let newGMU = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.86 , longitude: 145.20),
            intensity: 500
        )
        let newGMU2 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.85, longitude: 145.20),
            intensity: 20
        )
        let newGMU3 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -32, longitude: 145.20),
            intensity: 500
        )
        interpolationController.addWeightedLatLng(latlng: newGMU)
        interpolationController.addWeightedLatLng(latlng: newGMU2)
        interpolationController.addWeightedLatLng(latlng: newGMU3)
        var data = interpolationController.generateHeatMaps(n: 1)
        XCTAssertEqual(0, data.count)
        data = interpolationController.generateHeatMaps(n: 0.5)
        XCTAssertEqual(0, data.count)
        data = interpolationController.generateHeatMaps(n: 1.5)
        XCTAssertEqual(0, data.count)
        data = interpolationController.generateHeatMaps(n: 1.99)
        XCTAssertEqual(0, data.count)
    }

    func testWithTooLargeN() {
        let newGMU = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.86 , longitude: 145.20),
            intensity: 500
        )
        let newGMU2 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.85, longitude: 145.20),
            intensity: 20
        )
        let newGMU3 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -32, longitude: 145.20),
            intensity: 500
        )
        interpolationController.addWeightedLatLng(latlng: newGMU)
        interpolationController.addWeightedLatLng(latlng: newGMU2)
        interpolationController.addWeightedLatLng(latlng: newGMU3)
        var data = interpolationController.generateHeatMaps(n: 3)
        XCTAssertEqual(0, data.count)
        data = interpolationController.generateHeatMaps(n: 4)
        XCTAssertEqual(0, data.count)
        data = interpolationController.generateHeatMaps(n: 100)
        XCTAssertEqual(0, data.count)
        data = interpolationController.generateHeatMaps(n: 2.50000001)
        XCTAssertEqual(0, data.count)
    }

    func testWithAcceptableN() {
        let newGMU = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.86 , longitude: 145.20),
            intensity: 500
        )
        let newGMU2 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.85, longitude: 145.20),
            intensity: 20
        )
        let newGMU3 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -32, longitude: 145.20),
            intensity: 500
        )
        interpolationController.addWeightedLatLng(latlng: newGMU)
        interpolationController.addWeightedLatLng(latlng: newGMU2)
        interpolationController.addWeightedLatLng(latlng: newGMU3)
        var data = interpolationController.generateHeatMaps(n: 2)
        XCTAssertLessThan(0, data.count)
        data = interpolationController.generateHeatMaps(n: 2.4)
        XCTAssertLessThan(0, data.count)
        data = interpolationController.generateHeatMaps(n: 2.3)
        XCTAssertLessThan(0, data.count)
    }

    func testNoDataset() {
        let data = interpolationController.generateHeatMaps(n: 2)
        XCTAssertEqual(0, data.count)
    }

    func testMultipleCalls() {
        let newGMU = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.86 , longitude: 145.20),
            intensity: 500
        )
        let newGMU2 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.85, longitude: 145.20),
            intensity: 20
        )
        let newGMU3 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -32, longitude: 145.20),
            intensity: 500
        )
        interpolationController.addWeightedLatLng(latlng: newGMU)
        interpolationController.addWeightedLatLng(latlng: newGMU2)
        interpolationController.addWeightedLatLng(latlng: newGMU3)
        var data = interpolationController.generateHeatMaps(n: 2)
        let first = data.count
        data = interpolationController.generateHeatMaps(n: 2)
        XCTAssertEqual(first, data.count)
    }

    func testListOfPoints() {
        let newGMU = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.86 , longitude: 145.20),
            intensity: 500
        )
        let newGMU2 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.85, longitude: 145.20),
            intensity: 20
        )
        let newGMU3 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -32, longitude: 145.20),
            intensity: 500
        )
        let points = [newGMU, newGMU2, newGMU3]
        interpolationController.addWeightedLatLngs(latlngs: points)
        let data = interpolationController.generateHeatMaps(n: 2)
        XCTAssertLessThan(0, data.count)
    }

    func testDuplicatePoint() {
        let newGMU = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.86 , longitude: 145.20),
            intensity: 500
        )
        let points = [newGMU, newGMU, newGMU]
        interpolationController.addWeightedLatLngs(latlngs: points)
        let data = interpolationController.generateHeatMaps(n: 2)
        XCTAssertLessThan(0, data.count)
    }
}
