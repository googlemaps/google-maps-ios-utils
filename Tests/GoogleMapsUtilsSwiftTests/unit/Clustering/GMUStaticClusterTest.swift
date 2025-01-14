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

@testable import GoogleMapsUtils

// Sample coordinate constant.
let kClusterPosition = CLLocationCoordinate2D(latitude: -35, longitude: 151)

// Assuming GMUStaticCluster and GMUClusterItem are available in your Swift project.
final class GMUStaticClusterTest: XCTestCase {

    // Helper function to assert coordinates equality.
    func XCTAssertCoordsEqual(_ c1: CLLocationCoordinate2D, _ c2: CLLocationCoordinate2D, _ description: String) {
        XCTAssertEqual(c1.latitude, c2.latitude, description)
        XCTAssertEqual(c1.longitude, c2.longitude, description)
    }

    func XCTAssertItemsEqual(_ item1: GMUClusterItem1, _ item2: GMUClusterItem1, _ description: String = "") {
        XCTAssertEqual(item1.position.latitude, item2.position.latitude, description)
        XCTAssertEqual(item1.position.longitude, item2.position.longitude, description)
        XCTAssertEqual(item1.title, item2.title, description)
        XCTAssertEqual(item1.snippet, item2.snippet, description)
    }

    func testInitWithPosition() {
        let cluster = GMUStaticCluster1(position: kClusterPosition)
        XCTAssertCoordsEqual(cluster.position, kClusterPosition, "Cluster position failed to initialize.")
    }

    func testAddItem() {
        let cluster = GMUStaticCluster1(position: kClusterPosition)

        /// Add 1 item.
        /// Replace with appropriate mocking library.
        let item1 = MockGMUClusterItem(position: kClusterPosition, title: "Title1", snippet: "Snippet1")
        cluster.addItem(item1)
        XCTAssertEqual(cluster.count, 1)

        /// Add another item.
        /// Replace with appropriate mocking library.
        let item2 = MockGMUClusterItem(position: kClusterPosition, title: "Title2", snippet: "Snippet2")
        cluster.addItem(item2)
        XCTAssertEqual(cluster.count, 2)

        // Assert items are in added order.
        XCTAssertItemsEqual(cluster.items[0], item1, "Cluster items are different.")
        XCTAssertItemsEqual(cluster.items[1], item2, "Cluster items are different.")
    }

    func testRemoveItem() {
        let cluster = GMUStaticCluster1(position: kClusterPosition)

        let item1 = MockGMUClusterItem(position: kClusterPosition, title: "Title1", snippet: "Snippet1")
        let item2 = MockGMUClusterItem(position: kClusterPosition, title: "Title2", snippet: "Snippet2")

        // Add 1 item.
        cluster.addItem(item1)
        XCTAssertEqual(cluster.count, 1)

        // Remove item which does not exist is OK.
        cluster.removeItem(item2)
        XCTAssertEqual(cluster.count, 1)

        // Remove item1.
        cluster.removeItem(item1)
        XCTAssertEqual(cluster.count, 0)
    }
}
