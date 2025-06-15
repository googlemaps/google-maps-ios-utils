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
import GoogleMaps

// MARK: - GMUClusterItem Protocol
/// This protocol defines the contract for a cluster item.
/// 
/// The protocol requires a `position` property and provides optional `title` and `snippet`
/// properties through default implementations.
///
public protocol GMUClusterItem: AnyObject {

    /// Returns the position of the item.
    /// This is the only required property that conforming types must implement.
    var position: CLLocationCoordinate2D { get }

    /// Returns an optional title for the item.
    /// Conforming types can override this to provide a custom title, or use the default nil implementation.
    var title: String? { get }

    /// Returns an optional snippet for the item.
    /// Conforming types can override this to provide a custom snippet, or use the default nil implementation.
    var snippet: String? { get }
}

// MARK: - GMUClusterItem Default Implementation
/// Default implementation for optional properties.
/// 
/// This extension provides default implementations for `title` and `snippet` that return `nil`.
/// This approach makes these properties effectively optional - conforming types only need to
/// implement `position` (required) and can optionally override `title` and/or `snippet`.
///
extension GMUClusterItem {
    /// Default implementation returns nil, making title effectively optional for conforming types.
    public var title: String? { return nil }
    
    /// Default implementation returns nil, making snippet effectively optional for conforming types.
    public var snippet: String? { return nil }
}

// MARK: - GMSMarker Extension
/// Extension to make GMSMarker conform to GMUClusterItem protocol
///
extension GMSMarker: GMUClusterItem {
    // GMSMarker already has position, title, and snippet properties
    // No additional implementation needed as they match the protocol requirements
}
