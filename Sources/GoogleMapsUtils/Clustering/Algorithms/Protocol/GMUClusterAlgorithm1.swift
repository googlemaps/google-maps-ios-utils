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


// MARK: - GMUClusterAlgorithm Protocol
/// TO-DO: Rename the class to `GMUClusterAlgorithm` once the linking is done and remove the objective c class.
/// Generic protocol for arranging cluster items into groups.
///
protocol GMUClusterAlgorithm1 {

    /// Adds an array of items to the cluster algorithm.
    ///
    /// - Parameter items: An array of items conforming to `GMUClusterItem` protocol.
    func addItems(_ items: [GMUClusterItem1])

    /// Removes a specific item from the cluster algorithm.
    ///
    /// - Parameter item: The item conforming to `GMUClusterItem` protocol to be removed.
    func removeItem(_ item: GMUClusterItem1)

    /// Removes an item.
    func clearItems()

    /// Returns the set of clusters of the added items.
    ///
    /// - Parameter zoom: The zoom level at which to compute clusters.
    /// - Returns: An array of clusters conforming to `GMUCluster` protocol.
    func clusters(atZoom zoom: Float) -> [GMUCluster1]
}
