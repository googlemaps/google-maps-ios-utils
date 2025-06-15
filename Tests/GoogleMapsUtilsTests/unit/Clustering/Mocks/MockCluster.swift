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

import CoreLocation

@testable import GoogleMapsUtils

/// A mock implementation of `GMUCluster` for testing purposes.
final class MockCluster: GMUCluster {

    // MARK: - Properties
    /// The geographic position of the cluster.
    var position: CLLocationCoordinate2D
    /// The items contained within the cluster.
    var items: [GMUClusterItem]
    /// The number of items in the cluster.
    var count: Int {
        return items.count
    }

    // MARK: - Initializer
    
    /// Initializes a mock cluster with a given position and items.
    /// - Parameters:
    ///   - position: The location of the cluster.
    ///   - items: The list of cluster items.
    init(position: CLLocationCoordinate2D, items: [GMUClusterItem]) {
        self.position = position
        self.items = items
    }
}
