//
//  GMUGeometryCollectionTest.swift
//  
//
//  Created by Angela Yu on 4/1/24.
//

import XCTest

@testable import GoogleMapsUtils

final class GMUGeometryCollectionTest: XCTestCase {

  func testInitWithGeometries() throws {

    let point = GMUPoint(coordinate: CLLocationCoordinate2DMake(10, -10))
    let firstGeometry: GMUGeometry = point

    let path = GMSMutablePath()
    path.addLatitude(0.0, longitude: 101.0)
    path.addLatitude(1.0, longitude: 102.0)

    let lineString = GMULineString(path: path)
    let secondGeometry: GMUGeometry = lineString

    let geometries: [GMUGeometry] = [firstGeometry, secondGeometry]
    let geometryCollection: GMUGeometryCollection = GMUGeometryCollection.init(geometries: geometries)

    guard let geometryPoint = geometryCollection.geometries.first as? GMUPoint else {
      XCTFail("Geometry is not a GMUPoint")
      return
    }

    guard let geometryLineString = geometryCollection.geometries.last as? GMULineString else {
      XCTFail("Geometry is not a GMULineString")
      return
    }

    XCTAssertEqual(geometryCollection.type, "GeometryCollection")
    XCTAssertEqual(geometryPoint, point)
    XCTAssertEqual(geometryLineString, lineString)
  }
}
