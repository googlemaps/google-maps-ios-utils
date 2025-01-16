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

/// Represents a placemark which is either a Point, LineString, Polygon, or MultiGeometry. Contains
/// the properties and styles of the place.
/// TO-DO: Rename the class to `GMUPlacemark` once the linking is done and remove the objective c class.
struct GMUPlacemark1: GMUGeometryContainer1 {
    // MARK: - Properties
    /// The geometry object in the container.
    var geometry: GMUGeometry1
    /// Style information that should be applied to the contained geometry object.
    var style: GMUStyle1?
    /// The name element of the placemark.
    private(set) var title: String?
    /// The description element of the placemark.
    private(set) var snippet: String?
    /// The StyleUrl element of the placemark; used to reference a style defined in the file.
    private(set) var styleUrl: String?

}
