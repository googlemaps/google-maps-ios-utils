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

/// Instances of this class represent a Ground Overlay object.
/// 
struct GMUGroundOverlay: GMUGeometry {
    // MARK: - Properties
    /// The type of the geometry.
    var type: String = "GroundOverlay"
    /// The North-East corner of the overlay.
    private(set) var northEast: CLLocationCoordinate2D
    /// The South-West corner of the overlay.
    private(set) var southWest: CLLocationCoordinate2D
    /// The Z-Index of the overlay.
    private(set) var zIndex: Int
    /// The rotation of the overlay on the map.
    private(set) var rotation: Double
    /// The image to be rendered on the overlay.
    private(set) var href: String
}
