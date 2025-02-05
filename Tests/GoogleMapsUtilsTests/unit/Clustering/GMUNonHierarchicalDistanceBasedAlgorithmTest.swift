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

class GMUNonHierarchicalDistanceBasedAlgorithmTest: GMUClusterAlgorithmTest {

    /// Test that at low zoom levels, all items are grouped into one cluster.
    ///
    func testClustersAtZoomLowZoomItemsGroupedIntoOneCluster() {
        let items = simpleClusterItems()

        /// Act
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        algorithm.addItems(items)
        let clusters = algorithm.clusters(atZoom: 4)

        /// Assert
        XCTAssertEqual(clusters.count, 1)
        XCTAssertEqual(totalItemCountsForClusters(clusters), items.count)
    }

    /// Test that at high zoom levels, items are grouped into multiple clusters.
    ///
    func testClustersAtZoomHighZoomItemsGroupedIntoMultipleClusters() {
        let items = simpleClusterItems()

        /// Act
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        algorithm.addItems(items)
        let clusters = algorithm.clusters(atZoom: 14)

        /// Assert
        XCTAssertEqual(clusters.count, 4)
        XCTAssertEqual(totalItemCountsForClusters(clusters), items.count)
    }

    /// Generates a bunch of random points around a number of "centroids", then shuffle them up and
    /// verify number of clusters should be equal to number of centroids.
    ///
    func testClustersAtZoomRandomClusters() {
        /// Arrange
        let items = randomizedClusterItems()

        /// Act
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        algorithm.addItems(items)
        var clusters = algorithm.clusters(atZoom: 10)

        /// Assert
        XCTAssertEqual(clusters.count, 4)
        XCTAssertEqual(totalItemCountsForClusters(clusters), items.count)
        for cluster in clusters {
            XCTAssertEqual(cluster.items.count, items.count / 4)
        }
        assertValidClusters(clusters)

        /// Test at high zoom, should split into multiple clusters
        clusters = algorithm.clusters(atZoom: 18)

        /// Assert
        XCTAssertEqual(totalItemCountsForClusters(clusters), items.count)
        assertValidClusters(clusters)
    }

    /// Verifies that at high zoom levels, all clusters are distinct,
    /// and the total cluster size equals the input size.
    ///
    func testClustersProducesDistinctClustersAtHighZoom() {
        /// Arrange
        let items = randomizedClusterItems()

        /// Act
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        algorithm.addItems(items)
        let clusters = algorithm.clusters(atZoom: 18)

        /// Assert
        XCTAssertEqual(totalItemCountsForClusters(clusters), items.count)
        assertValidClusters(clusters)
    }
}
