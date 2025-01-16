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

/// Instances of this class represent a Polygon object.
/// TO-DO: Rename the class to `GMUPolygon` once the linking is done and remove the objective c class.
struct GMUPolygon1: GMUGeometry1 {
    // MARK: - Properties
    /// The type of the geometry.
    var type: String = "Polygon"
    /// The array of LinearRing paths for the Polygon. The first is the exterior ring of the Polygon; any subsequent rings are holes.
    private(set) var paths: [GMSPath]
}
