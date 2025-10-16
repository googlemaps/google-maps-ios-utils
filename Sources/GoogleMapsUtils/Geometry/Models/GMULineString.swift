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

import GoogleMaps

/// Line geometry.
public struct GMULineString: GMUGeometry, Equatable {
    /// Geometry type identifier.
    public var type: String = "LineString"

    /// Path coordinates.
    public private(set) var path: GMSPath

    /// Creates a line with a path.
    public init(type: String = "", path: GMSPath) {
        self.type = type
        self.path = path
    }

    public static func == (lhs: GMULineString, rhs: GMULineString) -> Bool {
        guard lhs.path.count() == rhs.path.count() else { return false }

        for i in 0..<lhs.path.count() {
            let lhsCoord = lhs.path.coordinate(at: i)
            let rhsCoord = rhs.path.coordinate(at: i)
            if lhsCoord.latitude != rhsCoord.latitude || lhsCoord.longitude != rhsCoord.longitude {
                return false
            }
        }
        return true
    }
}

