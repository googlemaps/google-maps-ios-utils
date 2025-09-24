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

/// Point geometry.
public struct GMUPoint: GMUGeometry, Equatable {
    /// Geometry type identifier.
    public var type: String = "Point"

    /// Location coordinate.
    public private(set) var coordinate: CLLocationCoordinate2D

    /// Creates a point at coordinate.
    public init(type: String = "", coordinate: CLLocationCoordinate2D) {
        self.type = type
        self.coordinate = coordinate
    }

    public static func == (lhs: GMUPoint, rhs: GMUPoint) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

