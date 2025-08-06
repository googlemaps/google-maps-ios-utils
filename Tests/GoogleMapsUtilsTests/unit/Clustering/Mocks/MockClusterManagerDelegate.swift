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

/// A mock implementation of `GMUClusterManagerDelegate` for testing purposes.
final class MockClusterManagerDelegate: GMUClusterManagerDelegate, Equatable {

    // MARK: - Equatable Conformance
    /// Compares two instances of `MockClusterManagerDelegate`.
    static func == (lhs: MockClusterManagerDelegate, rhs: MockClusterManagerDelegate) -> Bool {
        return true
    }

    // MARK: - GMUClusterManagerDelegate Methods
    /// Called when a cluster is tapped.
    func clusterManager(_ clusterManager: GMUClusterManager, didTapCluster cluster: GMUCluster) -> Bool {
        return false
    }

    /// Called when a cluster item is tapped.
    func clusterManager(_ clusterManager: GMUClusterManager, didTapClusterItem clusterItem: GMUClusterItem) -> Bool {
        return false
    }
}
