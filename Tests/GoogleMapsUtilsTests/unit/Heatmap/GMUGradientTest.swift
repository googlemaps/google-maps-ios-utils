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

class GMUGradientTest: XCTestCase {

    private var gradientColor: [UIColor]!
    private var startPoints: [CGFloat]!
    private var colorMapSize: Int!

    override func setUp() {
        super.setUp()
        gradientColor = [
            UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
            UIColor(red: 1.0, green: 0, blue: 0, alpha: 1)
        ]
        startPoints = [0.2, 1.0]
        colorMapSize = 3
    }

    override func tearDown() {
        gradientColor = nil
        startPoints = nil
        colorMapSize = nil
        super.tearDown()
    }

    func testInitWithColors() {
        do {
            let gradient = try GMUGradient(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
            XCTAssertEqual(gradient.colors.count, gradient.startPoints.count)
        } catch {
            XCTFail("GMUGradient1 initialization failed with error: \(error)")
        }
    }

    func testInitWithEmptyColors() {
        XCTAssertThrowsError(try GMUGradient(colors: [], startPoints: self.startPoints, colorMapSize: self.colorMapSize)) { error in
            guard let gradientError = error as? GMUGradientError else {
                XCTFail("GMUGradient initialization failed with error: \(error)")
                return
            }
            XCTAssertEqual(gradientError.localizedDescription, "colors' size: 0 is not equal to startPoints' size: 2")
        }
    }

    func testInitWithNotEqualColorsAndStartPoints() {
        let gradientColors = [
            UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
            UIColor(red: 1.0, green: 0, blue: 0, alpha: 1),
            UIColor(red: 0.5, green: 0.2, blue: 0.3, alpha: 1)
        ]
        XCTAssertThrowsError(try GMUGradient(colors: gradientColors, startPoints: self.startPoints, colorMapSize: self.colorMapSize)) { error in
            guard let gradientError = error as? GMUGradientError else {
                XCTFail("GMUGradient initialization failed with error: \(error)")
                return
            }
            XCTAssertEqual(gradientError.localizedDescription, "colors' size: 3 is not equal to startPoints' size: 2")
        }
    }

    func testInitWithColorsAndStartPointsNonDescending() {
        let gradientColors = [
            UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
            UIColor(red: 1.0, green: 0, blue: 0, alpha: 1),
            UIColor(red: 0.5, green: 0.2, blue: 0.3, alpha: 1)
        ]
        let nonDescendingStartPoints: [CGFloat] = [1.0, 1.2, 0.1]
        XCTAssertThrowsError(try GMUGradient(colors: gradientColors, startPoints: nonDescendingStartPoints, colorMapSize: self.colorMapSize)) { error in
            guard let gradientError = error as? GMUGradientError else {
                XCTFail("GMUGradient initialization failed with error: \(error)")
                return
            }
            XCTAssertEqual(gradientError.localizedDescription, "startPoints' are not in non-descending order.")
        }
    }

    func testInitWithColorsAndMapSizeLessThanTwo() {
        let colorMapSize = 1
        XCTAssertThrowsError(try GMUGradient(colors: self.gradientColor, startPoints: self.startPoints, colorMapSize: colorMapSize)) { error in
            guard let gradientError = error as? GMUGradientError else {
                XCTFail("GMUGradient initialization failed with error: \(error)")
                return
            }
            XCTAssertEqual(gradientError.localizedDescription, "mapSize is less than 2.")
        }
    }

    func testInitWithColorsAndStartPointsLessThanZero() {
        let lessThanZeroStartPoints: [CGFloat]  = [-1.0, 1.2]
        
        XCTAssertThrowsError(try GMUGradient(colors: self.gradientColor, startPoints: lessThanZeroStartPoints, colorMapSize: self.colorMapSize)) { error in
            guard let gradientError = error as? GMUGradientError else {
                XCTFail("GMUGradient initialization failed with error: \(error)")
                return
            }
            XCTAssertEqual(gradientError.localizedDescription, "startPoints' are not all in the range [0,1].")
        }
    }

    func testInitWithColorsAndStartPointsGreaterThanOne() {
        let lessThanZeroStartPoints: [CGFloat]  = [1.0, 2.0]
        XCTAssertThrowsError(try GMUGradient(colors: self.gradientColor, startPoints: lessThanZeroStartPoints, colorMapSize: self.colorMapSize)) { error in
            guard let gradientError = error as? GMUGradientError else {
                XCTFail("GMUGradient initialization failed with error: \(error)")
                return
            }
            XCTAssertEqual(gradientError.localizedDescription, "startPoints' are not all in the range [0,1].")
        }
    }

    func testGenerateColorMap() {
        let gradientColor = [
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
            UIColor(red: 1.9, green: 1.5, blue: 1.6, alpha: 1),
        ]

        do {
            let gradient = try GMUGradient(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
            XCTAssertEqual(gradient.generateColorMap().count, colorMapSize)
        } catch {
            XCTFail("GMUGradient1 initialization failed with error: \(error)")
        }
    }

    func testInterpolateColorHueDifferenceLessThanPointFive() {
        let gradientColor = [
            UIColor(red: 1.9, green: 1.5, blue: 1.6, alpha: 1),
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
            UIColor(red: 2.0, green: 2.0, blue: 2.0, alpha: 1)
        ]
        let startPoints: [CGFloat] = [0.0, 0.5, 1.0]
        
        do {
            let gradient = try GMUGradient(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
            XCTAssertEqual(gradient.generateColorMap().count, colorMapSize)
        } catch {
            XCTFail("GMUGradient initialization failed with error: \(error)")
        }
    }
    
}
