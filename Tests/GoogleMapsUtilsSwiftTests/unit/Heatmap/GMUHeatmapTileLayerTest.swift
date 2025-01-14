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
    private var mockTileCreationData: GMUHeatmapTileCreationData1!
    private let heatmapTileLayer = GMUHeatmapTileLayer1()
    private let gmuTileSize: Int = 512

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
        // Mock valid tile creation data
        let mockPoints = [
            GQTPointQuadTreeItemMock(points: GQTPoint1(x: -0.5, y: 0.5)),
            GQTPointQuadTreeItemMock(points: GQTPoint1(x: 0.2, y: 0.3))
        ]
        let mockQuadTree = GQTPointQuadTreeMock()
        for point in mockPoints {
            _ = mockQuadTree.add(item: point)
        }
        mockTileCreationData = GMUHeatmapTileCreationData1(
            quadTree: mockQuadTree,
            bounds: GQTBounds1(minX: -1.0, minY: -1.0, maxX: 0.5, maxY: 0.5),
            radius: 0,
            minimumZoomIntensity: nil,
            maximumZoomIntensity: nil,
            colorMap: [UIColor.red, UIColor.green, UIColor.blue],
            maxIntensities: [10.0, 20.0, 30.0],
            kernel: Array(repeating: 1.0, count: 31) // Simplified kernel
        )
        heatmapTileLayer.tileCreationData = mockTileCreationData
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
        do {
            let gradient = try GMUGradient1(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
            heatmapTileLayer.gradient = gradient
            XCTAssertEqual(gradientColor, heatmapTileLayer.gradient?.colors)
        } catch {
            XCTFail("Failed to initialize GMUGradient1 with error: \(error)")
        }
    }

    func testHeatMapTileLayerDataPoints() {
        let intensity: Float = 10.0
        let modifiedIntensity: Float = 30.0
        let radius: Int = 20
        let minimumZoomIntensity: Int = 5
        let maximumZoomIntensity: Int = 10
        let mapsAPIKey: String = "randomGoogleMapsAPIKey"
        let cameraLatitude: Double = -33.8
        let cameraLongitude: Double = 151.2
        let weightedData: [GMUWeightedLatLng1] = [GMUWeightedLatLng1(coordinate: secondTestCoordinate, intensity: intensity), GMUWeightedLatLng1(coordinate: firstTestCoordinate, intensity: intensity)]
        GMSServices.provideAPIKey(mapsAPIKey)
        let heatmapTileLayer = GMUHeatmapTileLayer1()
        do {
            heatmapTileLayer.gradient = try GMUGradient1(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
        } catch {
            XCTFail("Failed to initialize GMUGradient1 with error: \(error)")
        }
        heatmapTileLayer.weightedData = [GMUWeightedLatLng1(coordinate: firstTestCoordinate, intensity: modifiedIntensity), GMUWeightedLatLng1(coordinate: secondTestCoordinate, intensity: modifiedIntensity)]
        heatmapTileLayer.radius = 20
        heatmapTileLayer.minimumZoomIntensity = 5
        heatmapTileLayer.maximumZoomIntensity = 10
        let camera = GMSCameraPosition.camera(withLatitude: cameraLatitude, longitude: cameraLongitude, zoom: 4)
        let options = GMSMapViewOptions()
        options.camera = camera
        heatmapTileLayer.map = nil
        XCTAssertEqual(gradientColor, heatmapTileLayer.gradient?.colors)
        XCTAssertNotEqual(weightedData[0].intensity, heatmapTileLayer.weightedData![0].intensity)
        XCTAssertEqual(radius, heatmapTileLayer.radius)
        XCTAssertEqual(minimumZoomIntensity, heatmapTileLayer.minimumZoomIntensity)
        XCTAssertEqual(maximumZoomIntensity, heatmapTileLayer.maximumZoomIntensity)
    }

    func testTileForWithValidInputs() {
        let result = heatmapTileLayer.tileFor(x: -1.0, y: 1.0, zoom: 1.0)
        XCTAssertNotNil(result, "Tile should not be nil for valid inputs.")
        XCTAssertEqual(result?.size.width, CGFloat(gmuTileSize), "Tile width should match the expected size.")
        XCTAssertEqual(result?.size.height, CGFloat(gmuTileSize), "Tile height should match the expected size.")
    }

    func testTileForWithEdgeCaseBounds() {
        let result = heatmapTileLayer.tileFor(x: -1.0, y: -1.0, zoom: 1.0)
        
        XCTAssertNotNil(result, "Tile should not be nil for edge case bounds.")
    }

    func testTileForHandlesWrappedPoints() {
        let result = heatmapTileLayer.tileFor(x: 0.0, y: 0.0, zoom: 1.0)
        
        XCTAssertNotNil(result, "Tile should be generated for wrapped points.")
    }
    
}
