// Copyright 2024 Google LLC
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
import CoreLocation

@testable import GoogleMapsUtils

class GMUSimpleClusterAlgorithmTest: XCTestCase {

    // MARK: - Properties
    private var clustersCount: Int!
    private var zoom: Float!
    var mockItem: GMUTestClusterItem!
    private let kLocation1 = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    private let kLocation2 = CLLocationCoordinate2D(latitude: 17.7749, longitude: -112.4194)
    private let kLocation3 = CLLocationCoordinate2D(latitude: 27.7749, longitude: -102.4194)
    private let kLocation4 = CLLocationCoordinate2D(latitude: 7.7749, longitude: -112.4194)

    // MARK: - Setup()
    override func setUp() {
        clustersCount = 10
        zoom = 3
        mockItem = GMUTestClusterItem(position: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194))
        super.setUp()
    }

    // MARK: - Teardown
    override func tearDown() {
        clustersCount = nil
        zoom = nil
        mockItem = nil
        super.tearDown()
    }

    // MARK: - Tests
    func testClustersAtZoomWithDefaultClusterCount() {
        // Arrange.
        let simpleClusterAlgorithm = GMUSimpleClusterAlgorithm()
        simpleClusterAlgorithm.addItems(self.simpleClusterItems())
        simpleClusterAlgorithm.addItems(self.simpleClusterItems())
        simpleClusterAlgorithm.addItems(self.simpleClusterItems())
        // Act.
        let clusterItems = simpleClusterAlgorithm.clusters(atZoom: zoom)
        // Assert.
        XCTAssertEqual(clustersCount, clusterItems.count)
    }

    func testClustersAtZoomWithClearingClusterItems() {
        // Arrange.
        let simpleClusterAlgorithm = GMUSimpleClusterAlgorithm()
        simpleClusterAlgorithm.addItems(self.simpleClusterItems())
        simpleClusterAlgorithm.addItems(self.simpleClusterItems())
        simpleClusterAlgorithm.clearItems()
        // Act.
        let clusters = simpleClusterAlgorithm.clusters(atZoom: zoom)
        // Assert.
        XCTAssertEqual(0, clusters.count)
        XCTAssertNotEqual(clustersCount, clusters.count)
    }

    func testRemoveItem() {
        // Arrange.
        let simpleClusterAlgorithm = GMUSimpleClusterAlgorithm()
        // Act.
        simpleClusterAlgorithm.testClusterItems = [mockItem]
        // Assert.
        XCTAssertEqual(simpleClusterAlgorithm.testClusterItems.count, 1, "Initial count should be 1")
        // Act.
        simpleClusterAlgorithm.removeItem(mockItem)
        // Assert.
        XCTAssertEqual(simpleClusterAlgorithm.testClusterItems.count, 0, "Item should be removed from clusterItems")
    }

    // MARK: - Fixtures
    /// Generates a fixed number of items for simple test cases.
    /// Returns an array of simple cluster items.
    ///
    func simpleClusterItems() -> [GMUClusterItem] {
        var items = [GMUClusterItem]()
        items.append(item(at: kLocation1))
        items.append(item(at: kLocation2))
        items.append(item(at: kLocation3))
        items.append(item(at: kLocation4))
        return items
    }

    /// Creates a cluster item at a given location.
    ///
    func item(at location: CLLocationCoordinate2D) -> GMUClusterItem {
        /// Placeholder: Replace with actual implementation to create GMUClusterItem at location.
        return GMUTestClusterItem(position: location)
    }
}


