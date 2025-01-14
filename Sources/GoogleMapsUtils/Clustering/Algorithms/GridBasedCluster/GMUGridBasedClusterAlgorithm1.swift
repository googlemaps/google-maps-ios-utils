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

/// TO-DO: Rename the class to `GMUGridBasedClusterAlgorithm` once the linking is done and remove the objective c class.
/// A simple algorithm which devides the map into a grid where a cell has fixed dimension in screen space.
///
final class GMUGridBasedClusterAlgorithm1: GMUClusterAlgorithm1 {

    // MARK: - Properties
    /// Internal array to store cluster items.
    private var clusterItems: [GMUClusterItem1]
    /// Grid cell dimension in pixels to keep clusters about 100 pixels apart on screen.
    private let gmuGridCellSizePoints: Float = 100.0

    // MARK: - Initializers
    init() {
        clusterItems = []
    }

    // MARK: - Methods
    /// Adds an array of items to the grid based cluster algorithm.
    ///
    /// - Parameter items: Array of items conforming to `GMUClusterItem` protocol.
    func addItems(_ items: [GMUClusterItem1]) {
        clusterItems.append(contentsOf: items)
    }

    /// Removes a specific item from the grid based cluster algorithm.
    ///
    /// - Parameter item: The item conforming to `GMUClusterItem` protocol to be removed.
    func removeItem(_ item: GMUClusterItem1) {
        clusterItems.removeAll { $0 === item }
    }

    /// Clears all items from the grid based cluster algorithm.
    func clearItems() {
        clusterItems.removeAll()
    }

    /// Returns an array of clusters at the specified zoom level.
    ///
    /// - Parameter zoom: The zoom level at which to compute clusters.
    /// - Returns: An array of clusters conforming to `GMUCluster` protocol.
    func clusters(atZoom zoom: Float) -> [GMUCluster1] {
        var clusters: [Int : GMUCluster1] = [:]

        // Divide the whole map into a numCells x numCells grid and assign items to them.
        let numCells: Int = Int(ceil(256 * pow(2, zoom) / gmuGridCellSizePoints))

        for item in clusterItems {
            let point: GMSMapPoint = GMSProject(item.position)
            /// point.x is in [-1, 1] range
            let col: Int = Int(Double(numCells) * (1.0 + point.x) / 2.0)
            /// point.y is in [-1, 1] range
            let row: Int = Int(Double(numCells) * (1.0 + point.y) / 2.0)
            let index: Int = numCells * row + col
            var cluster: GMUStaticCluster1? = clusters[index] as? GMUStaticCluster1
            if cluster == nil {
                // Normalize cluster's centroid to center of the cell.
                let newNumCells = Double(numCells - 1)
                let xCoordinate = Double((Double(col) + 0.5) * 2.0 / newNumCells)
                let yCoordinate = Double((Double(row) + 0.5) * 2.0 / newNumCells)
                let mapPoint: GMSMapPoint = GMSMapPoint(x: xCoordinate, y: yCoordinate)
                let position: CLLocationCoordinate2D = GMSUnproject(mapPoint)
                cluster = GMUStaticCluster1(position: position)
                clusters[index] = cluster
            }
            cluster?.addItem(item)
        }
        return Array(clusters.values)
    }
}
