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

/// TO-DO: Rename the class to `GMUWeightedLatLng` once the linking is done and remove the objective c class.
/// A class that represents a weighted geographical point on the earth's surface, implementing the `GQTPointQuadTreeItem` protocol.
///
final class GMUWeightedLatLng1: GQTPointQuadTreeItem1, Equatable {
    static func == (lhs: GMUWeightedLatLng1, rhs: GMUWeightedLatLng1) -> Bool {
        return true
    }
    

    // MARK: - Properties
    /// The intensity of the data point. The scale is arbitrary, assumed to be linear.
    /// Intensity of 3 is equivalent to three co-located points with intensity 1.
    let intensity: Float
    /// Internal storage for the projected 2D point.
    private var pointValue: GQTPoint1

    // MARK: - Initializers
    /// Designated initializer to create an instance of `GMUWeightedLatLng`.
    ///
    /// - Parameters:
    ///   - coordinate: The geographical coordinate (latitude and longitude) of the data point.
    ///   - intensity: The intensity of the data point.
    init(coordinate: CLLocationCoordinate2D, intensity: Float) {
        self.intensity = intensity
        let mapPoint = GMSProject(coordinate)
        self.pointValue = GQTPoint1(x: mapPoint.x, y: mapPoint.y)
    }

    // MARK: - `GQTPointQuadTreeItem`
    /// Getter for the `GQTPoint` representation of the coordinate in the projected 2D space.
    ///
    func point() -> GQTPoint1 {
        return pointValue
    }
}
