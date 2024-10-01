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
/// The class implements a quad tree data structure for spatial indexing, 
/// allowing efficient insertion, removal, and search of items within specified bounds.
/// 
/// TO-DO: Rename the class to `GQTPointQuadTree` once the linking is done and remove the objective c class.
final class GQTPointQuadTree1 {

    // MARK: - Properties
    /// The bounds of this PointQuadTree.
    private var bounds: GQTBounds1
    /// The Quad Tree data structure.
    private var root: GQTPointQuadTreeChild1
    /// The number of items in this tree.
    var count: Int = 0

    // MARK: - Init
    /// Create a QuadTree with bounds. Please note, this class is not thread safe.
    ///
    /// - Parameter bounds: The bounds of this PointQuadTree. The tree will only accept items that fall within the bounds.
    /// The bounds are inclusive.
    init(bounds: GQTBounds1) {
        self.bounds = bounds
        self.root = GQTPointQuadTreeChild1()
        self.clear()
    }

    ///  Create a QuadTree with the inclusive bounds of (-1,-1) to (1,1).
    convenience init() {
        self.init(bounds: GQTBounds1(minX: -1, minY: -1, maxX: 1, maxY: 1))
    }

    // MARK: - `add`
    /// Insert an item into this PointQuadTree.
    ///
    /// - Parameter item: The item to insert. Must not be nil.
    /// - Returns: `false` if the item is not contained within the bounds of this tree. Otherwise adds the item and returns `true`.
    func add(item: GQTPointQuadTreeItem1?) -> Bool {
        // Ensure the item is not nil and within the bounds of the tree.
        guard let item = item, isItemWithinBounds(item) else {
            return false
        }

        // Add the item to the tree.
        root.add(item: item, withOwnBounds: bounds, atDepth: 0)
        count += 1

        return true
    }

    // MARK: - `remove`
    /// Delete an item from this PointQuadTree.
    ///
    /// - Parameter item: The item to delete.
    /// - Returns: `false` if the item was not found in the tree, `true` otherwise.
    func remove(item: GQTPointQuadTreeItem1) -> Bool {
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
    private func isItemWithinBounds(_ item: GQTPointQuadTreeItem1) -> Bool {
        let itemPoint = item.point()
        return itemPoint.x <= bounds.maxX &&
                   itemPoint.x >= bounds.minX &&
                   itemPoint.y <= bounds.maxY &&
                   itemPoint.y >= bounds.minY
    }

    // MARK: - `clear`
    /// Delete all items from this PointQuadTree.
    func clear() {
        root = GQTPointQuadTreeChild1()
        count = 0
    }

    // MARK: - `search`
    /// Retreive all items in this PointQuadTree within a bounding box.
    ///
    /// - Parameter searchBounds: The bounds of the search box.
    /// - Returns: The collection of items within |bounds|, returned as an Array
    /// of `GQTPointQuadTreeItem1`.
    func search(withBounds searchBounds: GQTBounds1) -> [GQTPointQuadTreeItem1] {
        var results: [GQTPointQuadTreeItem1] = []
        root.search(withBounds: searchBounds, withOwnBounds: bounds, results: &results)
        return results
    }

    // MARK: - `getCount`
    /// The number of items in this entire tree.
    ///
    /// - Returns: The number of items.
    func getCount() -> Int {
        return count
    }
}
