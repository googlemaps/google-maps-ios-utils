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

/// A location (latitude or longitude) represented in radians
typealias LocationRadians = Double

/// A struct representing a latitude, longitude value represented in radians
struct LatLngRadians {
  var latitude: LocationRadians
  var longitude: LocationRadians
}

extension LocationRadians {
  var degrees: CLLocationDegrees {
    return self * (180 / .pi)
  }
}

extension LatLngRadians {
  var locationCoordinate2D: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude.degrees, longitude: longitude.degrees)
  }
}

extension CLLocationCoordinate2D {
  var latLngRadians: LatLngRadians {
    LatLngRadians(latitude: latitude.radians, longitude: longitude.radians)
  }
}

extension CLLocationDegrees {
  var radians: LocationRadians {
    return self * (.pi / 180)
  }
}
