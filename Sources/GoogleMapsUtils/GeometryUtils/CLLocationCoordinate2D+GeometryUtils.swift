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
    return distance(to: to, radius: kGMSEarthRadius)
  }

  /// Returns the initial heading (degrees clockwise from North) at this coordinate
  /// at the shortest distance to `to`.
  /// - Parameters:
  ///   - to: The CLLocationCoordinate2D to compute the heading from
  /// - Return: The initial heading between this coordinate and `to`
  func heading(to: CLLocationCoordinate2D) -> CLLocationDistance {
    let bearing = Math.initialBearing(self.latLngRadians, to.latLngRadians)
    return Math.wrap(value: bearing.degrees, min: 0, max: 360)
  }

  /// Returns the destination coordinate, when starting from this coordinate with initial `heading`,
  /// travelling `distance` meters along a great circle arc, on Earth.
  ///
  /// - Parameters:
  ///   - distance: The distance to offset by from this coordinate
  ///   - heading: The inital heading to offset by from this coordinate
  /// - Returns: The destination coordinate
  func offset(distance: CLLocationDistance, heading: CLLocationDistance) -> CLLocationCoordinate2D {
    return offset(distance: distance, heading: heading, radius: kGMSEarthRadius)
  }

  /// Returns the coordinate that lies a `fraction` of the way between this coordinate and `to`
  /// using the shortest path.
  ///
  /// - Parameters:
  ///   - to: The end coordinate for the interpolation
  ///   - fraction: The fraction to interpolate by
  /// - Returns: The interpolated coordinate
  func interpolate(to: CLLocationCoordinate2D, fraction: Double) -> CLLocationCoordinate2D {
    let angularDistance = distanceUnit(to: to) * fraction
    let heading = self.heading(to: to)
    return offsetUnit(angularDistance: angularDistance, heading: heading)
  }
}

private extension CLLocationCoordinate2D {
  /// Returns the great circle distance between this coordinate and `to` on a sphere with radius `radius` in meters.
  ///
  /// - Parameters:
  ///   - to: The CLLocationCoordinate2D to compute the distance from
  ///   - radius: The radius in meters
  /// - Returns: The great circle distance
  func distance(to: CLLocationCoordinate2D, radius: CLLocationDistance) -> CLLocationDistance {
    return radius * distanceUnit(to: to)
  }

  /// Returns the distance between this coordinate and `to` on the unit sphere.
  /// - Parameters:
  ///   - to: The CLLocationCoordinate2D to compute the distance from
  /// - Returns: The great circle distance on a unit sphere
  func distanceUnit(to: CLLocationCoordinate2D) -> CLLocationDistance {
    return Math.inverseHaversine(Math.haversineDistance(self.latLngRadians, to.latLngRadians))
  }

  /// Returns the destination coordinate, when starting from this coordinate with initial `heading`, travelling `distance` meters along a great circle arc
  /// on a sphere with radius `radius`.
  ///
  /// - Parameters:
  ///   - distance: The distance to offset by from this coordinate
  ///   - heading: The inital heading to offset by from this coordinate
  ///   - radius: The radius of the sphere
  /// - Returns: The destination coordinate
  func offset(
    distance: CLLocationDistance,
    heading: CLLocationDistance,
    radius: CLLocationDistance
  ) -> CLLocationCoordinate2D {
    let angularDistance = distance / radius
    return offsetUnit(angularDistance: angularDistance, heading: heading)
  }

  /// Offset this coordinate by the provided `angularDistance` and `heading` on a unit sphere
  ///
  /// - Parameters:
  ///   - angularDistance: The angular distance on a unit sphere
  ///   - heading: The inital heading to offset by from this coordinate
  /// - Returns: The destination coordinate
  func offsetUnit(angularDistance: Double, heading: CLLocationDistance) -> CLLocationCoordinate2D {
    let bearing = heading.radians
    let latLng1 = self.latLngRadians
    let sinLat2 = sin(latLng1.latitude) * cos(angularDistance) + cos(latLng1.latitude) * sin(angularDistance) * cos(bearing)
    let lat2 = asin(sinLat2)
    let y = sin(bearing) * sin(angularDistance) * cos(latLng1.latitude)
    let x = cos(angularDistance) - sin(latLng1.latitude) * sinLat2
    let lng2 = latLng1.longitude + atan2(y, x)
    return CLLocationCoordinate2D(
      latitude: lat2.degrees,
      longitude: Math.wrap(value: lng2.degrees, min: -180, max: 180)
    )
  }
}
