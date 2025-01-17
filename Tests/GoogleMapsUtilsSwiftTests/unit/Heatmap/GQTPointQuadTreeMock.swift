/* Copyright (c) 2024 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import CoreLocation

@testable import GoogleMapsUtils

class GQTPointQuadTreeMock: GQTPointQuadTree1 {
    override func search(withBounds bounds: GQTBounds1) -> [GQTPointQuadTreeItem1] {
        // Return mock points based on the search bounds for testing
        if bounds.minX < -1 || bounds.maxX > 1 || bounds.minY < -1 || bounds.maxY > 1 {
            return [] // Simulate no data for out-of-bounds searches
        }
        return [
            GMUWeightedLatLng1(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: -90.0), intensity: 1.0),
            GMUWeightedLatLng1(coordinate: CLLocationCoordinate2D(latitude: 10.0, longitude: 45.0), intensity: 2.0)
        ]
    }
}
