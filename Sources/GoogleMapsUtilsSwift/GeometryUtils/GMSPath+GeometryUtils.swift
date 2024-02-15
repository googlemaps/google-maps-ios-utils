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

  /// The default tolerance used to computed whether a coordinate is near a path
  static let defaultToleranceInMeters = 0.1

  /// Returns the area of this path on Earth which is considered to be closed.
  /// - Parameters:
  ///   - radius: the radius of the sphere. Defaults to `kGMSEarthRadius`
  /// - Returns: the area of this path
  func area(radius: CLLocationDistance = kGMSEarthRadius) -> Double {
    return abs(signedArea(radius: radius))
  }

  /// The signed area of this path which is considered to be closed. The result
  /// is positive if the points of path are in counter-clockwise order,  negative otherwise, and 0
  /// if this path contains less than 0 coordinates.
  /// - Parameters:
  ///   - radius: the radius of the sphere. Defaults to `kGMSEarthRadius`
  /// - Returns: The signed area of this path
  func signedArea(radius: CLLocationDistance = kGMSEarthRadius) -> Double {
    guard var prev = coordinates.last?.latLngRadians else { return 0 }
    guard count() > 2 else { return 0 }

    var area = 0.0
    for coord in coordinates {
      let coordRadians = coord.latLngRadians
      area += LatLngRadians.polarTriangleArea(coordRadians, prev)
      prev = coordRadians
    }
    return area * pow(radius, 2)
  }

  /// Returns whether or not `coordinate` is inside this path which is always considered to be closed
  /// regardless if the last point of this path equals the first or not. This path is described by great circle
  /// segments if `geodesic` is true, otherwise, it is described by rhumb (loxodromic) segments.
  ///
  /// If `coordinate` is exactly equal to one of the vertices, the result is true. A point that is not equal to a
  /// vertex is on one side or the other of any path segment—it can never be "exactly on the border".
  /// See `isOnPath(coordinate:, geodesic:, tolerance:)` for a border test with tolerance.
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

  /// Returns whether `coordinate` lies on or near this path within the specified `tolerance` in meters.
  ///
  /// The tolerance, in meters, is relative to the spherical radius of the Earth. If you need to work on a sphere of different radius,
  /// you may compute the equivalent tolerance from the desired tolerance on the sphere of radius R:
  ///   tolerance = toleranceR * (RadiusEarth / R), with RadiusEarth==6371009.
  ///
  /// - Parameters:
  ///   - coordinate: The coordinate to inspect if it lies within this path
  ///   - geodesic: `true` if this path is described by great circle segments, otherwise, it is described by rhumb (loxodromic) segments
  ///   - tolerance: the tolerance in meters. Default value is `defaultToleranceInMeters`
  func isOnPath(coordinate: CLLocationCoordinate2D, geodesic: Bool, tolerance: Double = defaultToleranceInMeters) -> Bool {

    let coordinates = self.coordinates

    // No points
    guard let prev = coordinates.first else {
      return false
    }

    // Naming: the segment is latLng1 to latLng2 and the point is targetLatLng.
    var latLng1 = prev.latLngRadians
    let targetLatLng = coordinate.latLngRadians
    let normalizedTolerance = tolerance / kGMSEarthRadius
    let havTolerance = Math.haversine(normalizedTolerance)

    // Single point
    guard coordinates.count > 1 else {
      let distance = Math.haversineDistance(latLng1, targetLatLng)
      return distance < havTolerance
    }

    // Handle geodesic
    if (geodesic) {
      for coord in coordinates {
        let latLng2 = coord.latLngRadians
        if (isOnSegmentGreatCircle(latLng1: latLng1, latLng2: latLng2, latLng3: targetLatLng, havTolerance: havTolerance)) {
          return true
        }
        latLng1 = latLng2
      }
      return false
    }

    // We project the points to mercator space, where the Rhumb segment is a straight line,
    // and compute the geodesic distance between point3 and the closest point on the segment.
    // Note that this method is an approximation, because it uses "closest" in mercator space,
    // which is not "closest" on the sphere -- but the error introduced is small as
    // `normalizedTolerance` is small.
    let minAcceptable = targetLatLng.latitude - normalizedTolerance
    let maxAcceptable = targetLatLng.latitude + normalizedTolerance

    var point1 = CartesianPoint(x: 0, y: Math.mercatorY(latitudeInRadians: latLng1.latitude))

    for coord in coordinates {
      let latLng2 = coord.latLngRadians

      guard max(latLng1.latitude, latLng2.latitude) >= minAcceptable &&
              min(latLng1.latitude, latLng2.latitude) <= maxAcceptable else {
        continue
      }

      // The implicit x1 is always 0 because we offset longitudes by -lng1.
      let point2 = CartesianPoint(
        x: Math.wrap(value: latLng2.longitude - latLng1.longitude, min: -.pi, max: .pi),
        y: Math.mercatorY(latitudeInRadians: latLng2.latitude)
      )
      let point3 = CartesianPoint(
        x: Math.wrap(value: targetLatLng.longitude - latLng1.longitude, min: -.pi, max: .pi),
        y: Math.mercatorY(latitudeInRadians: targetLatLng.latitude)
      )

      if let closestPoint = closestPointAround(point1, point2, point3) {
        let latClosest = Math.inverseMercatorLatitudeRadians(closestPoint.y)
        let deltaLng = point3.x - closestPoint.x
        let havDistance = Math.haversineDistance(
          latitude1: targetLatLng.latitude,
          latitude2: latClosest,
          deltaLongitude: deltaLng
        )
        if (havDistance < havTolerance) {
          return true
        }
      }

      latLng1 = latLng2
      point1 = CartesianPoint(x: 0, y: point2.y)
    }

    return false
  }

  /// Returns an array of `GMSStyleSpan` constructed by repeated application of style and length information
  /// from `lengths` and `styles` along this path.
  ///
  /// - Parameters:
  ///   - styles: The styles to create `GMSStyleSpan` objects from
  ///   - lengths: The length the corresponding style at the same index of `styles` should be applied
  ///   - lengthKind: The `GMSLengthKind` the lengths are provided in
  ///   - offset: A length offset that will be skipped over relative to `lengths`
  func styleSpans(
    styles: [GMSStrokeStyle],
    lengths: [Double],
    lengthKind: GMSLengthKind,
    offset: Double = 0
  ) -> [GMSStyleSpan] {
    guard !styles.isEmpty else {
      return []
    }

    let sumLength = lengths.reduce(0) { return $0 + $1 }
    guard sumLength > 0 else {
      return []
    }

    let lengthOffset = Math.wrap(
      value: offset,
      min: 0,
      max: sumLength * Double(
        (styles.count / Math.greatestCommonDivisor(lengths.count, styles.count))
      )
    )
    let totalLength = self.length(of: lengthKind)

    var lengthIter = 0
    var styleIter = 0
    var lengthPos = -lengthOffset
    var prevSegments = 0.0
    var spans: [GMSStyleSpan] = []

    while (lengthPos < totalLength) {
      lengthPos += lengths[lengthIter]
      if (lengthPos > 0) {
        let segments = self.segments(forLength: lengthPos, kind: lengthKind)
        let delta = segments - prevSegments
        if (delta > 0) {
          spans.append(GMSStyleSpan(style: styles[styleIter], segments: delta))
          prevSegments = segments
        }
      }
      lengthIter = (lengthIter + 1) % lengths.count
      styleIter = (styleIter + 1) % styles.count
    }

    return spans
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

  /// Returns the closest point on the segment [`p1`, `p2`] to candidates (`p3.x`, `p3.y`), (`p3.x - 2 * .pi`, `p3.y`),
  /// and (`p3.x + 2 * .pi`, `p3.y`) and returns the closest point.
  /// Note: `p1.x` should be 0.
  func closestPointAround(_ p1: CartesianPoint, _ p2: CartesianPoint, _ p3: CartesianPoint) -> CartesianPoint? {
    guard p1.x == 0 else {
      return nil
    }

    var closestDistance = Double.infinity
    var result = p3
    for x in [p3.x, p3.x - 2 * .pi, p3.x + 2 * .pi] {
      let pCurrent = CartesianPoint(x: x, y: p3.y)

      // Get closest point
      let dy = p2.y - p1.y
      let len2 = p2.x * p2.x + dy * dy
      let t = (len2 <= 0) ? 0 : Math.clamp(value: (pCurrent.x * p2.x + (p3.y - p1.y) * dy) / len2, min: 0, max: 1)
      let closest = CartesianPoint(x: t * p2.x, y: p1.y + t * dy)

      let distance = ((pCurrent.x - closest.x) * (pCurrent.x - closest.x)) + ((pCurrent.y - closest.y) * (pCurrent.y - closest.y))
      if (distance < closestDistance) {
        closestDistance = distance
        result = closest
      }
    }
    return result
  }

  func isOnSegmentGreatCircle(
    latLng1: LatLngRadians,
    latLng2: LatLngRadians,
    latLng3: LatLngRadians,
    havTolerance: LocationRadians
  ) -> Bool {
    // Haversine is strictly increasing on [0, .pi]; we do some comparisons in hav space.
    // First check distance to the ends of the segment.
    let havDist13 = Math.haversineDistance(latLng1, latLng3)
    guard havDist13 > havTolerance else {
      return true
    }

    let havDist23 = Math.haversineDistance(latLng2, latLng3)
    guard havDist23 > havTolerance else {
      return true
    }

    // Compute "cross-track distance", the distance from point to the GC formed by the segment.
    let sinBearing = sinDeltaBearing(latLng1: latLng1, latLng2: latLng2, latLng3: latLng3)
    let sinDist13 = Math.sinFromHaversine(havDist13)
    let havCrossTrack = Math.haversineFromSin(sinDist13 * sinBearing)
    guard havCrossTrack <= havTolerance else {
        return false
    }

    // Check that the "projection" P of latlng3 to the GC circle formed by the segment is inside the segment.
    // We compare the alongTrack distance from both ends of the segment with the length of the
    // segment. If any of the alongTrack is larger than the segment, then the point projects outside.
    // cos(alongTrack) == cos(distance13)/cos(crossTrack), so
    // hav(alongTrack) == (havDist13 - havCrossTrack)/cos(crossTrack).
    // alongTrack > distance12 becomes:
    // hav(alongTrack) > havDist12,
    // (havDist13 - havCrossTrack)/cos(crossTrack) > havDist12 . Note cos(crossTrack) > 0 and large.
    // havDist13 > havDist12 * cos(crossTrack) + havCrossTrack.
    // cos(crossTrack) == 1 - 2*havCrossTrack. Note cos(crossTrack) is positive.
    // havDist13 > havDist12 * (1 - 2*havCrossTrack) + havCrossTrack
    // havDist13 > havDist12 + havCrossTrack * (1 - 2 * havDist12).
    let havDist12 = Math.haversineDistance(latLng1, latLng2)
    let term = havDist12 + havCrossTrack * (1 - 2 * havDist12)
    if (havDist13 > term || havDist23 > term) {
        return false;
    }

    // If both along-track distances are less than the segment, the projection may still
    // be outside only if the segment is larger than 120deg.
    if (havDist12 < 0.7) {
        return true
    }

    // We decide remaining case by comparing the sum of along-track distances to the half-circle.
    let cosCrossTrack = 1 - 2 * havCrossTrack
    let havAlongTrack13 = (havDist13 - havCrossTrack) / cosCrossTrack
    let havAlongTrack23 = (havDist23 - havCrossTrack) / cosCrossTrack
    let sinSumAlongTrack = Math.sinSumFromHaversine(havAlongTrack13, havAlongTrack23)
    return sinSumAlongTrack > 0  // Compare with half-circle == PI using sign of sin().
  }

  /// Returns sin(initial bearing from `latLng1` to `latLng3` minus initial bearing from `latLng1` to `latLng2`).
  func sinDeltaBearing(latLng1: LatLngRadians, latLng2: LatLngRadians, latLng3: LatLngRadians) -> LocationRadians {
    // Uses sin(atan2(a,b) - atan2(c,d)) == (a*d - b*c) / sqrt((a*a + b*b) * (c*c + d*d)).
    let sinLat1 = sin(latLng1.latitude)
    let cosLat2 = cos(latLng2.latitude)
    let cosLat3 = cos(latLng3.latitude)
    let lat31 = latLng3.latitude - latLng1.latitude
    let lng31 = latLng3.longitude - latLng1.longitude
    let lat21 = latLng2.latitude - latLng1.latitude
    let lng21 = latLng2.longitude - latLng1.longitude
    let a = sin(lng31) * cosLat3
    let c = sin(lng21) * cosLat2
    let b = sin(lat31) + 2 * sinLat1 * cosLat3 * Math.haversine(lng31)
    let d = sin(lat21) + 2 * sinLat1 * cosLat2 * Math.haversine(lng21)
    let denominator = (a * a + b * b) * (c * c + d * d)
    return denominator <= 0 ? 1 : (a * d - b * c) / sqrt(denominator);
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

public extension Sequence where Iterator.Element == CLLocationCoordinate2D {

  /// Creates a `GMSMutablePath` from this sequence of `CLLocationCoordinate2D`
  var gmsMutablePath: GMSMutablePath {
    let path = GMSMutablePath()
    forEach { coordinate in
      path.add(coordinate)
    }
    return path
  }
}
