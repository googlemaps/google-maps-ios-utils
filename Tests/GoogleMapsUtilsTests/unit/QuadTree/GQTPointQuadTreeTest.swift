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

import XCTest

@testable import GoogleMapsUtils

// A utility function to generate random numbers within a range
func randd(min: Double, max: Double) -> Double {
    let range = max - min
    return min + range * Double(arc4random_uniform(1000)) / 1000.0
}

final class GQTPointQuadTreeTest: XCTestCase {

    func item(at point: GQTPoint) -> GQTPointQuadTreeItem {
        return GQTPointQuadTreeItemMock(points: point)
    }

    // MARK: - Tests
    func testRemoveNonExistingItemIgnored() {
        let tree = GQTPointQuadTree()
        let item = item(at: GQTPoint(x: 0.5, y: 0.5))
        _ = tree.add(item: item)

        let newItem = self.item(at: GQTPoint(x: 0.5, y: 0.5))
        let result = tree.remove(item: newItem)

        XCTAssertFalse(result)
        XCTAssertEqual(tree.count, 1)
    }

    func testRemoveOutsideItemIgnored() {
        let tree = GQTPointQuadTree()
        let item = item(at: GQTPoint(x: 1.5, y: 1.5))
        let result = tree.remove(item: item)

        XCTAssertFalse(result)
        XCTAssertEqual(tree.count, 0)
    }

    func testClear() {
        let tree = GQTPointQuadTree()
        _ = tree.add(item: item(at: GQTPoint(x: 0.5, y: 0.5)))
        _ = tree.add(item: item(at: GQTPoint(x: 1.0, y: 1.0)))
        XCTAssertEqual(tree.count, 2)

        tree.clear()

        XCTAssertEqual(tree.count, 0)
    }

    func testSearchWithBounds() {
        let tree = GQTPointQuadTree()
        _ = tree.add(item: item(at: GQTPoint(x: 0.5, y: 0.5)))
        _ = tree.add(item: item(at: GQTPoint(x: -0.5, y: 0.5)))
        _ = tree.add(item: item(at: GQTPoint(x: -0.5, y: -0.5)))
        _ = tree.add(item: item(at: GQTPoint(x: -0.5, y: -0.5)))
    
        var items = tree.search(withBounds: GQTBounds(minX: -1, minY: -1, maxX: 1, maxY: 1))
        XCTAssertEqual(items.count, 4)
        
        items = tree.search(withBounds: GQTBounds(minX: -1, minY: -1, maxX: -0.6, maxY: -0.6))
        XCTAssertEqual(items.count, 0)

        items = tree.search(withBounds: GQTBounds(minX: 0.6, minY: 0.6, maxX: 1, maxY: 1))
        XCTAssertEqual(items.count, 0)

        items = tree.search(withBounds: GQTBounds(minX: 0, minY: 0, maxX: 0.6, maxY: 0.6))
        XCTAssertEqual(items.count, 1)

        items = tree.search(withBounds: GQTBounds(minX: -1, minY: -1, maxX: 1, maxY: 0))
        XCTAssertEqual(items.count, 2)
    }

    func testSearchWithBoundsRandomizedItems() {
        let tree = GQTPointQuadTree()

        // Adding items to the tree
        for item in itemsFullyInside(bounds: GQTBounds(minX: -1, minY: -1, maxX: 0, maxY: 0), count: 10) {
            _ = tree.add(item: item)
        }

        for item in itemsFullyInside(bounds: GQTBounds(minX: -1, minY: 0, maxX: 0, maxY: 1), count: 20) {
            _ = tree.add(item: item)
        }

        for item in itemsFullyInside(bounds: GQTBounds(minX: 0, minY: 0, maxX: 1, maxY: 1), count: 30) {
            _ = tree.add(item: item)
        }

        for item in itemsFullyInside(bounds: GQTBounds(minX: 0, minY: -1, maxX: 1, maxY: 0), count: 40) {
            _ = tree.add(item: item)
        }

        // Now perform the search
        var items = tree.search(withBounds: GQTBounds(minX: -1, minY: -1, maxX: 1, maxY: 1))
        XCTAssertEqual(items.count, 100)  // Expecting 100 items

        items = tree.search(withBounds: GQTBounds(minX: -1, minY: -1, maxX: 0, maxY: 0))
        XCTAssertEqual(items.count, 10)   // Expecting 10 items

        items = tree.search(withBounds: GQTBounds(minX: -1, minY: 0, maxX: 0, maxY: 1))
        XCTAssertEqual(items.count, 20)   // Expecting 20 items

        items = tree.search(withBounds: GQTBounds(minX: 0, minY: 0, maxX: 1, maxY: 1))
        XCTAssertEqual(items.count, 30)   // Expecting 30 items

        items = tree.search(withBounds: GQTBounds(minX: 0, minY: -1, maxX: 1, maxY: 0))
        XCTAssertEqual(items.count, 40)   // Expecting 40 items
    }
    
    func testAddInsideItemAdded() {
        let tree = GQTPointQuadTree()
        let item = item(at: GQTPoint(x: 0.5, y: 0.5))
        let result = tree.add(item: item)

        XCTAssertTrue(result)
        XCTAssertEqual(tree.count, 1)
    }

    func testAddInsideItemIgnored() {
        let tree = GQTPointQuadTree(bounds: GQTBounds(minX: -0.2, minY: -0.2, maxX: 0.2, maxY: 0.2))
        let item = item(at: GQTPoint(x: 0.5, y: 0.5))
        let result = tree.add(item: item)

        XCTAssertFalse(result)
        XCTAssertEqual(tree.count, 0)
    }

    func testRemoveAddedItemRemoved() {
        let tree = GQTPointQuadTree()
        let item = item(at: GQTPoint(x: 0.5, y: 0.5))
        _ = tree.add(item: item)

        let result = tree.remove(item: item)

        XCTAssertTrue(result)
        XCTAssertEqual(tree.count, 0)
    }

    func testAddNilItemIgnored() {
        let tree = GQTPointQuadTree()

        let result = tree.add(item: nil)

        XCTAssertFalse(result)
        XCTAssertEqual(tree.count, 0)
    }

    // MARK: - Utilities
    func itemsFullyInside(bounds: GQTBounds, count: Int) -> [GQTPointQuadTreeItem] {
        var items = [GQTPointQuadTreeItem]()
        for _ in 0..<count {
            let point = GQTPoint(x: randd(min: bounds.minX + Double.ulpOfOne, max: bounds.maxX - Double.ulpOfOne),
                               y: randd(min: bounds.minY + Double.ulpOfOne, max: bounds.maxY - Double.ulpOfOne))
            items.append(item(at: point))
        }
        return items
    }
}
