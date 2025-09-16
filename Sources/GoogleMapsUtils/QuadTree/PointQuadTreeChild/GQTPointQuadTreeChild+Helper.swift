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


// MARK: - GQTPointQuadTreeChild Constants

/// Configuration constants for quad tree nodes.
public struct GQTPointQuadTreeChildConstants {
    
    /// Maximum items per node before splitting.
    public static let maxElements: Int = 64
    
    /// Maximum tree depth to prevent infinite subdivision.
    public static let maxDepth: Int = 30
}

/// Helper methods for spatial calculations.
/// - ``boundsTopLeftChildBounds(_:)``
/// - ``boundsBottomRightChildBounds(_:)``
/// - ``boundsBottomLeftChildBounds(_:)``
public extension GQTPointQuadTreeChild {

    /// Calculates the center point of a rectangular boundary.
    ///
    /// This method computes the geometric center by averaging the minimum and maximum
    /// coordinates in both dimensions.
    ///
    /// - Parameter bounds: The rectangular bounds to find the center of.
    ///
    /// - Returns: A ``GQTPoint`` representing the center coordinates of the bounds.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bounds = GQTBounds(minX: 0, minY: 0, maxX: 10, maxY: 10)
    /// let center = boundsMidpoint(bounds)
    /// // center.x = 5.0, center.y = 5.0
    /// ```
    func boundsMidpoint(_ bounds: GQTBounds) -> GQTPoint {
        return GQTPoint(x: (bounds.minX + bounds.maxX) / 2, y: (bounds.minY + bounds.maxY) / 2)
    }

    /// Calculates the bounds for the top-right child quadrant.
    ///
    /// The top-right quadrant extends from the center point to the maximum coordinates
    /// of the parent bounds.
    ///
    /// - Parameter parentBounds: The bounds of the parent node to subdivide.
    ///
    /// - Returns: A ``GQTBounds`` representing the top-right quadrant of the parent bounds.
    ///
    /// ## Quadrant Layout
    /// ```
    /// ┌─────────┬─────────┐
    /// │ Top-Left│Top-Right│ ← This quadrant
    /// │         │    ●    │
    /// ├─────────┼─────────┤
    /// │Bot-Left │Bot-Right│
    /// │         │         │
    /// └─────────┴─────────┘
    /// ```
    func boundsTopRightChildBounds(_ parentBounds: GQTBounds) -> GQTBounds {
        let midPoint = boundsMidpoint(parentBounds)
        return GQTBounds(minX: midPoint.x, minY: midPoint.y, maxX: parentBounds.maxX, maxY: parentBounds.maxY)
    }

    /// Calculates the bounds for the top-left child quadrant.
    ///
    /// The top-left quadrant extends from the minimum X and center Y coordinates
    /// to the center X and maximum Y coordinates.
    ///
    /// - Parameter parentBounds: The bounds of the parent node to subdivide.
    ///
    /// - Returns: A ``GQTBounds`` representing the top-left quadrant of the parent bounds.
    ///
    /// ## Quadrant Layout
    /// ```
    /// ┌─────────┬─────────┐
    /// │ Top-Left│Top-Right│
    /// │    ●    │         │ ← This quadrant
    /// ├─────────┼─────────┤
    /// │Bot-Left │Bot-Right│
    /// │         │         │
    /// └─────────┴─────────┘
    /// ```
    func boundsTopLeftChildBounds(_ parentBounds: GQTBounds) -> GQTBounds {
        let midPoint = boundsMidpoint(parentBounds)
        return GQTBounds(minX: parentBounds.minX, minY: midPoint.y, maxX: midPoint.x, maxY: parentBounds.maxY)
    }

    /// Calculates the bounds for the bottom-right child quadrant.
    ///
    /// The bottom-right quadrant extends from the center X and minimum Y coordinates
    /// to the maximum X and center Y coordinates.
    ///
    /// - Parameter parentBounds: The bounds of the parent node to subdivide.
    ///
    /// - Returns: A ``GQTBounds`` representing the bottom-right quadrant of the parent bounds.
    ///
    /// ## Quadrant Layout
    /// ```
    /// ┌─────────┬─────────┐
    /// │ Top-Left│Top-Right│
    /// │         │         │
    /// ├─────────┼─────────┤
    /// │Bot-Left │Bot-Right│
    /// │         │    ●    │ ← This quadrant
    /// └─────────┴─────────┘
    /// ```
    func boundsBottomRightChildBounds(_ parentBounds: GQTBounds) -> GQTBounds {
        let midPoint = boundsMidpoint(parentBounds)
        return GQTBounds(minX: midPoint.x, minY: parentBounds.minY, maxX: parentBounds.maxX, maxY: midPoint.y)
    }

    /// Calculates the bounds for the bottom-left child quadrant.
    ///
    /// The bottom-left quadrant extends from the minimum coordinates of the parent
    /// to the center point.
    ///
    /// - Parameter parentBounds: The bounds of the parent node to subdivide.
    ///
    /// - Returns: A ``GQTBounds`` representing the bottom-left quadrant of the parent bounds.
    ///
    /// ## Quadrant Layout
    /// ```
    /// ┌─────────┬─────────┐
    /// │ Top-Left│Top-Right│
    /// │         │         │
    /// ├─────────┼─────────┤
    /// │Bot-Left │Bot-Right│
    /// │    ●    │         │ ← This quadrant
    /// └─────────┴─────────┘
    /// ```
    func boundsBottomLeftChildBounds(_ parentBounds: GQTBounds) -> GQTBounds {
        let midPoint = boundsMidpoint(parentBounds)
        return GQTBounds(minX: parentBounds.minX, minY: parentBounds.minY, maxX: midPoint.x, maxY: midPoint.y)
    }

    /// Tests whether two rectangular bounds intersect or overlap.
    ///
    /// Two rectangles intersect if they share any common area, including when they
    /// only touch at edges or corners. This method is used during spatial queries
    /// to determine which quadrants need to be searched.
    ///
    /// - Parameters:
    ///   - bounds1: The first rectangular boundary to test.
    ///   - bounds2: The second rectangular boundary to test.
    ///
    /// - Returns: `true` if the rectangles intersect or touch, `false` if they are completely separate.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let rect1 = GQTBounds(minX: 0, minY: 0, maxX: 5, maxY: 5)
    /// let rect2 = GQTBounds(minX: 3, minY: 3, maxX: 8, maxY: 8)
    /// let intersects = boundsIntersectsBounds(rect1, rect2) // true - they overlap
    ///
    /// let rect3 = GQTBounds(minX: 10, minY: 10, maxX: 15, maxY: 15)
    /// let separate = boundsIntersectsBounds(rect1, rect3) // false - no overlap
    /// ```
    func boundsIntersectsBounds(_ bounds1: GQTBounds, _ bounds2: GQTBounds) -> Bool {
        return !(bounds1.maxY < bounds2.minY || bounds2.maxY < bounds1.minY) &&
        !(bounds1.maxX < bounds2.minX || bounds2.maxX < bounds1.minX)
    }
}

