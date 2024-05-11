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
@testable import GoogleMapsUtilsSwift

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

}
