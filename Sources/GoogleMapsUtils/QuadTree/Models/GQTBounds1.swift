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

//MARK: - GQTBounds
/// The struct defines a rectangular boundary 
/// using read-only minimum and maximum X and Y coordinates.
/// 
/// TO-DO: Rename the struct to `GQTBounds` once the linking is done and remove the objective c class.
struct GQTBounds1 {
    //MARK: - Properties
    private(set) var minX: Double
    private(set) var minY: Double
    private(set) var maxX: Double
    private(set) var maxY: Double
}