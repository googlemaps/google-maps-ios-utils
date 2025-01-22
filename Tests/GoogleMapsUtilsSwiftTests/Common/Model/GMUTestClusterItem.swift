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

/// Simple cluster item implementation for use in tests.
///
final class GMUTestClusterItem: GMUClusterItem {

    // MARK: - Properties
    /// Position of the read-only cluster item (required by the protocol).
    private(set) var position: CLLocationCoordinate2D
    /// Optional title for the cluster item.
    var title: String?
    /// Optional snippet for the cluster item.
    var snippet: String?

    // MARK: - Initializers
    /// Designated initializer that takes position, title, and snippet as arguments.
    /// This initializes all the properties accordingly.
    init(position: CLLocationCoordinate2D, title: String?, snippet: String?) {
        self.position = position
        self.title = title
        self.snippet = snippet
    }

    /// Convenience Initializer that takes only the position as an argument.
    /// Title and snippet are set to nil by default.
    convenience init(position: CLLocationCoordinate2D) {
        self.init(position: position, title: nil, snippet: nil)
    }
}
