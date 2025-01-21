//
//  GMUGeometryCollectionTest.swift
//  
//
//  Created by Angela Yu on 4/1/24.
//

import XCTest
import GoogleMaps

@testable import GoogleMapsUtils

final class GMUGeometryCollectionTest: XCTestCase {

  func testInitWithGeometries() throws {

    let point = GMUPoint1(coordinate: CLLocationCoordinate2DMake(10, -10))
    let firstGeometry: GMUGeometry1 = point

    let path = GMSMutablePath()
    path.addLatitude(0.0, longitude: 101.0)
    path.addLatitude(1.0, longitude: 102.0)

    let lineString = GMULineString1(path: path)
    let secondGeometry: GMUGeometry1 = lineString

    let geometries: [GMUGeometry1] = [firstGeometry, secondGeometry]
    let geometryCollection: GMUGeometryCollection1 = GMUGeometryCollection1.init(geometries: geometries)

    guard let geometryPoint = geometryCollection.geometries.first as? GMUPoint1 else {
      XCTFail("Geometry is not a GMUPoint")
      return
    }

    guard let geometryLineString = geometryCollection.geometries.last as? GMULineString1 else {
      XCTFail("Geometry is not a GMULineString")
      return
    }

    XCTAssertEqual(geometryCollection.type, "GeometryCollection")
    XCTAssertEqual(geometryPoint, point)
    XCTAssertEqual(geometryLineString, lineString)
  }
}
