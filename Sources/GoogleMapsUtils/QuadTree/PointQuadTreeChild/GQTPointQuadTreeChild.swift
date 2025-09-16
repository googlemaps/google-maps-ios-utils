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

// MARK: - GQTPointQuadTreeChild
/// Internal quad tree node. Most developers should use ``GQTPointQuadTree`` instead.
///
/// This class manages the hierarchical subdivision of space into quadrants.
/// It's public for advanced use cases but typically handled internally.
///
/// ## Topics
///
/// ### Item Management
/// - ``add(item:withOwnBounds:atDepth:)``
/// - ``remove(item:withOwnBounds:)``
///
/// ### Spatial Queries
/// - ``search(withBounds:withOwnBounds:results:)``
public final class GQTPointQuadTreeChild {

    // MARK: - Properties
    
    /// The top-right child quadrant. `nil` until this node subdivides.
    ///
    /// When a node splits, this quadrant contains items with coordinates greater than
    /// the node's center point in both X and Y dimensions.
    private var topRight: GQTPointQuadTreeChild?
    
    /// The top-left child quadrant. `nil` until this node subdivides.
    ///
    /// When a node splits, this quadrant contains items with X coordinates less than
    /// the center X and Y coordinates greater than the center Y.
    private var topLeft: GQTPointQuadTreeChild?
    
    /// The bottom-right child quadrant. `nil` until this node subdivides.
    ///
    /// When a node splits, this quadrant contains items with X coordinates greater than
    /// the center X and Y coordinates less than the center Y.
    private var bottomRight: GQTPointQuadTreeChild?
    
    /// The bottom-left child quadrant. `nil` until this node subdivides.
    ///
    /// When a node splits, this quadrant contains items with coordinates less than
    /// the node's center point in both X and Y dimensions.
    private var bottomLeft: GQTPointQuadTreeChild?
    
    /// Items stored in this node when it's a leaf. `nil` after subdivision.
    ///
    /// This array contains the actual ``GQTPointQuadTreeItem`` objects when the node
    /// is in leaf state. Once the node splits into child quadrants, this becomes `nil`
    /// and items are distributed among the child nodes.
    private var pointQuadTreeItems: [GQTPointQuadTreeItem]?

    // MARK: - Initialization
    
    /// Creates a new leaf node ready to store items.
    ///
    /// The node starts as a leaf with an empty items array. It will remain in this state
    /// until the number of items exceeds ``GQTPointQuadTreeChildConstants/maxElements``
    /// and the depth is below ``GQTPointQuadTreeChildConstants/maxDepth``.
    init() {
        pointQuadTreeItems = []
    }

    // MARK: - Item Management
    
    /// Inserts an item into this quad tree node, handling automatic subdivision if necessary.
    ///
    /// This method adds an item to the appropriate location in the quad tree hierarchy:
    /// - If the node is a leaf and has capacity, the item is stored directly
    /// - If the node is a leaf but at capacity, it subdivides and redistributes all items
    /// - If the node has children, the item is routed to the appropriate child quadrant
    ///
    /// ## Subdivision Behavior
    ///
    /// Subdivision occurs when:
    /// - Current item count ≥ ``GQTPointQuadTreeChildConstants/maxElements``
    /// - Current depth < ``GQTPointQuadTreeChildConstants/maxDepth``
    ///
    /// When subdivision happens, the node:
    /// 1. Creates four child quadrants
    /// 2. Redistributes existing items to appropriate children
    /// 3. Adds the new item to the correct child
    ///
    /// - Parameters:
    ///   - item: The item to insert. Must not be `nil`.
    ///   - bounds: The spatial bounds of this node.
    ///   - depth: The current depth in the tree (0 = root).
    ///
    /// - Precondition: `item` must not be `nil`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let node = GQTPointQuadTreeChild()
    /// let bounds = GQTBounds(minX: 0, minY: 0, maxX: 100, maxY: 100)
    /// 
    /// // Add item to leaf node
    /// node.add(item: myItem, withOwnBounds: bounds, atDepth: 0)
    /// ```
    public func add(item: GQTPointQuadTreeItem?, withOwnBounds bounds: GQTBounds, atDepth depth: Int) {
        // Ensure the item is not nil, otherwise, raise a fatal error.
        guard let item else {
            fatalError("Invalid item argument, item must not be nil")
        }

        /// Check if the node needs to be split based on the number of pointQuadTreeItems and current depth.
        if shouldSplit(atDepth: depth) {
            split(withOwnBounds: bounds, atDepth: depth)
        }

        /// Determine the correct quadrant and add the item.
        if let topRight {
            addItemToCorrectQuadrant(topRight, item: item, withOwnBounds: bounds, atDepth: depth)
        } else {
            /// Append the item to the list.
            pointQuadTreeItems?.append(item)
        }
    }

