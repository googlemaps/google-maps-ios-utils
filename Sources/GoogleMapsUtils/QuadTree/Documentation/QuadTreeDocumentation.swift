// Copyright 2025 Google LLC
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

/// # QuadTree Documentation Module
///
/// **📖 Documentation-only namespace** - A comprehensive spatial data structure module for efficient 2D point indexing and range queries.
///
/// > Important: This struct exists solely for documentation organization. 
/// > **Do not instantiate or use this struct in your code.** 
/// > Use the individual QuadTree components instead: ``GQTPointQuadTree``, ``GQTPoint``, ``GQTBounds``, and ``GQTPointQuadTreeItem``.
///
/// ## Overview
///
/// The QuadTree module provides hierarchical spatial data structures that recursively subdivide
/// 2D space into quadrants, enabling efficient insertion, removal, and range queries for
/// spatially distributed data with O(log n) average performance.
///
/// ## Module Organization
///
/// The QuadTree module is organized by folder structure to separate concerns:
///
/// ```
/// 📁 QuadTree/
/// ├── 📁 Models/              → Core spatial data types
/// │   ├── GQTPoint           → 2D coordinates  
/// │   └── GQTBounds          → Rectangular boundaries
/// ├── 📁 Protocols/          → Integration interfaces
/// │   └── GQTPointQuadTreeItem → Protocol for storable items
/// ├── 📁 PointQuadTree/      → Main implementation
/// │   └── GQTPointQuadTree   → Primary quad tree class
/// └── 📁 PointQuadTreeChild/ → Node management
///     ├── GQTPointQuadTreeChild → Individual tree nodes
///     └── GQTPointQuadTreeChildConstants → Configuration constants
/// ```
///
/// ## Complete Usage Example
///
/// **Use the actual QuadTree components in your code, not this documentation struct:**
///
/// ```swift
/// import GoogleMapsUtils
///
/// // 1. Create spatial bounds using GQTBounds (Models folder)
/// let bounds = GQTBounds(minX: -180, minY: -90, maxX: 180, maxY: 90)
///
/// // 2. Create quad tree using GQTPointQuadTree (PointQuadTree folder)
/// let quadTree = GQTPointQuadTree(bounds: bounds)
///
/// // 3. Create items conforming to protocol (Protocols folder)
/// class MapMarker: GQTPointQuadTreeItem {
///     let coordinate: CLLocationCoordinate2D
///     let name: String
///     
///     init(coordinate: CLLocationCoordinate2D, name: String) {
///         self.coordinate = coordinate
///         self.name = name
///     }
///     
///     func point() -> GQTPoint {
///         return GQTPoint(x: coordinate.longitude, y: coordinate.latitude)
///     }
/// }
///
/// // 4. Use the complete system
/// let marker = MapMarker(
///     coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
///     name: "San Francisco"
/// )
/// 
/// quadTree.add(item: marker)
/// 
/// let searchBounds = GQTBounds(minX: -123, minY: 37, maxX: -122, maxY: 38)
/// let itemsInRegion = quadTree.search(withBounds: searchBounds)
/// ```
///
/// ## Topics
///
/// ### Main Implementation
/// - ``GQTPointQuadTree``
///
/// ### Node Management
/// - ``GQTPointQuadTreeChild``
/// - ``GQTPointQuadTreeChildConstants``
///
/// ### Spatial Models
/// - ``GQTPoint``
/// - ``GQTBounds``
///
/// ### Integration Protocols
/// - ``GQTPointQuadTreeItem``
///
///
/// ## Thread Safety
///
/// ⚠️ **Important**: All QuadTree classes are **not thread-safe**. External synchronization 
/// is required for concurrent access from multiple threads.
///
/// ## See Also
///
/// - ``GMUClusterManager``
///
public struct QuadTreeDocumentation {
    
    /// Private initializer to prevent instantiation.
    ///
    /// This struct exists solely for documentation organization and should never be instantiated.
    /// It serves as a namespace to group QuadTree module documentation in one place.
    private init() {}
}
