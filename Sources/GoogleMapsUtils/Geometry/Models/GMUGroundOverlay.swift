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

/// Image overlay on map.
public struct GMUGroundOverlay: GMUGeometry {
    /// Geometry type identifier.
    public var type: String = "GroundOverlay"

    /// Northeast corner.
    public private(set) var northEast: CLLocationCoordinate2D

    /// Southwest corner.
    public private(set) var southWest: CLLocationCoordinate2D

    /// Drawing order.
    public private(set) var zIndex: Int

    /// Rotation in degrees.
    public private(set) var rotation: Double

    /// Image URL or path.
    public private(set) var href: String

    /// Creates an overlay with bounds and image.
    public init(
        type: String = "",
        northEast: CLLocationCoordinate2D,
        southWest: CLLocationCoordinate2D,
        zIndex: Int = 0,
        rotation: Double = 0,
        href: String
    ) {
        self.type = type
        self.northEast = northEast
        self.southWest = southWest
        self.zIndex = zIndex
        self.rotation = rotation
        self.href = href
    }
}