    // MARK: - `add` Helpers
    /// Determines whether the current node should be split based on the depth and the number of pointQuadTreeItems.
    ///
    /// - Parameter depth: The depth of the node.
    /// - Returns: Bool
    private func shouldSplit(atDepth depth: Int) -> Bool {
        if let pointQuadTreeItems = pointQuadTreeItems {
            /// A split is necessary if the number of pointQuadTreeItems exceeds the max allowed elements and depth is below the max depth.
            return pointQuadTreeItems.count >= GQTPointQuadTreeChildConstants.maxElements && depth < GQTPointQuadTreeChildConstants.maxDepth
        }
        return false
    }

    /// Determines the correct quadrant for the item.
    ///
    /// - Parameters:
    ///   - topRight: The top right child.
    ///   - item: The Point QuadTree item.
    ///   - bounds: The bounds of the node.
    ///   - depth: The depth of the node.
    private func addItemToCorrectQuadrant(_ topRight: GQTPointQuadTreeChild, item: GQTPointQuadTreeItem, withOwnBounds bounds: GQTBounds, atDepth depth: Int) {
        let itemPoint = item.point()
        let midPoint = boundsMidpoint(bounds)
        
        /// Check if the item belongs to the top or bottom quadrant and add it accordingly.
        if isItemInTopQuadrant(itemPoint, midPoint: midPoint) {
            addItemToTopQuadrant(topRight, item: item, itemPoint: itemPoint, midPoint: midPoint, bounds: bounds, atDepth: depth)
        } else {
            addItemToBottomQuadrant(item, itemPoint: itemPoint, midPoint: midPoint, bounds: bounds, atDepth: depth)
        }
    }

    /// Checks if the item belongs to the top quadrants based on its Y coordinate.
    ///
    /// - Parameters:
    ///   - itemPoint: The point of the item.
    ///   - midPoint: The mid point of the item.
    /// - Returns: Bool
    private func isItemInTopQuadrant(_ itemPoint: GQTPoint, midPoint: GQTPoint) -> Bool {
        return itemPoint.y > midPoint.y
    }

    /// Adds the item to the appropriate top quadrant based on its X coordinate.
    ///
    /// - Parameters:
    ///   - topRight: The top right child.
    ///   - item: The Point QuadTree item.
    ///   - itemPoint: The point of the item.
    ///   - midPoint: The mid point of the item.
    ///   - bounds: The bounds of the node.
    ///   - depth: The depth of the node.
    private func addItemToTopQuadrant(_ topRight: GQTPointQuadTreeChild, item: GQTPointQuadTreeItem, itemPoint: GQTPoint, midPoint: GQTPoint, bounds: GQTBounds, atDepth depth: Int) {
        if itemPoint.x > midPoint.x {
            /// Add to the top-right quadrant
            topRight.add(item: item, withOwnBounds: boundsTopRightChildBounds(bounds), atDepth: depth + 1)
        } else {
            /// Add to the top-left quadrant
            topLeft?.add(item: item, withOwnBounds: boundsTopLeftChildBounds(bounds), atDepth: depth + 1)
        }
    }

