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

final class GMUGroundOverlayTest: XCTestCase {

    // MARK: - Properties
    private let type: String = "GroundOverlay"
    private let href: String = "image.jpg"
    private let zIndex: Int = 1
    private let rotation: Double = 45.0
    private let northEast: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 234.567, longitude: 345.678)
    private let southWest: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 123.456, longitude: 456.789)

    // MARK: - Test Methods
    func testInitWithProperties() {
        let groundOverlay: GMUGroundOverlay1 = makeSUT()

        XCTAssertEqual(groundOverlay.type, type)
        XCTAssertEqual(groundOverlay.northEast.longitude, northEast.longitude)
        XCTAssertEqual(groundOverlay.northEast.latitude, northEast.latitude)
        XCTAssertEqual(groundOverlay.southWest.latitude, southWest.latitude)
        XCTAssertEqual(groundOverlay.southWest.longitude, southWest.longitude)
        XCTAssertEqual(groundOverlay.zIndex, zIndex)
        XCTAssertEqual(groundOverlay.rotation, rotation)
        XCTAssertEqual(groundOverlay.href, href)
    }

    // MARK: - SUT
    private func makeSUT() -> GMUGroundOverlay1 {
        let groundOverlay = GMUGroundOverlay1(
            type: type,
            northEast: northEast,
            southWest: southWest,
            zIndex: zIndex,
            rotation: rotation,
            href: href
        )
        return groundOverlay
    }
}
