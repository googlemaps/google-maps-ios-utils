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


/// TO-DO: Rename the class to `GMUSimpleClusterAlgorithm` once the linking is done and remove the objective c class.
/// `GMUSimpleClusterAlgorithm` is a basic clustering algorithm that groups a set of `GMUClusterItem` objects into a fixed number of clusters (default 10).
/// Not for production: used for experimenting with new clustering algorithms only.
///
final class GMUSimpleClusterAlgorithm1: GMUClusterAlgorithm1 {

    // MARK: - Properties
    /// Number of clusters to form.
    private let clusterCount: Int = 10
    /// Internal array to store cluster items.
    private var clusterItems: [GMUClusterItem] = []

    // MARK: - `GMUClusterAlgorithm` Methods
    /// Adds an array of items to the cluster algorithm.
    ///
    /// - Parameter items: Array of items conforming to `GMUClusterItem` protocol.
    func addItems(_ items: [GMUClusterItem]) {
        clusterItems.append(contentsOf: items)
    }

    /// Removes a specific item from the cluster algorithm.
    ///
    /// - Parameter item: The item conforming to `GMUClusterItem` protocol to be removed.
    func removeItem(_ item: GMUClusterItem) {
        clusterItems.removeAll { $0 === item }
    }

    /// Clears all items from the cluster algorithm.
    func clearItems() {
        clusterItems.removeAll()
    }

    /// Returns an array of clusters at the specified zoom level.
    ///
    /// - Parameter zoom: The zoom level at which to compute clusters.
    /// - Returns: An array of clusters conforming to `GMUCluster` protocol.
    func clusters(atZoom zoom: Float) -> [GMUCluster] {
        var clusters: [GMUCluster] = []

        for i in 0..<clusterCount {
            if i >= clusterItems.count {
                break
            }
            let item: GMUClusterItem = clusterItems[i]
            clusters.append(GMUStaticCluster(position: item.position))
        }

        var clusterIndex: Int = 0
        for i in clusterCount..<clusterItems.count {
            let item = clusterItems[i]
            if let cluster = clusters[clusterIndex % clusterCount] as? GMUStaticCluster {
                cluster.addItem(item)
            }
            clusterIndex += 1
        }

        return clusters
    }
}
