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

import CoreLocation

/// Describes a point on the globe in a projected coordinate system.
///
/// The value of `x`, the longitude projection, is in the  range [-1, 1].
/// The axis direction behaves such that increasing `y` values go towards North,
/// and increasing `x` values go towards East.
///
/// The point (0, 0) is the coordinate at lat, long (0, 0).
public struct MapPoint {
  var x: Double
  var y: Double
}

public extension CLLocationCoordinate2D {
  /// Projects this coordinate to the map and returns a MapPoint
  var mapPoint: MapPoint {
    return MapPoint(
      x: Math.mercatorX(longitudeInDegrees: longitude),
      y: Math.mercatorY(latitudeInDegrees: latitude)
    )
  }
}

public extension MapPoint {
  /// Unprojects this point from the map
  var location: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(
      latitude: Math.inverseMercatorLatitudeDegrees(y),
      longitude: Math.inverseMercatorLongitudeDegrees(x)
    )
  }

  /// Returns the length of the segment from this to `to` in projected space.
  /// The length is computed along the short path between the points potentially crossing the date line.
  /// E.g. the distance between the points corresponding to San Francisco and Tokyo measures the segment that passes north of Hawaii crossing the date line.
  func distance(to: MapPoint) -> Double {
    let dy = self.y - to.y
    let dx = self.x - to.x
    var dx2 = dx * dx
    if (dx2 > 1) {  // Equivalent to abs(dx) > 1.
      let dxprim = 2 - abs(dx)
      dx2 = dxprim * dxprim
    }
    return sqrt(dx2 + dy * dy)
  }

  /// Returns a linearly interpolated point on the segment `from` to `to` by `fraction`.
  /// t==0 corresponds to `from`, t==1 corresponds to `to`.
  ///
  /// The interpolation takes place along the short path between the points potentially crossing the date line.
  /// E.g. interpolating from San Francisco to Tokyo will pass north of Hawaii and cross the date line.
  static func interpolate(from: MapPoint, to: MapPoint, fraction: Double) -> MapPoint {
    let v = 1 - fraction
    var ax = from.x
    var bx = to.x

    // Rotate towards positive only so that we can avoid abs() on normalizing interpolateX below.
    let worldWidth = 2.0
    if (ax < bx) {
      ax += worldWidth
    } else {
      bx += worldWidth
    }
    var interpolateX = (ax * v) + (bx * fraction)
    if (interpolateX > 1) {
      interpolateX -= worldWidth
    }
    let interpolateY = (from.y * v) + (to.y * fraction)
    return MapPoint(x: interpolateX, y: interpolateY)
  }
}
