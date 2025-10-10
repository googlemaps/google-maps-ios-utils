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

// MARK: - GQTPointQuadTree

/// A quad tree for spatial indexing of 2D points.
///
/// Use this to efficiently store and query items by location. The tree automatically
/// subdivides space to maintain performance as you add more items.
///
/// ```swift
/// let quadTree = GQTPointQuadTree()
/// quadTree.add(item: myMapMarker)
/// let items = quadTree.search(withBounds: searchArea)
/// ```
///
/// - Important: Not thread-safe. Use external synchronization for concurrent access.
///
/// ## Topics
///
/// ### Creating Quad Trees
/// - ``init(bounds:)``
/// - ``init()``
///
/// ### Managing Items
/// - ``add(item:)``
/// - ``remove(item:)``
/// - ``clear()``
///
/// ### Querying Items
/// - ``search(withBounds:)``
/// - ``getCount()``
/// - ``count``
///
/// ## Related Types
///
/// ### Models (from `/Models/` folder)
/// - ``GQTPoint`` - 2D coordinate representation
/// - ``GQTBounds`` - Rectangular boundary definition
///
/// ### Protocols (from `/Protocols/` folder)  
/// - ``GQTPointQuadTreeItem`` - Interface for storable items
///
public class GQTPointQuadTree {

    // MARK: - Properties
    
    /// The spatial bounds that define the extent of this quad tree.
    ///
    /// All items added to the tree must fall within these bounds. Items outside
    /// the bounds will be rejected during insertion.
    private var bounds: GQTBounds
    
    /// The root node of the quad tree hierarchy.
    ///
    /// This is the top-level node that contains or subdivides into child quadrants
    /// as items are added to the tree.
    private var root: GQTPointQuadTreeChild
    
    /// The total number of items currently stored in the tree.
    ///
    /// This count is maintained automatically as items are added and removed.
    public var count: Int = 0

    // MARK: - Initialization
    
    /// Creates a new quad tree with the specified spatial bounds.
    ///
    /// The quad tree will only accept items whose positions fall within the specified bounds.
    /// Items outside these bounds will be rejected during insertion operations.
    ///
    /// - Parameter bounds: The inclusive spatial bounds for this quad tree. Items at the
    ///   boundary coordinates are considered within bounds.
    ///
    /// - Note: This class is not thread-safe. External synchronization is required for
    ///   concurrent access from multiple threads.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a quad tree for geographic coordinates
    /// let geoBounds = GQTBounds(
    ///     minX: -180, minY: -90,    // Southwest: 180°W, 90°S
    ///     maxX: 180, maxY: 90       // Northeast: 180°E, 90°N
    /// )
    /// let quadTree = GQTPointQuadTree(bounds: geoBounds)
    /// ```
    public init(bounds: GQTBounds) {
        self.bounds = bounds
        self.root = GQTPointQuadTreeChild()
        self.clear()
    }

    /// Creates a new quad tree with default bounds from (-1,-1) to (1,1).
    ///
    /// This convenience initializer creates a quad tree suitable for normalized coordinate
    /// systems or small-scale spatial indexing applications.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let quadTree = GQTPointQuadTree()
    /// // Tree bounds: minX: -1, minY: -1, maxX: 1, maxY: 1
    /// ```
    public convenience init() {
        self.init(bounds: GQTBounds(minX: -1, minY: -1, maxX: 1, maxY: 1))
    }

    // MARK: - Managing Items
    
    /// Inserts an item into the quad tree.
    ///
    /// The item will be added to the appropriate quadrant based on its spatial position.
    /// If the item's position falls outside the tree's bounds, the insertion will fail.
    ///
    /// - Parameter item: The item to insert. Must conform to ``GQTPointQuadTreeItem`` and
    ///   provide a valid position via its `point()` method.
    ///
    /// - Returns: `true` if the item was successfully inserted, `false` if the item is `nil`
    ///   or its position falls outside the tree's bounds.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let quadTree = GQTPointQuadTree()
    /// let marker = MyMapMarker(coordinate: CLLocationCoordinate2D(latitude: 0.5, longitude: 0.5))
    /// 
    /// if quadTree.add(item: marker) {
    ///     print("Marker added successfully")
    /// } else {
    ///     print("Failed to add marker - outside bounds or nil")
    /// }
    /// ```
    ///
    public func add(item: GQTPointQuadTreeItem?) -> Bool {
        // Ensure the item is not nil and within the bounds of the tree.
        guard let item = item, isItemWithinBounds(item) else {
            return false
        }

        // Add the item to the tree.
        root.add(item: item, withOwnBounds: bounds, atDepth: 0)
        count += 1

        return true
    }

