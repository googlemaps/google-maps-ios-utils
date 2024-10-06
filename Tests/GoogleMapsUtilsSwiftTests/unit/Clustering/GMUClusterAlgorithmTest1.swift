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

/// Base class for cluster algorithm tests.
///
class GMUClusterAlgorithmTest1: XCTestCase {

    // MARK: - Private properties
    /// Locations
    private let kLocation1 = CLLocationCoordinate2D(latitude: -1, longitude: -1)
    private let kLocation2 = CLLocationCoordinate2D(latitude: -1, longitude: 1)
    private let kLocation3 = CLLocationCoordinate2D(latitude: 1, longitude: 1)
    private let kLocation4 = CLLocationCoordinate2D(latitude: 1, longitude: -1)

    // MARK: - Methods
    /// Randomly shuffle a mutable array.
    ///
    func shuffleMutableArray<T>(_ array: inout [T]) {
        array.shuffle()
    }

    /// Creates a cluster item at a given location.
    ///
    func item(at location: CLLocationCoordinate2D) -> GMUClusterItem1 {
        /// Placeholder: Replace with actual implementation to create GMUClusterItem at location.
        return GMUTestClusterItem1(position: location)
    }
    
    /// Generates an array of random cluster items positioned around a specified geographic location within a certain radius.
    ///
    /// - Parameters:
    ///   - location: The central geographic coordinate (`CLLocationCoordinate2D`) around which the cluster items are generated.
    ///   - count: The number of cluster items to generate.
    ///   - zoom: The current zoom level of the map, which influences the scale and density of the items.
    ///   - radius: The radius in world units around the specified location within which the items will be placed.
    /// - Returns: An array of `GMUClusterItem1` objects, each positioned randomly within the specified radius around the given location.
    ///
    func itemsAroundLocation(_ location: CLLocationCoordinate2D, count: Int, zoom: Double, radius: Double) -> [GMUClusterItem1] {
        let worldUnitsPerScreenPoint = pow(2, -7 - zoom)
        let worldUnits = radius * worldUnitsPerScreenPoint
        let mapPoint = GMSProject(location)

        var items = [GMUClusterItem1]()
        var remainingCount = count

        while remainingCount > 0 {
            let nearMapPoint = GMSMapPoint(x: mapPoint.x + randd() * worldUnits, y: mapPoint.y + randd() * worldUnits)
            let nearLocation = GMSUnproject(nearMapPoint)
            items.append(GMUTestClusterItem1(position: nearLocation))
            remainingCount -= 1
        }

        return items
    }

    /// Helper function to generate a random Double
    ///
    func randd() -> Double {
        return Double.random(in: 0.0...1.0)
    }

    /// Sum of all clusters' item counts.
    ///
    func totalItemCountsForClusters(_ clusters: [GMUCluster1]) -> Int {
        var sum: Int = 0
        clusters.forEach { cluster in
            sum += cluster.items.count
        }
        return sum
    }

    // MARK: - Asserts
    /// Asserts that two clusters do not share common items.
    ///
    func assertCluster(_ cluster1: GMUCluster1, doesNotOverlapWith cluster2: GMUCluster1) {
        let set1 = Set(cluster1.items.map { $0 as? AnyHashable })
        let set2 = Set(cluster2.items.map { $0 as? AnyHashable })
        XCTAssertFalse(set1.intersection(set2).isEmpty, "Clusters overlap!")
    }

    /// Asserts that clusters are valid (can define specific validation rules).
    /// 
    func assertValidClusters(_ clusters: [GMUCluster1]) {
        for i in 0..<clusters.count {
            for j in 0..<i {
                assertCluster(clusters[i], doesNotOverlapWith: clusters[j])
            }
        }
    }

    // MARK: - Fixtures
    /// Generates a fixed number of items for simple test cases.
    /// Returns an array of simple cluster items.
    ///
    func simpleClusterItems() -> [GMUClusterItem1] {
        var items = [GMUClusterItem1]()
        items.append(item(at: kLocation1))
        items.append(item(at: kLocation2))
        items.append(item(at: kLocation3))
        items.append(item(at: kLocation4))
        return items
    }

    /// Randomly generates items around fixed centroids.
    ///
    func randomizedClusterItems() -> [GMUClusterItem1] {
        let zoom = 10.0
        let radius = 50.0
        let count = 10

        var items = [GMUClusterItem1]()

        let items1 = itemsAroundLocation(kLocation1, count: count, zoom: zoom, radius: radius)
        let items2 = itemsAroundLocation(kLocation2, count: count, zoom: zoom, radius: radius)
        let items3 = itemsAroundLocation(kLocation3, count: count, zoom: zoom, radius: radius)
        let items4 = itemsAroundLocation(kLocation4, count: count, zoom: zoom, radius: radius)

        items.append(contentsOf: items1)
        items.append(contentsOf: items2)
        items.append(contentsOf: items3)
        items.append(contentsOf: items4)

        shuffleMutableArray(&items)
        return items
    }
}
