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
  
  var gradient          : GMUGradient!
  var kGradientColor    : [UIColor]!
  var kStartPoints      : [NSNumber]!
  var kColorMapSize     : UInt!
  
  override func setUp() {
    kGradientColor = [
        UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
        UIColor(red: 1.0, green: 0, blue: 0, alpha: 1)
    ]
    kStartPoints = [NSNumber(value: 0.2), NSNumber(value: 1.0)]
    kColorMapSize = 3
  }
  
  override func tearDown() {
    gradient = nil
    kGradientColor = nil
  }
  
  func testInitWithColors() {
    gradient = GMUGradient(colors: kGradientColor, startPoints: kStartPoints, colorMapSize: kColorMapSize)
    XCTAssertEqual(gradient.colors.count, gradient.startPoints.count)
  }
  
  func testInitWithEmptyColors() {
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException{
        _ = GMUGradient(colors: [], startPoints: self.kStartPoints, colorMapSize: self.kColorMapSize)
      }
    } catch let error{
      XCTAssertNotNil(error)
    }
  }
  
  func testInitWithNotEqualColorsAndStarPoints() {
    let gradientColors = [
        UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
        UIColor(red: 1.0, green: 0, blue: 0, alpha: 1),
        UIColor(red: 0.5, green: 0.2, blue: 0.3, alpha: 1)
    ]
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException{
        _ = GMUGradient(colors: gradientColors, startPoints: self.kStartPoints, colorMapSize: self.kColorMapSize)
      }
    } catch let error{
      XCTAssertNotNil(error)
    }
  }
  
  func testInitWithColorsAndStarPointsNonDescending() {
    let gradientColors = [
        UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
        UIColor(red: 1.0, green: 0, blue: 0, alpha: 1),
        UIColor(red: 0.5, green: 0.2, blue: 0.3, alpha: 1)
    ]
    let nonDescendingStartPoints = [NSNumber(value: 1.0), NSNumber(value: 1.2), NSNumber(value: 0.1)]
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException{
        _ = GMUGradient(colors: gradientColors, startPoints: nonDescendingStartPoints, colorMapSize: self.kColorMapSize)
      }
    } catch let error{
      XCTAssertNotNil(error)
    }
  }
  
  func testInitWithColorsAndMapSizeLessThanTwo() {
    let colorMapSize = 1
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException{
        _ = GMUGradient(colors: self.kGradientColor, startPoints: self.kStartPoints, colorMapSize: UInt(colorMapSize))
      }
    } catch let error{
      XCTAssertNotNil(error)
    }
  }
  
  func testInitWithColorsAndStarPointsLessThanZero() {
    let lessThanZeroStartPoints = [NSNumber(value: -1.0), NSNumber(value: 1.2)]
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException{
        _ = GMUGradient(colors: self.kGradientColor, startPoints: lessThanZeroStartPoints, colorMapSize: self.kColorMapSize)
      }
    } catch let error{
      XCTAssertNotNil(error)
    }
  }
  
  func testInitWithColorsAndStarPointsGreaterThanOne() {
    let lessThanZeroStartPoints = [NSNumber(value: 1.0), NSNumber(value: 2.0)]
    do {
      try GMUObectiveCTestHelper.catchObjectiveCException{
        _ = GMUGradient(colors: self.kGradientColor, startPoints: lessThanZeroStartPoints, colorMapSize: self.kColorMapSize)
      }
    } catch let error{
      XCTAssertNotNil(error)
    }
  }
  
  func testGenerateColorMap() {
    let gradientColor = [
      UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
      UIColor(red: 1.9, green: 1.5, blue: 1.6, alpha: 1),
    ]
    gradient = GMUGradient(colors: gradientColor, startPoints: kStartPoints, colorMapSize: kColorMapSize)
    XCTAssertEqual(gradient.generateColorMap().count, Int(kColorMapSize))
  }
  
  func testInterpolateColorHueDifferenceLessThanPointFive() {
    let gradientColor = [
      UIColor(red: 1.9, green: 1.5, blue: 1.6, alpha: 1),
      UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
      UIColor(red: 2.0, green: 2.0, blue: 2.0, alpha: 1)
    ]
    let startPoints = [NSNumber(value: 0.0), NSNumber(value: 0.5), NSNumber(value: 1.0)]
    gradient = GMUGradient(colors: gradientColor, startPoints: startPoints, colorMapSize: kColorMapSize)
    XCTAssertEqual(gradient.generateColorMap().count, Int(kColorMapSize))
  }

}