    /// Removes an item from the quad tree.
    ///
    /// The method searches for the item based on object identity (===) and removes it
    /// if found. The item's position must be within the tree's bounds for removal to succeed.
    ///
    /// - Parameter item: The item to remove. Must be the same object instance that was
    ///   previously added to the tree.
    ///
    /// - Returns: `true` if the item was found and successfully removed, `false` if the
    ///   item was not found or its position is outside the tree's bounds.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let quadTree = GQTPointQuadTree()
    /// let marker = MyMapMarker(coordinate: CLLocationCoordinate2D(latitude: 0.5, longitude: 0.5))
    /// 
    /// quadTree.add(item: marker)
    /// 
    /// if quadTree.remove(item: marker) {
    ///     print("Marker removed successfully")
    /// } else {
    ///     print("Marker not found or outside bounds")
    /// }
    /// ```
    ///
    public func remove(item: GQTPointQuadTreeItem) -> Bool {
        // Ensure the item within the bounds of the tree.
        guard isItemWithinBounds(item) else {
            return false
        }
        let removed = root.remove(item: item, withOwnBounds: bounds)
        if removed {
            count -= 1
        }
        return removed
    }
    
    // MARK: - `add` & `remove` Helpers
    /// Checks if the given item is within the bounds of this PointQuadTree.
    ///
    /// - Parameter item: The item to check.
    /// - Returns: `true` if the item is within the bounds; `false` otherwise.
    private func isItemWithinBounds(_ item: GQTPointQuadTreeItem) -> Bool {
        let itemPoint = item.point()
        return itemPoint.x <= bounds.maxX &&
                   itemPoint.x >= bounds.minX &&
                   itemPoint.y <= bounds.maxY &&
                   itemPoint.y >= bounds.minY
    }

    /// Removes all items from the quad tree.
    ///
    /// This method efficiently clears the entire tree by creating a new root node
    /// and resetting the item count to zero. All previously added items will be
    /// removed from the tree.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let quadTree = GQTPointQuadTree()
    /// // Add many items...
    /// print("Items before clear: \(quadTree.count)")
    /// 
    /// quadTree.clear()
    /// print("Items after clear: \(quadTree.count)") // Prints: 0
    /// ```
    ///
    public func clear() {
        root = GQTPointQuadTreeChild()
        count = 0
    }

    // MARK: - Querying Items
    
    /// Retrieves all items within the specified bounding box.
    ///
    /// This method performs a spatial range query, returning all items whose positions
    /// fall within the given bounds. The search is optimized using the quad tree's
    /// hierarchical structure to avoid checking irrelevant quadrants.
    ///
    /// - Parameter searchBounds: The rectangular region to search within. Items at the
    ///   boundary coordinates are included in the results.
    ///
    /// - Returns: An array containing all items whose positions fall within the search bounds.
    ///   The order of items in the array is not guaranteed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let quadTree = GQTPointQuadTree()
    /// // Add items...
    /// 
    /// // Search for items in the northeast quadrant
    /// let searchBounds = GQTBounds(minX: 0, minY: 0, maxX: 1, maxY: 1)
    /// let itemsInRegion = quadTree.search(withBounds: searchBounds)
    /// 
    /// print("Found \(itemsInRegion.count) items in the region")
    /// ```
    ///
    public func search(withBounds searchBounds: GQTBounds) -> [GQTPointQuadTreeItem] {
        var results: [GQTPointQuadTreeItem] = []
        root.search(withBounds: searchBounds, withOwnBounds: bounds, results: &results)
        return results
    }

    /// Returns the total number of items currently stored in the tree.
    ///
    /// This method provides the same information as the ``count`` property but
    /// in method form for compatibility with existing code.
    ///
    /// - Returns: The number of items in the tree.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let quadTree = GQTPointQuadTree()
    /// quadTree.add(item: marker1)
    /// quadTree.add(item: marker2)
    /// 
    /// print("Tree contains \(quadTree.getCount()) items") // Prints: 2
    /// ```
    ///
    public func getCount() -> Int {
        return count
    }
}
