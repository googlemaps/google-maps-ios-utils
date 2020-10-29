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

public extension GMSPath {

  /// Returns whether or not `coordinate` is inside this path which is always considered to be closed
  /// regardless if the last point of this path equals the first or not. This path is described by great circle
  /// segments if `geodesic` is true, otherwise, it is described by rhumb (loxodromic) segments.
  ///
  /// If `coordinate` is exactly equal to one of the vertices, the result is true. A point that is not equal to a
  /// vertex is on one side or the other of any path segment—it can never be "exactly on the border".
  ///
  /// Note: "Inside" is defined as not containing the South Pole—the South Pole is always considered outside.
  func contains(coordinate: CLLocationCoordinate2D, geodesic: Bool) -> Bool {

    let coordinates = self.coordinates

    // Naming: the segment is latLng1 to latLng2 and the point is latLng3
    guard var latLng1 = coordinates.last?.latLngRadians else {
      return false
    }
    let latLng3 = coordinate.latLngRadians

    var intersectionsCount = 0

    for coord in coordinates {
      let wrappedLng3 = Math.wrap(value: latLng3.longitude - latLng1.longitude, min: -.pi, max: .pi)

      // Special-case: coordinate equal to one of the vertices.
      if (latLng3.latitude == latLng1.latitude && wrappedLng3 == 0) {
        return true
      }

      let latLng2 = coord.latLngRadians
      let wrappedLng2 = Math.wrap(value: latLng2.longitude - latLng1.longitude, min: -.pi, max: .pi)

      if intersects(
            lat1: latLng1.latitude,
            latLng2: LatLngRadians(latitude: latLng2.latitude, longitude: wrappedLng2),
            latLng3: LatLngRadians(latitude: latLng3.latitude, longitude: wrappedLng3),
            geodesic: geodesic
      ) {
        intersectionsCount += 1
      }
      latLng1 = latLng2
    }
    return intersectionsCount % 2 == 1
  }
}

private extension GMSPath {

  var coordinates: [CLLocationCoordinate2D] {
    var coords: [CLLocationCoordinate2D] = []
    for idx in 0..<self.count() {
      coords.append(self.coordinate(at: idx))
    }
    return coords
  }

  /// Computes whether the vertical segment `latLng3` to South Pole intersects the
  /// segment (`lat1`, 0) to `latLng2`. Longitudes are offset by -`lng1`, the implicit
  /// lng1 becomes 0.
  func intersects(
    lat1: LocationRadians,
    latLng2: LatLngRadians,
    latLng3: LatLngRadians,
    geodesic: Bool
  ) -> Bool {

    // Both ends on the same side of lng3 doesn't intersect
    if ((latLng3.longitude >= 0 && latLng3.longitude >= latLng2.longitude) ||
          (latLng3.longitude < 0 && latLng3.longitude < latLng2.longitude)) {
        return false
    }

    // Point is South Pole.
    if (latLng3.latitude <= -.pi / 2) {
        return false
    }

    // Any segment end is a pole.
    if (lat1 <= -.pi / 2 || latLng2.latitude <= -.pi / 2 || lat1 >= .pi / 2 || latLng2.latitude >= .pi / 2) {
        return false
    }

    if (latLng2.longitude <= -.pi) {
        return false
    }

    let linearLat = (lat1 * (latLng2.longitude - latLng3.longitude) + latLng2.latitude * latLng3.longitude) / latLng2.longitude

    // Northern hemisphere and point under lat-lng line.
    if (lat1 >= 0 && latLng2.latitude >= 0 && latLng3.latitude < linearLat) {
        return false
    }

    // Southern hemisphere and point above lat-lng line.
    if (lat1 <= 0 && latLng2.latitude <= 0 && latLng3.latitude >= linearLat) {
        return true
    }
    // North Pole.
    if (latLng3.latitude >= .pi / 2) {
        return true
    }
    // Compare lat3 with latitude on the GC/Rhumb segment corresponding to lng3.
    // Compare through a strictly-increasing function (tan() or mercator()) as convenient.
    return geodesic ?
      tan(latLng3.latitude) >= tanLatGreatCircle(lat1: lat1, latLng2: latLng2, lng3: latLng3.longitude) :
      Math.mercatorY(latitudeInRadians: latLng3.latitude) >= mercatorLatRhumb(lat1: lat1, latLng2: latLng2, lng3: latLng3.longitude)
  }

  /// Returns tan(latitude-at-lng3) on the great circle (`lat1`, 0) to `latLng2`.
  func tanLatGreatCircle(lat1: LocationRadians, latLng2: LatLngRadians, lng3: LocationRadians) -> LocationRadians {
    return (tan(lat1) * sin(latLng2.longitude - lng3) + tan(latLng2.latitude) * sin(lng3)) / sin(latLng2.longitude)
  }

  /// Returns  mercator(latitude-at-lng3) on the Rhumb line (`lat1`, 0) to `latLng2`.
  func mercatorLatRhumb(lat1: LocationRadians, latLng2: LatLngRadians, lng3: LocationRadians) -> LocationRadians {
    return (
      Math.mercatorY(latitudeInRadians: lat1) * (latLng2.longitude - lng3) + Math.mercatorY(latitudeInRadians: latLng2.latitude) * lng3
    ) / latLng2.longitude
  }
}
