//
//  LatLngRadiansTest.swift
//  UnitTest
//
//  Created by Chris Arriola on 2/4/21.
//  Copyright © 2021 Google. All rights reserved.
//

import XCTest
@testable import GoogleMapsUtils

class LatLngRadiansTest : XCTestCase {
  let latLng1 = LatLngRadians(latitude: 1, longitude: 2)
  let latLng2 = LatLngRadians(latitude: -1, longitude: 8)
  let latLng3 = LatLngRadians(latitude: 0, longitude: 10)

  private let accuracy = 1e-15

  func testAddition() {
    let sum = latLng1 + latLng2
    XCTAssertEqual(latLng3.latitude, sum.latitude, accuracy: accuracy)
    XCTAssertEqual(latLng3.longitude, sum.longitude, accuracy: accuracy)
  }

  func testSubtraction() {
    let difference = latLng3 - latLng2
    XCTAssertEqual(latLng1.latitude, difference.latitude, accuracy: accuracy)
    XCTAssertEqual(latLng1.longitude, difference.longitude, accuracy: accuracy)
  }
}
