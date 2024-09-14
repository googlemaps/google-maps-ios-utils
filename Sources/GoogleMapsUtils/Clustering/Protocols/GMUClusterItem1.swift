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

/// TO-DO: Rename the class to `GMUClusterItem1` once the linking is done and remove the objective c class.
/// This protocol defines the contract for a cluster item, with read-only properties.
///
protocol GMUClusterItem1 {

    /// Returns the position of the item.
    var position: CLLocationCoordinate2D { get }

    /// Returns an optional title for the item.
    var title: String? { get }

    /// Returns an optional snippet for the item.
    var snippet: String? { get }
}
