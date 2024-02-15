// Copyright 2020 Google LLC
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

public extension GMSPolygon {

  /// Returns whether or not `coordinate` is inside this polygon.
  func contains(coordinate: CLLocationCoordinate2D) -> Bool {
    guard let path = self.path else {
      return false
    }
    return path.contains(coordinate: coordinate, geodesic: geodesic)
  }

  /// Returns the area of this polygon.
  /// - Parameters:
  ///   - radius: the radius of the sphere. Defaults to `kGMSEarthRadius`
  /// - Returns: the area of this polygon, nil if the coordinates composing this polygon is invalid
  func area(radius: CLLocationDistance = kGMSEarthRadius) -> Double? {
    guard let path = self.path else {
      return nil
    }
    return path.area(radius: radius)
  }

  /// The signed area of this path on Earth which is considered. The result
  /// is positive if the points of path are in counter-clockwise order, and negative otherwise.
  /// - Parameters:
  ///   - radius: the radius of the sphere. Defaults to `kGMSEarthRadius`
  /// - Returns: the signed area of this polygon, nil if the coordinates composing this polygon is invalid
  func signedArea(radius: CLLocationDistance = kGMSEarthRadius) -> Double? {
    guard let path = self.path else {
      return nil
    }
    return path.signedArea(radius: radius)
  }
}