    /// Adds the item to the appropriate bottom quadrant based on its X coordinate.
    ///
    /// - Parameters:
    ///   - item: The Point QuadTree item.
    ///   - itemPoint: The point of the item.
    ///   - midPoint: The mid point of the item.
    ///   - bounds: The bounds of the node.
    ///   - depth: The depth of the node.
    private func addItemToBottomQuadrant(_ item: GQTPointQuadTreeItem, itemPoint: GQTPoint, midPoint: GQTPoint, bounds: GQTBounds, atDepth depth: Int) {
        if itemPoint.x > midPoint.x {
            /// Add to the bottom-right quadrant
            bottomRight?.add(item: item, withOwnBounds: boundsBottomRightChildBounds(bounds), atDepth: depth + 1)
        } else {
            /// Add to the bottom-left quadrant
            bottomLeft?.add(item: item, withOwnBounds: boundsBottomLeftChildBounds(bounds), atDepth: depth + 1)
        }
    }

    // MARK: - `splitWithOwnBounds`
    /// Split the contents of this Quad over four child quads.
    ///
    /// - Parameters:
    ///   - ownBounds: The bounds of this node.
    ///   - depth: The depth of this node.
    private func split(withOwnBounds ownBounds: GQTBounds, atDepth depth: Int) {
        assert(pointQuadTreeItems != nil)
        topRight = GQTPointQuadTreeChild()
        topLeft = GQTPointQuadTreeChild()
        bottomRight = GQTPointQuadTreeChild()
        bottomLeft = GQTPointQuadTreeChild()

        /// Temporarily store the current items and clear the original array.
        let itemsToSplit = pointQuadTreeItems
        pointQuadTreeItems = nil

        if let itemsToSplit {
            /// Redistribute each item to the appropriate child node using forEach.
            itemsToSplit.forEach { item in
                add(item: item, withOwnBounds: ownBounds, atDepth: depth)
            }
        }
    }

    /// Removes an item from this quad tree node and its subtree.
    ///
    /// This method searches for the specified item in the quad tree hierarchy and removes it:
    /// - If the node has children, it determines the correct child quadrant and delegates removal
    /// - If the node is a leaf, it searches the items array and removes the matching item
    ///
    /// The removal process uses object identity (`===`) to match items, ensuring that
    /// the exact same object instance is removed from the tree.
    ///
    /// - Parameters:
    ///   - item: The item to remove from the tree.
    ///   - bounds: The spatial bounds of this node, used for quadrant determination.
    ///
    /// - Returns: `true` if the item was found and removed, `false` if not found.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let success = node.remove(item: myItem, withOwnBounds: bounds)
    /// if success {
    ///     print("Item removed successfully")
    /// } else {
    ///     print("Item not found in tree")
    /// }
    /// ```
    public func remove(item: GQTPointQuadTreeItem, withOwnBounds bounds: GQTBounds) -> Bool {
        if let topRight {
            return removeFromChild(topRight, item: item, withOwnBounds: bounds)
        }
        return removeFromCurrentNode(item)
    }

    // MARK: - `remove` Helpers
    /// Removes the item from the appropriate child quadrant.
    ///
    /// - Parameters:
    ///   - topRight: The top right child.
    ///   - item: The item to remove.
    ///   - bounds: The bounds of the current node.
    /// - Returns: `true` if the item was successfully removed from a child, `false` otherwise.
    private func removeFromChild(_ topRight: GQTPointQuadTreeChild, item: GQTPointQuadTreeItem, withOwnBounds bounds: GQTBounds) -> Bool {
        let itemPoint = item.point()
        let midPoint = boundsMidpoint(bounds)

        // Determine the quadrant the item belongs to and attempt to remove it from that child.
        if isInTopQuadrant(itemPoint, midPoint: midPoint) {
            return removeFromTopQuadrant(topRight, item: item, itemPoint: itemPoint, midPoint: midPoint, bounds: bounds)
        } else {
            return removeFromBottomQuadrant(item, itemPoint: itemPoint, midPoint: midPoint, bounds: bounds)
        }
    }

    /// Determines if the item is in one of the top quadrants based on its coordinates.
    ///
    /// - Parameters:
    ///   - itemPoint: The point of the item.
    ///   - midPoint: The midpoint of the current node's bounds.
    /// - Returns: `true` if the item is in one of the top quadrants, `false` otherwise.
    private func isInTopQuadrant(_ itemPoint: GQTPoint, midPoint: GQTPoint) -> Bool {
        return itemPoint.y > midPoint.y
    }

