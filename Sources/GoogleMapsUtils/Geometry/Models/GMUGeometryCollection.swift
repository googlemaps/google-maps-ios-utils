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


/// Collection of geometry objects.
public struct GMUGeometryCollection: GMUGeometry {
    /// Geometry type identifier.
    public var type: String = "GeometryCollection"

    /// Contained geometries.
    public private(set) var geometries: [GMUGeometry]
    
    /// Creates a collection with geometries.
    public init(geometries: [GMUGeometry] = []) {
        self.geometries = geometries
    }
    
    /// Creates a collection with custom type.
    public init(type: String, geometries: [GMUGeometry]) {
        self.type = type
        self.geometries = geometries
    }
}

