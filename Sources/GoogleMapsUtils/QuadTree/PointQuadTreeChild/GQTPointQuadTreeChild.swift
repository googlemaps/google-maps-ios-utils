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
/// The class manages the children and items in a quad tree node, 
/// handling insertion, removal, splitting, and searching within specific bounds.
/// 
/// TO-DO: Rename the class to `GQTPointQuadTreeChild` once the linking is done and remove the objective c class.
final class GQTPointQuadTreeChild1 {

    // MARK: - Properties
    /// Top Right child quad. Nil until this node is split.
    private var topRight: GQTPointQuadTreeChild1?
    /// Top Left child quad. Nil until this node is split.
    private var topLeft: GQTPointQuadTreeChild1?
    /// Bottom Right child quad. Nil until this node is split.
    private var bottomRight: GQTPointQuadTreeChild1?
    /// Top Right child quad. Nil until this node is split.
    private var bottomLeft: GQTPointQuadTreeChild1?
    /// Bottom Left child quad. Nil until this node is split.
    private var pointQuadTreeItems: [GQTPointQuadTreeItem1]?

    // MARK: - Init
    init() {
        pointQuadTreeItems = []
    }

    // MARK: - `add`
    /// Insert an item into this PointQuadTreeChild
    ///
    /// - Parameters:
    ///   - item: The item to insert. Must not be nil.
    ///   - bounds: The bounds of this node.
    ///   - depth: The depth of this node.
    func add(item: GQTPointQuadTreeItem1?, withOwnBounds bounds: GQTBounds1, atDepth depth: Int) {
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
    private func addItemToCorrectQuadrant(_ topRight: GQTPointQuadTreeChild1, item: GQTPointQuadTreeItem1, withOwnBounds bounds: GQTBounds1, atDepth depth: Int) {
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
    private func isItemInTopQuadrant(_ itemPoint: GQTPoint1, midPoint: GQTPoint1) -> Bool {
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
    private func addItemToTopQuadrant(_ topRight: GQTPointQuadTreeChild1, item: GQTPointQuadTreeItem1, itemPoint: GQTPoint1, midPoint: GQTPoint1, bounds: GQTBounds1, atDepth depth: Int) {
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
    private func addItemToBottomQuadrant(_ item: GQTPointQuadTreeItem1, itemPoint: GQTPoint1, midPoint: GQTPoint1, bounds: GQTBounds1, atDepth depth: Int) {
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
    private func split(withOwnBounds ownBounds: GQTBounds1, atDepth depth: Int) {
        assert(pointQuadTreeItems != nil)
        topRight = GQTPointQuadTreeChild1()
        topLeft = GQTPointQuadTreeChild1()
        bottomRight = GQTPointQuadTreeChild1()
        bottomLeft = GQTPointQuadTreeChild1()

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

    // MARK: - `remove`
    /// Delete an item from this PointQuadTree.
    ///
    /// - Parameters:
    ///   - item: The item to delete.
    ///   - bounds: The bounds of this node.
    /// - Returns: `false` if the item was not found in the tree, `true` otherwise.
    func remove(item: GQTPointQuadTreeItem1, withOwnBounds bounds: GQTBounds1) -> Bool {
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
    private func removeFromChild(_ topRight: GQTPointQuadTreeChild1, item: GQTPointQuadTreeItem1, withOwnBounds bounds: GQTBounds1) -> Bool {
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
    private func isInTopQuadrant(_ itemPoint: GQTPoint1, midPoint: GQTPoint1) -> Bool {
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
    private func removeFromTopQuadrant(_ topRight: GQTPointQuadTreeChild1, item: GQTPointQuadTreeItem1, itemPoint: GQTPoint1, midPoint: GQTPoint1, bounds: GQTBounds1) -> Bool {
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
    private func removeFromBottomQuadrant(_ item: GQTPointQuadTreeItem1, itemPoint: GQTPoint1, midPoint: GQTPoint1, bounds: GQTBounds1) -> Bool {
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
    private func removeFromCurrentNode(_ items: GQTPointQuadTreeItem1) -> Bool {
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

    // MARK: - `search`
    /// Retrieve all pointQuadTreeItems in this PointQuadTree within a bounding box.
    ///
    /// - Parameters:
    ///   - searchBounds: The bounds of the search box.
    ///   - ownBounds: The bounds of this node.
    ///   - accumulator: The results of the search.
    func search(withBounds searchBounds: GQTBounds1, withOwnBounds ownBounds: GQTBounds1, results accumulator: inout [GQTPointQuadTreeItem1]) {
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
    private func searchInChildQuadrants(_ topRight: GQTPointQuadTreeChild1,_ searchBounds: GQTBounds1,_ ownBounds: GQTBounds1,_ topRightBounds: GQTBounds1,_ topLeftBounds: GQTBounds1,_ bottomRightBounds: GQTBounds1,_ bottomLeftBounds: GQTBounds1,_ accumulator: inout [GQTPointQuadTreeItem1]) {
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
    private func searchInCurrentNode(searchBounds: GQTBounds1, accumulator: inout [GQTPointQuadTreeItem1]) {
        guard let pointQuadTreeItems = pointQuadTreeItems else {
            return
        }

        // Filter items based on whether their points are within the search bounds.
        let pointQuadFilteredTreeItems: [GQTPointQuadTreeItem1] = pointQuadTreeItems.filter { item in
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
