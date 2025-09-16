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

// MARK: - GQTBounds

/// A rectangular boundary defined by corner coordinates.
///
/// ```swift
/// let bounds = GQTBounds(minX: -122.5, minY: 37.7, maxX: -122.3, maxY: 37.8)
/// ```
public struct GQTBounds {
    
    // MARK: - Properties
    
    /// The minimum x-coordinate (left edge).
    public var minX: Double
    
    /// The minimum y-coordinate (bottom edge).
    public var minY: Double
    
    /// The maximum x-coordinate (right edge).
    public var maxX: Double
    
    /// The maximum y-coordinate (top edge).
    public var maxY: Double
}
