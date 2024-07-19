// Copyright 2024 Google LLC
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

import XCTest
import GoogleMaps

@testable import GoogleMapsUtils

final class GMUFeatureTests: XCTestCase {
  
    func testInitWithGeometry() throws {

      let point = GMUPoint(coordinate: CLLocationCoordinate2DMake(10, -10))
      let geometry: GMUGeometry = point
      let identifier: String = "TestFeature"
      let northEast: CLLocationCoordinate2D = CLLocationCoordinate2DMake(10, 10)
      let southWest: CLLocationCoordinate2D = CLLocationCoordinate2DMake(-10, -10)
      let boundingBox: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
      let description: NSObject = "A feature for unit testing" as NSObject

      let properties: [String: NSObject] = ["description": description]
      let feature: GMUFeature = GMUFeature.init(geometry: geometry, identifier: identifier, properties:properties, boundingBox: boundingBox)

      guard let featurePoint = feature.geometry as? GMUPoint else {
        XCTFail("Geometry is not a GMUPoint")
        return
      }

      XCTAssertEqual(featurePoint, point)
      XCTAssertEqual(feature.identifier, identifier)
      XCTAssertEqual(feature.properties, properties)
      XCTAssertEqual(feature.boundingBox, boundingBox)

    }
}
