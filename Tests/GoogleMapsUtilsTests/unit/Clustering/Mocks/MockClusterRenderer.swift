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

/// A mock implementation of `GMUClusterRenderer` for testing purposes.
final class MockClusterRenderer: GMUClusterRenderer {

    // MARK: - Properties
    /// Stores the last rendered clusters for verification in tests.
    private(set) var lastRenderedClusters: [GMUCluster]?

    // MARK: - GMUClusterRenderer Conformance
    /// Mocks the rendering of clusters by storing them.
    func renderClusters(_ clusters: [GMUCluster]) {
        lastRenderedClusters = clusters
    }
    
    /// Updates the cluster rendering. This is a no-op in the mock.
    func update() {}
}