    /// Attempts to remove the item from the appropriate top quadrant.
    ///
    /// - Parameters:
    ///   - topRight: The top right child.
    ///   - item: The item to remove.
    ///   - itemPoint: The point of the item.
    ///   - midPoint: The midpoint of the current node's bounds.
    ///   - bounds: The bounds of the current node.
    /// - Returns: `true` if the item was successfully removed, `false` otherwise.
    private func removeFromTopQuadrant(_ topRight: GQTPointQuadTreeChild, item: GQTPointQuadTreeItem, itemPoint: GQTPoint, midPoint: GQTPoint, bounds: GQTBounds) -> Bool {
        if itemPoint.x > midPoint.x {
            // Remove from top-right quadrant
            return topRight.remove(item: item, withOwnBounds: boundsTopRightChildBounds(bounds))
        } else if let topLeft {
            // Remove from top-left quadrant
            return topLeft.remove(item: item, withOwnBounds: boundsTopLeftChildBounds(bounds))
        } else {
            return false
        }
    }

    /// Attempts to remove the item from the appropriate bottom quadrant.
    ///
    /// - Parameters:
    ///   - item: The item to remove.
    ///   - itemPoint: The point of the item.
    ///   - midPoint: The midpoint of the current node's bounds.
    ///   - bounds: The bounds of the current node.
    /// - Returns: `true` if the item was successfully removed, `false` otherwise.
    private func removeFromBottomQuadrant(_ item: GQTPointQuadTreeItem, itemPoint: GQTPoint, midPoint: GQTPoint, bounds: GQTBounds) -> Bool {
        if let bottomRight, itemPoint.x > midPoint.x {
            // Remove from bottom-right quadrant
            return bottomRight.remove(item: item, withOwnBounds: boundsBottomRightChildBounds(bounds))
        } else if let bottomLeft {
            // Remove from bottom-left quadrant
            return bottomLeft.remove(item: item, withOwnBounds: boundsBottomLeftChildBounds(bounds))
        } else {
            return false
        }
    }

    /// Removes the item from the current node's items array.
    ///
    /// - Parameter item: The item to remove.
    /// - Returns: `true` if the item was found and removed, `false` otherwise.
    private func removeFromCurrentNode(_ items: GQTPointQuadTreeItem) -> Bool {
        // Attempt to find the index of the item in the array.
        guard var pointQuadTreeItems,
              let index = pointQuadTreeItems.firstIndex(where: { $0 === items }) else {
            // If the item is not found, return false early.
            return false
        }
        
        // If the item is found, remove it and return true.
        pointQuadTreeItems.remove(at: index)
        return true
    }

    // MARK: - Spatial Queries
    
