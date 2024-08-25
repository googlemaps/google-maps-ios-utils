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

@testable import GoogleMapsUtils

final class GMULineStringTest: XCTestCase {
    
    // MARK: - Properties
    private let type: String = "LineString"
    private let firstLatitude: CLLocationDegrees = 50.0
    private let firstLongitude: CLLocationDegrees = 45.0
    private let secondLatitude: CLLocationDegrees = 60.0
    private let secondLongitude: CLLocationDegrees = 55.0
    private let path: GMSMutablePath = GMSMutablePath()

    // MARK: - Test Methods
    func testInitWithCoordinates() {
        let lineString: GMULineString1 = makeSUT()
        
        XCTAssertEqual(lineString.type, type)
        XCTAssertEqual(lineString.path, path)
    }

    // MARK: - SUT
    private func makeSUT() -> GMULineString1 {
        let firstCoordinate = CLLocationCoordinate2D(latitude: firstLatitude, longitude: firstLongitude)
        let secondCoordinate = CLLocationCoordinate2D(latitude: secondLatitude, longitude: secondLongitude)
        path.add(firstCoordinate)
        path.add(secondCoordinate)
        
        let lineString: GMULineString1 = GMULineString1(type: type, path: path)
        return lineString
    }
}
