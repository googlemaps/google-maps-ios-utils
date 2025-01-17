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
import CoreLocation
import GoogleMaps

@testable import GoogleMapsUtils

final class GMUPolygonTest: XCTestCase {

    // MARK: - Properties
    private let type: String = "Polygon"
    private let firstLatitude: CLLocationDegrees = 50.0
    private let firstLongitude: CLLocationDegrees = 45.0
    private let secondLatitude: CLLocationDegrees = 55.0
    private let secondLongitude: CLLocationDegrees = 50.0
    private let thirdLatitude: CLLocationDegrees = 60.0
    private let thirdLongitude: CLLocationDegrees = 55.0

    // MARK: - Test Methods
    func testInitWithCoordinatesArray() {
        let (polygon, paths) = makeSUT()
        
        XCTAssertEqual(polygon.type, type)
        XCTAssertEqual(polygon.paths, paths)
    }
    
    // MARK: - SUT
    private func makeSUT() -> (GMUPolygon1, [GMSMutablePath]) {
        let firstCoordinate = CLLocationCoordinate2D(latitude: firstLatitude, longitude: firstLongitude)
        let secondCoordinate = CLLocationCoordinate2D(latitude: secondLatitude, longitude: secondLongitude)
        let thirdCoordinate = CLLocationCoordinate2D(latitude: thirdLatitude, longitude: thirdLongitude)
        
        let path: GMSMutablePath = GMSMutablePath()
        path.add(firstCoordinate)
        path.add(secondCoordinate)
        path.add(thirdCoordinate)
        path.add(firstCoordinate)  // Closing the polygon
        
        let paths: [GMSMutablePath] = [path]
        let polygon: GMUPolygon1 = GMUPolygon1(type: type, paths: paths)
        return (polygon, paths)
    }
}