    /// Performs a spatial range query to find all items within the specified bounds.
    ///
    /// This method efficiently searches the quad tree hierarchy to collect all items
    /// whose coordinates fall within the search bounds:
    ///
    /// - **Internal Nodes**: Tests each child quadrant for intersection with search bounds
    ///   and recursively searches intersecting children
    /// - **Leaf Nodes**: Filters stored items by coordinate containment within search bounds
    ///
    /// The search uses spatial pruning to avoid examining quadrants that don't intersect
    /// with the search area, providing efficient O(log n + k) performance where k is
    /// the number of results.
    ///
    /// - Parameters:
    ///   - searchBounds: The rectangular area to search within.
    ///   - ownBounds: The spatial bounds of this node (used for child bound calculations).
    ///   - accumulator: An in-out array that collects matching items during traversal.
    ///
    /// ## Search Process
    ///
    /// 1. **Intersection Test**: Check if child quadrants intersect search bounds
    /// 2. **Recursive Search**: Visit only intersecting child quadrants
    /// 3. **Item Filtering**: Test leaf items for coordinate containment
    /// 4. **Result Collection**: Add matching items to accumulator array
    ///
    /// ## Example
    ///
    /// ```swift
    /// var results: [GQTPointQuadTreeItem] = []
    /// let searchArea = GQTBounds(minX: 10, minY: 10, maxX: 50, maxY: 50)
    /// 
    /// node.search(withBounds: searchArea, withOwnBounds: nodeBounds, results: &results)
    /// print("Found \(results.count) items in search area")
    /// ```
    public func search(withBounds searchBounds: GQTBounds, withOwnBounds ownBounds: GQTBounds, results accumulator: inout [GQTPointQuadTreeItem]) {
        if let topRight = topRight {
            // Define bounds for each child quadrant.
            let topRightBounds = boundsTopRightChildBounds(ownBounds)
            let topLeftBounds = boundsTopLeftChildBounds(ownBounds)
            let bottomRightBounds = boundsBottomRightChildBounds(ownBounds)
            let bottomLeftBounds = boundsBottomLeftChildBounds(ownBounds)
            
            // Search in child quadrants if their bounds intersect with the search bounds.
            searchInChildQuadrants(topRight, searchBounds, ownBounds, topRightBounds,  topLeftBounds, bottomRightBounds, bottomLeftBounds, &accumulator)
        } else {
            // Search in the current node's items.
            searchInCurrentNode(searchBounds: searchBounds, accumulator: &accumulator)
        }
    }

    // MARK: - `search` Helpers
    /// Searches in the child quadrants if their bounds intersect with the search bounds.
    ///
    /// - Parameters:
    ///   - topRight: The top right child
    ///   - searchBounds: The bounds of the search box.
    ///   - ownBounds: The bounds of this node.
    ///   - topRightBounds: The bounds of the top-right child quadrant.
    ///   - topLeftBounds: The bounds of the top-left child quadrant.
    ///   - bottomRightBounds: The bounds of the bottom-right child quadrant.
    ///   - bottomLeftBounds: The bounds of the bottom-left child quadrant.
    ///   - accumulator: The results of the search.
    private func searchInChildQuadrants(_ topRight: GQTPointQuadTreeChild,_ searchBounds: GQTBounds,_ ownBounds: GQTBounds,_ topRightBounds: GQTBounds,_ topLeftBounds: GQTBounds,_ bottomRightBounds: GQTBounds,_ bottomLeftBounds: GQTBounds,_ accumulator: inout [GQTPointQuadTreeItem]) {
        if boundsIntersectsBounds(topRightBounds, searchBounds) {
            topRight.search(withBounds: searchBounds, withOwnBounds: topRightBounds, results: &accumulator)
        }
        if boundsIntersectsBounds(topLeftBounds, searchBounds) {
            topLeft?.search(withBounds: searchBounds, withOwnBounds: topLeftBounds, results: &accumulator)
        }
        if boundsIntersectsBounds(bottomRightBounds, searchBounds) {
            bottomRight?.search(withBounds: searchBounds, withOwnBounds: bottomRightBounds, results: &accumulator)
        }
        if boundsIntersectsBounds(bottomLeftBounds, searchBounds) {
            bottomLeft?.search(withBounds: searchBounds, withOwnBounds: bottomLeftBounds, results: &accumulator)
        }
    }

    /// Searches for items within the current node's bounds that intersect with the search bounds.
    ///
    /// - Parameters:
    ///   - searchBounds: The bounds of the search box.
    ///   - accumulator: The results of the search.
    private func searchInCurrentNode(searchBounds: GQTBounds, accumulator: inout [GQTPointQuadTreeItem]) {
        guard let pointQuadTreeItems = pointQuadTreeItems else {
            return
        }

        // Filter items based on whether their points are within the search bounds.
        let pointQuadFilteredTreeItems: [GQTPointQuadTreeItem] = pointQuadTreeItems.filter { item in
            let point = item.point()
            return point.x <= searchBounds.maxX &&
            point.x >= searchBounds.minX &&
            point.y <= searchBounds.maxY &&
            point.y >= searchBounds.minY
        }

        // Append the filtered items to the accumulator.
        accumulator.append(contentsOf: pointQuadFilteredTreeItems)
    }
}
