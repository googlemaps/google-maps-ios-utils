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


class Math {
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
  static func inverseMercatorLatitude(_ y: Double) -> CLLocationDegrees {
    return (2 * atan(exp(y * .pi)) - (.pi / 2)) * (180 / .pi)
  }

  /// Return longitude in degrees from mercator X
  static func inverseMercatorLongitude(_ x: Double) -> CLLocationDegrees {
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
}
