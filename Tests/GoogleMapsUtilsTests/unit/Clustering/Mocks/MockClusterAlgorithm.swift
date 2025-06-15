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

@testable import GoogleMapsUtils

/// A mock implementation of `GMUClusterAlgorithm` for testing purposes.
final class MockClusterAlgorithm: GMUClusterAlgorithm, Equatable {

    // MARK: - Properties
    /// Stores the list of cluster items.
    private var items: [GMUClusterItem] = []

    // MARK: - Equatable Conformance
    /// Compares two instances of `MockClusterAlgorithm`.
    static func == (lhs: MockClusterAlgorithm, rhs: MockClusterAlgorithm) -> Bool {
        return true
    }

    // MARK: - Cluster Management Methods
    /// Adds multiple items to the cluster.
    /// - Parameter items: The items to be added.
    func addItems(_ items: [GMUClusterItem]) {
        self.items.append(contentsOf: items)
    }

    /// Removes a specific item from the cluster.
    /// - Parameter item: The item to be removed.
    func removeItem(_ item: GMUClusterItem) {
        self.items.removeAll {
            $0.position.latitude == item.position.latitude &&
            $0.position.longitude == item.position.longitude
        }
    }

    /// Clears all items from the cluster.
    func clearItems() {
        items.removeAll()
    }

    // MARK: - GMUClusterAlgorithm Conformance
    /// Generates clusters based on the current zoom level.
    /// - Parameter zoom: The zoom level.
    /// - Returns: An array of `GMUCluster` objects.
    func clusters(atZoom zoom: Float) -> [GMUCluster] {
        guard let firstItem = items.first else { return [] }
        return [MockCluster(position: firstItem.position, items: items)]
    }
}
