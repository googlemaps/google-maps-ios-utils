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

//MARK: - GQTPoint
/// The struct represents a point with read-only x and y coordinates.
/// 
/// TO-DO: Rename the struct to `GQTPoint` once the linking is done and remove the objective c class.
struct GQTPoint1 {
    //MARK: - Properties
    private(set) var x: Double
    private(set) var y: Double
}