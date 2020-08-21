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

class HeatMapInterpolationTests: XCTestCase {

    private var gradientColor: [UIColor]!
    private var startPoints: [NSNumber]!
    private var colorMapSize: UInt!
    
    private let interpolationController = HeatMapInterpolationPoints()
    
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
        do {
            _ = try interpolationController.generatePoints(influence: 1)
        } catch {
            print("\(error)")
            XCTAssertTrue(true)
        }
        do {
            _ = try interpolationController.generatePoints(influence: 0.5)
        } catch {
            print("\(error)")
            XCTAssertTrue(true)
        }
        do {
            _ = try interpolationController.generatePoints(influence: 1.9999999)
        } catch {
            print("\(error)")
            XCTAssertTrue(true)
        }
        do {
            _ = try interpolationController.generatePoints(influence: 1.5)
        } catch {
            print("\(error)")
            XCTAssertTrue(true)
        }
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
        do {
            _ = try interpolationController.generatePoints(influence: 2.500001)
        } catch {
            print("\(error)")
            XCTAssertTrue(true)
        }
        do {
            _ = try interpolationController.generatePoints(influence: 3)
        } catch {
            print("\(error)")
            XCTAssertTrue(true)
        }
        do {
            _ = try interpolationController.generatePoints(influence: 100000)
        } catch {
            print("\(error)")
            XCTAssertTrue(true)
        }
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
        do {
            let data = try interpolationController.generatePoints(influence: 2.4)
            XCTAssertLessThan(0, data.count)
        } catch {
            print("\(error)")
            XCTAssertTrue(false)
        }
        do {
            let data = try interpolationController.generatePoints(influence: 2.3)
            XCTAssertLessThan(0, data.count)
        } catch {
            print("\(error)")
            XCTAssertTrue(false)
        }
    }
    
    func testNoDataset() {
        do {
            let data = try interpolationController.generatePoints(influence: 2)
            XCTAssertEqual(0, data.count)
        } catch {
            print("\(error)")
            XCTAssertTrue(false)
        }
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
        do {
            var data = try interpolationController.generatePoints(influence: 2)
            let first = data.count
            data = try interpolationController.generatePoints(influence: 2)
            XCTAssertEqual(first, data.count)
        } catch {
            print("\(error)")
            XCTAssertTrue(false)
        }
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
        do {
            let data = try interpolationController.generatePoints(influence: 2.4)
            XCTAssertLessThan(0, data.count)
        } catch {
            print("\(error)")
            XCTAssertTrue(false)
        }
    }
    
    func testDuplicatePoint() {
        let newGMU = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.86 , longitude: 145.20),
            intensity: 500
        )
        let points = [newGMU, newGMU, newGMU]
        interpolationController.addWeightedLatLngs(latlngs: points)
        do {
            let data = try interpolationController.generatePoints(influence: 2.4)
            XCTAssertLessThan(0, data.count)
        } catch {
            print("\(error)")
            XCTAssertTrue(false)
        }
    }
}
