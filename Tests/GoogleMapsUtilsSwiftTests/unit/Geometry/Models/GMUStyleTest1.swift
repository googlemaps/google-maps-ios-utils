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

/// TO-DO: Rename the test file to `GMUStyleTest` once the linking is done and remove the objective c class.

final class GMUStyleTest1: XCTestCase {

    // MARK: - Properties
    private let styleID: String = "#test"
    private let iconUrl: String = "test.png"
    private let title: String = "Test Placemark"
    private let width: Float = 1.0
    private let scale: Float = 1.0
    private let heading: Float = 45.0
    private let hasFill: Bool = true
    private let hasStroke: Bool = true
    private let strokeColor: UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    private let fillColor: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
    private let anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)

    // MARK: - Test Methods
    func testInitWithProperties() {
        let style: GMUStyle1 = makeSUT()

        XCTAssertEqual(style.styleID, styleID)
        XCTAssertEqual(style.strokeColor, strokeColor)
        XCTAssertEqual(style.fillColor, fillColor)
        XCTAssertEqual(style.width, width)
        XCTAssertEqual(style.scale, scale)
        XCTAssertEqual(style.heading, heading)
        XCTAssertEqual(style.anchor.x, anchor.x)
        XCTAssertEqual(style.anchor.y, anchor.y)
        XCTAssertEqual(style.iconUrl, iconUrl)
        XCTAssertEqual(style.title, title)
        XCTAssertEqual(style.hasFill, hasFill)
        XCTAssertEqual(style.hasStroke, hasStroke)
    }

    // MARK: - SUT
    private func makeSUT() -> GMUStyle1 {
        let style: GMUStyle1 = GMUStyle1(
            styleID: styleID,
            strokeColor: strokeColor,
            fillColor: fillColor,
            width: width,
            scale: scale,
            heading: heading,
            anchor: anchor,
            iconUrl: iconUrl,
            title: title,
            hasFill: hasFill,
            hasStroke: hasStroke
        )
        return style
    }
}
