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

/// Mock class for `GMUClusterItem`
final class MockGMUClusterItem: GMUClusterItem {

    // MARK: - Properties
    /// Returns the position of the item.
    var position: CLLocationCoordinate2D = kClusterPosition

    /// Returns an optional title for the item.
    var title: String?

    /// Returns an optional snippet for the item.
    var snippet: String?

    // MARK: - Initializers
    init(position: CLLocationCoordinate2D, title: String? = nil, snippet: String? = nil) {
        self.position = position
        self.title = title
        self.snippet = snippet
    }
}

