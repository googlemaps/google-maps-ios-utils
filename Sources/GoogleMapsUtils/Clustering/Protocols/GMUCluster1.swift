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

// MARK: - GMUCluster Protocol
/// TO-DO: Rename the class to `GMUCluster` once the linking is done and remove the objective c class.
/// Defines a generic cluster object, with read-only properties.
///
protocol GMUCluster1 {

    /// Returns the position of the cluster.
    var position: CLLocationCoordinate2D { get }

    /// Returns the number of items in the cluster.
    var count: Int { get }

    /// Returns a copy of the list of items in the cluster.
    var items: [GMUClusterItem1] { get }
}