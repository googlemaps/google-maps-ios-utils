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

/// Defines a generic geometry container.
/// TO-DO: Rename the class to `GMUGeometryContainer` once the linking is done and remove the objective c class
protocol GMUGeometryContainer1 {
    /// The geometry object in the container.
    var geometry: GMUGeometry1 { get }
    /// Style information that should be applied to the contained geometry object.
    var style: GMUStyle1? { get set }
}
