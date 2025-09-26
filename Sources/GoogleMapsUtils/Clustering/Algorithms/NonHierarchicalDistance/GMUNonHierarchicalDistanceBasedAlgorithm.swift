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

import GoogleMaps

/// A simple clustering algorithm with O(nlog n) performance.
/// Resulting clusters are not hierarchical.
/// High level algorithm:
/// 1. Iterate over items in the order they were added (candidate clusters).
/// 2. Create a cluster with the center of the item.
/// 3. Add all items that are within a certain distance to the cluster.
/// 4. Move any items out of an existing cluster if they are closer to another cluster.
/// 5. Remove those items from the list of candidate clusters.
/// Clusters have the center of the first element (not the centroid of the items within it).
///
public final class GMUNonHierarchicalDistanceBasedAlgorithm: GMUClusterAlgorithm {

    // MARK: - Properties
    /// MapPoint is in a [-1,1]x[-1,1] space.
    private let mapPointWidth: Double = 2.0
    private var clusterItems: [GMUClusterItem]
    private var quadTree: GQTPointQuadTree
    private var clusterDistancePoints: Int

    // MARK: - Initializers
    /// Initializes this GMUNonHierarchicalDistanceBasedAlgorithm with clusterDistancePoints
    /// for the distance it uses to cluster items (default is 100).
    /// 
    /// - Parameter clusterDistancePoints: The distance in points used for clustering.
    public init(clusterDistancePoints: Int) {
        self.clusterItems = []
        let bounds = GQTBounds(minX: -1, minY: -1, maxX: 1, maxY: 1)
        self.quadTree = GQTPointQuadTree(bounds: bounds)
        self.clusterDistancePoints = clusterDistancePoints
    }
    
    /// Convenience init with default(100) `clusterDistancePoints`
    ///
    public convenience init() {
        self.init(clusterDistancePoints: 100)
    }

    // MARK: - Protocol Method's
    /// Adds an array of items to the non-hierarchical distance based cluster algorithm and quad tree.
    ///
    /// - Parameter items: Array of items conforming to `GMUClusterItem` protocol.
    public func addItems(_ items: [GMUClusterItem]) {
        clusterItems.append(contentsOf: items)
        for item in items {
            let quadItem = GMUClusterItemQuadItem(clusterItem: item)
            _ = quadTree.add(item: quadItem)
        }
    }

    /// Removes a specific item from the non-hierarchical distance based cluster algorithm and quad tree.
    ///
    /// - Parameter item: The item conforming to `GMUClusterItem` protocol to be removed.
    public func removeItem(_ item: GMUClusterItem) {
        clusterItems.removeAll { $0 === item }
        let quadItem = GMUClusterItemQuadItem(clusterItem: item)
        _ = quadTree.remove(item: quadItem)
    }

    /// Clears all items from the non-hierarchical distance based cluster algorithm and quad tree.
    public func clearItems() {
        clusterItems.removeAll()
        quadTree.clear()
    }

    /// Returns an array of clusters at the specified zoom level.
    ///
    /// - Parameter zoom: The zoom level at which to compute clusters.
    /// - Returns: An array of clusters conforming to `GMUCluster` protocol.
    public func clusters(atZoom zoom: Float) -> [GMUCluster] {
        var clusters: [GMUCluster] = []
        var itemToClusterMap: [GMUWrappingDictionaryKey: GMUCluster] = [:]
        var itemToClusterDistanceMap: [GMUWrappingDictionaryKey: Double] = [:]
        var processedItems: [GMUClusterItem] = []

        for item in clusterItems {
            if processedItems.contains(where: { $0 === item }) {
                continue
            }

            let cluster: GMUStaticCluster = GMUStaticCluster(position: item.position)
            let point: GMSMapPoint = GMSProject(item.position)
            // Query items within a fixed point distance to form a cluster.
            let radius: Double = Double(clusterDistancePoints) * mapPointWidth / pow(2.0, Double(zoom) + 8.0)
            let bounds: GQTBounds = GQTBounds(minX: point.x - radius, minY: point.y - radius, maxX: point.x + radius, maxY: point.y + radius)
            let nearbyItems: [GQTPointQuadTreeItem] = quadTree.search(withBounds: bounds)

            for quadItem in nearbyItems {
                guard let quadItem = quadItem as? GMUClusterItemQuadItem else {
                    continue
                }
                let nearbyItem: GMUClusterItem = quadItem.gmuClusterItem
                processedItems.append(nearbyItem)
                let nearbyItemPoint: GMSMapPoint = GMSProject(nearbyItem.position)
                let key: GMUWrappingDictionaryKey = GMUWrappingDictionaryKey(object: nearbyItem)
                let distanceSquared: Double = distanceSquared(between: point, and: nearbyItemPoint)
                if let existingDistance = itemToClusterDistanceMap[key] {
                    if existingDistance < distanceSquared {
                        /// Already belongs to a closer cluster.
                        continue
                    }
                    if let existingCluster: GMUStaticCluster = itemToClusterMap[key] as? GMUStaticCluster {
                        existingCluster.removeItem(nearbyItem)
                    }
                }
                itemToClusterDistanceMap[key] = distanceSquared
                itemToClusterMap[key] = cluster
                cluster.addItem(nearbyItem)
            }
            clusters.append(cluster)
        }

        assert(itemToClusterDistanceMap.count == clusterItems.count, "All items should be mapped to a distance")
        assert(itemToClusterMap.count == clusterItems.count, "All items should be mapped to a cluster")

#if DEBUG
        let totalCount = clusters.reduce(0) { $0 + $1.count }
        assert(clusterItems.count == totalCount, "All clusters combined should make up original item set")
#endif

        return clusters
    }

    // MARK: - Private method
    /// Calculates squared distance between two GMSMapPoint's.
    ///
    private func distanceSquared(between pointA: GMSMapPoint, and pointB: GMSMapPoint) -> Double {
        let deltaX: Double = pointA.x - pointB.x
        let deltaY: Double = pointA.y - pointB.y
        return deltaX * deltaX + deltaY * deltaY
    }
}

// MARK: - `GMUClusterItemQuadItem`
/// A class to represent the cluster Quad item and its projected point.
///
final private class GMUClusterItemQuadItem: NSObject, GQTPointQuadTreeItem {

    // MARK: - Properties
    let gmuClusterItem: GMUClusterItem
    private var clusterItemPoint: GQTPoint

    // MARK: - Initializers
    init(clusterItem: GMUClusterItem) {
        self.gmuClusterItem = clusterItem
        let point = GMSProject(clusterItem.position)
        self.clusterItemPoint = GQTPoint(x: point.x, y: point.y)
    }

    // MARK: - Method
    /// Method to retrieve the GQTPoint of the cluster item
    /// - Returns: `GQTPoint`
    func point() -> GQTPoint {
        return clusterItemPoint
    }

    // MARK: - Override's
    /// Forward the hash value to the underlying object.
    override var hash: Int {
        // Use the `hash` property of the wrapped object to provide the hash value.
        return (gmuClusterItem as AnyObject).hash
    }

    /// Forward the equality check to the underlying object.
    override func isEqual(_ object: Any?) -> Bool {
        // If both instances are the same, return true.
        if self === object as AnyObject {
            return true
        }

        // Check if the object is of the same type, and then compare the underlying objects.
        guard let other = object as? GMUClusterItemQuadItem else {
            return false
        }
        return (self.gmuClusterItem as AnyObject).isEqual(other.gmuClusterItem)
    }
}
