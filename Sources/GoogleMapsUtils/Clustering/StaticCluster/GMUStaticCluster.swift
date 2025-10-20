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

/// A class representing a static cluster where its position is fixed upon initialization.
///
import CoreLocation

public final class GMUStaticCluster: GMUCluster {

    // MARK: - Properties
    /// The position of the cluster, which is set during initialization and cannot be changed.
    public private(set) var position: CLLocationCoordinate2D
    /// Private mutable array to store the items in the cluster.
    private var clusterItems: [GMUClusterItem]
    /// The number of items in the cluster, which is derived from the internal items array.
    public var count: Int {
        return clusterItems.count
    }
    /// Returns a copy of the list of items in the cluster.
    /// This is a copy of the internal array to ensure immutability.
    public var items: [GMUClusterItem] {
        return clusterItems
    }

    // MARK: - Initializers
    /// Initializes a new instance of `GMUStaticCluster` with a specific position.
    /// - Parameter position: The position of the cluster.
    public init(position: CLLocationCoordinate2D) {
        self.position = position
        self.clusterItems = []
    }

    // MARK: - Methods
    /// Adds an item to the cluster.
    ///
    /// - Parameter item: The item to be added to the cluster.
    public func addItem(_ item: GMUClusterItem) {
        clusterItems.append(item)
    }

    /// Removes an item from the cluster.
    ///
    /// - Parameter item: The item to be removed from the cluster.
    public func removeItem(_ item: GMUClusterItem) {
        clusterItems.removeAll { $0 === item }
    }
}
