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
/// The struct maintains constants for `GQTPointQuadTreeChild` class.
///
struct GQTPointQuadTreeChildConstants {
    static let maxElements: Int = 64
    static let maxDepth: Int = 30
}

/// This extension of `GQTPointQuadTreeChild` provides helper methods 
/// for calculating child quadrant bounds, the midpoint of node bounds,
/// and determining whether two bounding boxes intersect.
/// 
/// TO-DO: Rename the extension to `GQTPointQuadTreeChild` once the linking is done and remove the objective c class.
extension GQTPointQuadTreeChild1 {

    /// Calculates the midpoint of the given bounds.
    ///
    /// - Parameter bounds: The bounds for which the midpoint is to be calculated.
    /// - Returns: A `GQTPoint1` representing the midpoint of the given bounds.
    func boundsMidpoint(_ bounds: GQTBounds1) -> GQTPoint1 {
        return GQTPoint1(x: (bounds.minX + bounds.maxX) / 2, y: (bounds.minY + bounds.maxY) / 2)
    }

    /// Calculates the bounds for the top-right child quadrant of the parent bounds.
    ///
    /// - Parameter parentBounds: The bounds of the parent node.
    /// - Returns: A `GQTBounds1` representing the top-right child bounds of the parent node.
    func boundsTopRightChildBounds(_ parentBounds: GQTBounds1) -> GQTBounds1 {
        let midPoint = boundsMidpoint(parentBounds)
        return GQTBounds1(minX: midPoint.x, minY: midPoint.y, maxX: parentBounds.maxX, maxY: parentBounds.maxY)
    }

    /// Calculates the bounds for the top-left child quadrant of the parent bounds.
    ///
    /// - Parameter parentBounds: The bounds of the parent node.
    /// - Returns: A `GQTBounds1` representing the top-left child bounds of the parent node.
    func boundsTopLeftChildBounds(_ parentBounds: GQTBounds1) -> GQTBounds1 {
        let midPoint = boundsMidpoint(parentBounds)
        return GQTBounds1(minX: parentBounds.minX, minY: midPoint.y, maxX: midPoint.x, maxY: parentBounds.maxY)
    }

    /// Calculates the bounds for the bottom-right child quadrant of the parent bounds.
    ///
    /// - Parameter parentBounds: The bounds of the parent node.
    /// - Returns: A `GQTBounds1` representing the bottom-right child bounds of the parent node.
    func boundsBottomRightChildBounds(_ parentBounds: GQTBounds1) -> GQTBounds1 {
        let midPoint = boundsMidpoint(parentBounds)
        return GQTBounds1(minX: midPoint.x, minY: parentBounds.minY, maxX: parentBounds.maxX, maxY: midPoint.y)
    }

    /// Calculates the bounds for the bottom-left child quadrant of the parent bounds.
    ///
    /// - Parameter parentBounds: The bounds of the parent node.
    /// - Returns: A `GQTBounds1` representing the bottom-left child bounds of the parent node.
    func boundsBottomLeftChildBounds(_ parentBounds: GQTBounds1) -> GQTBounds1 {
        let midPoint = boundsMidpoint(parentBounds)
        return GQTBounds1(minX: parentBounds.minX, minY: parentBounds.minY, maxX: midPoint.x, maxY: midPoint.y)
    }

    /// Checks if two bounding boxes intersect with each other.
    ///
    /// - Parameters:
    ///   - bounds1: The first bounding box.
    ///   - bounds2: The second bounding box.
    /// - Returns: `true` if the two bounding boxes intersect; otherwise, `false`.
    func boundsIntersectsBounds(_ bounds1: GQTBounds1, _ bounds2: GQTBounds1) -> Bool {
        return !(bounds1.maxY < bounds2.minY || bounds2.maxY < bounds1.minY) &&
        !(bounds1.maxX < bounds2.minX || bounds2.maxX < bounds1.minX)
    }
}

