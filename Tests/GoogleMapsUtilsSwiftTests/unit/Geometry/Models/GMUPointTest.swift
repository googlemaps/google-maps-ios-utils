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

@testable import GoogleMapsUtils

final class GMUPointTest: XCTestCase {

    // MARK: - Properties
    private let type: String = "Point"
    private let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 123.456, longitude: 456.789)

    // MARK: - Test Methods
    func testInitWithCoordinate() {
        let point: GMUPoint1 = makeSUT()

        XCTAssertEqual(point.type, type)
        XCTAssertEqual(point.coordinate.latitude, coordinate.latitude)
        XCTAssertEqual(point.coordinate.longitude, coordinate.longitude)
    }

    // MARK: - SUT
    private func makeSUT() -> GMUPoint1 {
        let point: GMUPoint1 = GMUPoint1(type: type, coordinate: coordinate)
        return point
    }
}
