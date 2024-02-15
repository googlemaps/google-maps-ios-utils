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

class Math {
  /// Computes the initial bearing between `from` and `to` in radians
  static func initialBearing(_ from: LatLngRadians, _ to: LatLngRadians) -> LocationRadians {
    let delta = to - from
    let cosLatTo = cos(to.latitude)
    let y = sin(delta.longitude) * cosLatTo
    let x = sin(delta.latitude) + sin(from.latitude) * cosLatTo * 2 * haversine(delta.longitude)
    return atan2(y, x)
  }

  /// Returns sin(arcHav(x) + arcHav(y)).
  static func sinSumFromHaversine(_ x: LocationRadians, _ y: LocationRadians) -> LocationRadians {
      let a = sqrt(x * (1 - x))
      let b = sqrt(y * (1 - y))
      return 2 * (a + b - 2 * (a * y + b * x))
  }

  /// Given h==hav(x), returns sin(abs(x))
  static func sinFromHaversine(_ h: LocationRadians) -> LocationRadians {
    return 2 * sqrt(h * (1 - h))
  }

  /// Returns hav(asin(x)).
  static func haversineFromSin(_ x: LocationRadians) -> LocationRadians {
    let x2 = x * x
    return x2 / (1 + sqrt(1 - x2)) * 0.5
  }

  /// Computes the haversine(angle-in-radians).
  /// hav(x) == (1 - cos(x)) / 2 == sin(x / 2)^2.
  static func haversine(_ radians: LocationRadians) -> LocationRadians {
    let sinHalf = sin(radians / 2)
    return sinHalf * sinHalf
  }

  /// Computes haversine of distance on a unit sphere between two coordinates in radians.
  static func haversineDistance(_ latLng1: LatLngRadians, _ latLng2: LatLngRadians) -> LocationRadians {
    return haversineDistance(
      latitude1: latLng1.latitude,
      latitude2: latLng2.latitude,
      deltaLongitude: latLng1.longitude - latLng2.longitude
    )
  }

  /// Computes haversine of distance on a unit sphere between two coordinates in radians.
  static func haversineDistance(
    latitude1: LocationRadians,
    latitude2: LocationRadians,
    deltaLongitude: LocationRadians
  ) -> LocationRadians {
    return haversine(latitude1 - latitude2) + haversine(deltaLongitude) * cos(latitude1) * cos(latitude2)
  }

  /// Computes the inverse haversine
  static func inverseHaversine(_ value: LocationRadians) -> LocationRadians {
    return 2 * asin(sqrt(value))
  }

  /// Restricts `value` to the range [`min`, `max`]
  static func clamp(value: Double, min: Double, max: Double) -> Double {
    return (value < min) ? min : (value > max) ? max : value
  }

  /// Wraps `value` into the inclusive-exclusive interval between `min` and `max`
  static func wrap(value: Double, min: Double, max: Double) -> Double {

    // Not necessary to wrap if value is already within [min, max)
    guard value < min || value >= max else {
      return value
    }

    return mod(value - min, modulus: max - min) + min
  }

  /// Returns the non-negative remainder of value / modulus
  static func mod(_ value: Double, modulus: Double) -> Double {
    let truncated = value.truncatingRemainder(dividingBy: modulus)
    return (truncated + modulus).truncatingRemainder(dividingBy: modulus)
  }

  /// Return latitude in degrees from mercator Y
  static func inverseMercatorLatitudeDegrees(_ y: Double) -> CLLocationDegrees {
    return inverseMercatorLatitudeRadians(y * .pi).degrees
  }

  /// Return latitude in degrees from mercator Y
  static func inverseMercatorLatitudeRadians(_ y: Double) -> LocationRadians {
    return (2 * atan(exp(y)) - (.pi / 2))
  }

  /// Return longitude in degrees from mercator X
  static func inverseMercatorLongitudeDegrees(_ x: Double) -> CLLocationDegrees {
    return x * 180
  }

  /// Returns mercator X from longitude in degrees
  static func mercatorX(longitudeInDegrees: CLLocationDegrees) -> Double {
    return longitudeInDegrees / 180
  }

  /// Returns mercator Y from latitude in degrees
  static func mercatorY(latitudeInDegrees: CLLocationDegrees) -> Double {
    return mercatorY(latitudeInRadians: latitudeInDegrees.radians) / .pi
  }

  /// Returns mercator Y from latitude in radians
  static func mercatorY(latitudeInRadians: LocationRadians) -> Double {
    return log(tan(latitudeInRadians * 0.5 + (.pi / 4)))
  }

  /// Returns the greatest common divisor between two integers using Euclid's algorithm
  static func greatestCommonDivisor(_ num1: Int, _ num2: Int) -> Int {
    guard num1 > 0 && num2 > 0 else {
      return 1
    }
    var a = num1
    var b = num2
    var t = 0
    while (b != 0) {
      t = b
      b = a % t
      a = t
    }
    return a
  }
}
