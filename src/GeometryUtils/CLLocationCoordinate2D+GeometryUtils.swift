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

public extension CLLocationCoordinate2D {

  /// Returns the great circle distance between this coordinate and `to`.
  ///
  /// - Parameters:
  ///   - to: The CLLocationCoordinate2D to compute the distance from
  /// - Returns: The great circle distance from this coordinate and `to`
  func distance(to: CLLocationCoordinate2D) -> CLLocationDistance {
    return distanceRadius(to: to, radius: kGMSEarthRadius)
  }
}

private extension CLLocationCoordinate2D {
  /// Returns the great circle distance between this coordinate and `to` on a sphere with radius `radius` in meters.
  ///
  /// - Parameters:
  ///   - to: The CLLocationCoordinate2D to compute the distance from
  ///   - radius: The radius in meters
  /// - Returns: The great circle distance
  func distanceRadius(to: CLLocationCoordinate2D, radius: CLLocationDistance) -> CLLocationDistance {
    let unitDistance = Math.inverseHaversine(Math.haversineDistance(self.latLngRadians, to.latLngRadians))
    return radius * unitDistance
  }
}
