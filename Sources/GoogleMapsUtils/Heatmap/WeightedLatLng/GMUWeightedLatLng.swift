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

/// A quad tree item which represents a data point of given intensity at a given point on the earth's
/// surface.
/// 
/// ```swift
/// let point = GMUWeightedLatLng(coordinate: location, intensity: 1.5)
/// heatmapLayer.weightedData = [point]
/// ```
///
/// ## Topics
///
/// ### Properties
/// - ``intensity``
///
/// ### Protocol Conformance
/// - ``point()``
public final class GMUWeightedLatLng: GQTPointQuadTreeItem, Equatable {

    // MARK: - Properties
    /// The intensity of the data point. The scale is arbitrary, assumed to be linear.
    /// Intensity of 3 is equivalent to three co-located points with intensity 1.
    public let intensity: Float
    /// Internal storage for the projected 2D point.
    private var pointValue: GQTPoint

    // MARK: - Initializers
    /// Creates a weighted point for heatmap data.
    ///
    /// - Parameters:
    ///   - coordinate: The geographic location
    ///   - intensity: The intensity value (higher = hotter)
    public init(coordinate: CLLocationCoordinate2D, intensity: Float) {
        self.intensity = intensity
        let mapPoint = GMSProject(coordinate)
        self.pointValue = GQTPoint(x: mapPoint.x, y: mapPoint.y)
    }

    // MARK: - `GQTPointQuadTreeItem`
    /// Returns the point's location for spatial indexing.
    public func point() -> GQTPoint {
        return pointValue
    }

    /// This is a custom implementation of the `Equatable` protocol for the `GMUWeightedLatLng` class.
    ///
    /// - The `==` operator compares two instances of `GMUWeightedLatLng`.
    /// - Currently, it returns `true` for all comparisons, which is **incorrect** and should be avoided in most cases.
    public static func == (lhs: GMUWeightedLatLng, rhs: GMUWeightedLatLng) -> Bool {
        return lhs.intensity == rhs.intensity && 
               lhs.pointValue.x == rhs.pointValue.x && 
               lhs.pointValue.y == rhs.pointValue.y
    }
}
