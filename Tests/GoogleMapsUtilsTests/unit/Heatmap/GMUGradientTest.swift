/* Copyright (c) 2020 Google Inc.
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

import XCTest
@testable import GoogleMapsUtils

class GMUGradientTest: XCTestCase {
  
  private var gradientColor: [UIColor]!
  private var startPoints: [NSNumber]!
  private var colorMapSize: UInt!
  
  override func setUp() {
    super.setUp()
    gradientColor = [
        UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
        UIColor(red: 1.0, green: 0, blue: 0, alpha: 1)
    ]
    startPoints = [NSNumber(value: 0.2), NSNumber(value: 1.0)]
    colorMapSize = 3
  }
  
  override func tearDown() {
    gradientColor = nil
    startPoints = nil
    colorMapSize = nil
    super.tearDown()
  }
  
  func testInitWithColors() {
    let gradient = GMUGradient(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
    XCTAssertEqual(gradient.colors.count, gradient.startPoints.count)
  }
  
  func testInitWithEmptyColors() {
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException {
        _ = GMUGradient(colors: [], startPoints: self.startPoints, colorMapSize: self.colorMapSize)
      }
    } catch let error as NSError {
        XCTAssertEqual("NSInvalidArgumentException", error.domain)
    }
  }
  
  func testInitWithNotEqualColorsAndStartPoints() {
    let gradientColors = [
        UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
        UIColor(red: 1.0, green: 0, blue: 0, alpha: 1),
        UIColor(red: 0.5, green: 0.2, blue: 0.3, alpha: 1)
    ]
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException {
        _ = GMUGradient(colors: gradientColors, startPoints: self.startPoints, colorMapSize: self.colorMapSize)
      }
    } catch let error as NSError {
        XCTAssertEqual("NSInvalidArgumentException", error.domain)
    }
  }
  
  func testInitWithColorsAndStartPointsNonDescending() {
    let gradientColors = [
        UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
        UIColor(red: 1.0, green: 0, blue: 0, alpha: 1),
        UIColor(red: 0.5, green: 0.2, blue: 0.3, alpha: 1)
    ]
    let nonDescendingStartPoints = [NSNumber(value: 1.0), NSNumber(value: 1.2), NSNumber(value: 0.1)]
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException {
        _ = GMUGradient(colors: gradientColors, startPoints: nonDescendingStartPoints, colorMapSize: self.colorMapSize)
      }
    } catch let error as NSError {
        XCTAssertEqual("NSInvalidArgumentException", error.domain)
    }
  }
  
  func testInitWithColorsAndMapSizeLessThanTwo() {
    let colorMapSize = 1
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException {
        _ = GMUGradient(colors: self.gradientColor, startPoints: self.startPoints, colorMapSize: UInt(colorMapSize))
      }
    } catch let error as NSError {
        XCTAssertEqual("NSInvalidArgumentException", error.domain)
    }
  }
  
  func testInitWithColorsAndStartPointsLessThanZero() {
    let lessThanZeroStartPoints = [NSNumber(value: -1.0), NSNumber(value: 1.2)]
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException {
        _ = GMUGradient(colors: self.gradientColor, startPoints: lessThanZeroStartPoints, colorMapSize: self.colorMapSize)
      }
    } catch let error as NSError {
        XCTAssertEqual("NSInvalidArgumentException", error.domain)
    }
  }
  
  func testInitWithColorsAndStartPointsGreaterThanOne() {
    let lessThanZeroStartPoints = [NSNumber(value: 1.0), NSNumber(value: 2.0)]
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException {
        _ = GMUGradient(colors: self.gradientColor, startPoints: lessThanZeroStartPoints, colorMapSize: self.colorMapSize)
      }
    } catch let error as NSError {
        XCTAssertEqual("NSInvalidArgumentException", error.domain)
    }
  }
  
  func testGenerateColorMap() {
    let gradientColor = [
      UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
      UIColor(red: 1.9, green: 1.5, blue: 1.6, alpha: 1),
    ]
    let gradient = GMUGradient(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
    XCTAssertEqual(gradient.generateColorMap().count, Int(colorMapSize))
  }
  
  func testInterpolateColorHueDifferenceLessThanPointFive() {
    let gradientColor = [
      UIColor(red: 1.9, green: 1.5, blue: 1.6, alpha: 1),
      UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
      UIColor(red: 2.0, green: 2.0, blue: 2.0, alpha: 1)
    ]
    let startPoints = [NSNumber(value: 0.0), NSNumber(value: 0.5), NSNumber(value: 1.0)]
    let gradient = GMUGradient(colors: gradientColor, startPoints: startPoints, colorMapSize: colorMapSize)
    XCTAssertEqual(gradient.generateColorMap().count, Int(colorMapSize))
  }

}
