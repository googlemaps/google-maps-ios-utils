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

/// A class that represents a weighted geographical point on the earth's surface, implementing the `GQTPointQuadTreeItem` protocol.
///
public final class GMUWeightedLatLng: GQTPointQuadTreeItem, Equatable {

    // MARK: - Properties
    /// The intensity of the data point. The scale is arbitrary, assumed to be linear.
    /// Intensity of 3 is equivalent to three co-located points with intensity 1.
    let intensity: Float
    /// Internal storage for the projected 2D point.
    private var pointValue: GQTPoint

    // MARK: - Initializers
    /// Designated initializer to create an instance of `GMUWeightedLatLng`.
    ///
    /// - Parameters:
    ///   - coordinate: The geographical coordinate (latitude and longitude) of the data point.
    ///   - intensity: The intensity of the data point.
    public init(coordinate: CLLocationCoordinate2D, intensity: Float) {
        self.intensity = intensity
        let mapPoint = GMSProject(coordinate)
        self.pointValue = GQTPoint(x: mapPoint.x, y: mapPoint.y)
    }

    // MARK: - `GQTPointQuadTreeItem`
    /// Getter for the `GQTPoint` representation of the coordinate in the projected 2D space.
    ///
    func point() -> GQTPoint {
        return pointValue
    }

    /// This is a custom implementation of the `Equatable` protocol for the `GMUWeightedLatLng` class.
    ///
    /// - The `==` operator compares two instances of `GMUWeightedLatLng`.
    /// - Currently, it returns `true` for all comparisons, which is **incorrect** and should be avoided in most cases.
    public static func == (lhs: GMUWeightedLatLng, rhs: GMUWeightedLatLng) -> Bool {
        return true
    }
}
