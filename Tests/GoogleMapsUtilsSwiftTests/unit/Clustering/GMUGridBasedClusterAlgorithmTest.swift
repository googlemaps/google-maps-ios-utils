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

final class GMUGridBasedClusterAlgorithmTest: GMUClusterAlgorithmTest {

    /// Test that at low zoom levels.
    ///
    func testClustersAtZoomLowZoomItemsGroupedIntoOneCluster() {
        let algorithm = GMUGridBasedClusterAlgorithm()
        let items = simpleClusterItems()
        algorithm.addItems(items)

        // At low zoom, there should be 1 cluster.
        let clusters = algorithm.clusters(atZoom: 3.0)
        guard let clusterItems = clusters[0] as? GMUStaticCluster else {
            return XCTFail("Clusters are not equivalent to GMUStaticCluster class")
        }
        XCTAssertEqual(clusters.count, 1)
        XCTAssertEqual(clusterItems.items.count, 4)
    }

    /// Test that at high zoom levels.
    ///
    func testClustersAtZoomHighZoomItemsGroupedIntoMultipleClusters() {
        let algorithm = GMUGridBasedClusterAlgorithm()
        let items = simpleClusterItems()
        algorithm.addItems(items)

        let clusters = algorithm.clusters(atZoom: 10)
        guard let _ = clusters[0] as? GMUStaticCluster else {
            return XCTFail("Clusters are not equivalent to GMUStaticCluster class")
        }
        XCTAssertEqual(clusters.count, 4)
        for i in 0..<clusters.count {
            XCTAssertEqual(clusters[i].items.count, 1)
        }
        assertValidClusters(clusters)
    }
}
