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

final class GMUGeoJSONParserTest: XCTestCase {

  // Helper function to load GeoJSON data
  private func features(withResource resource: String) -> [GMUFeature] {
    #if SWIFT_PACKAGE
    guard let path = Bundle.module.path(forResource: resource, ofType: "geojson"),
          let fileContents = try? String(contentsOfFile: path, encoding: .utf8),
          let data = fileContents.data(using: .utf8) else {
      XCTFail("GeoJSON resource not found or failed to load.")
      return []
    }
    #else
    let bundle = Bundle(for: Self.self)
    guard let path = bundle.path(forResource: resource, ofType: "geojson"),
          let fileContents = try? String(contentsOfFile: path, encoding: .utf8),
          let data = fileContents.data(using: .utf8) else {
      XCTFail("GeoJSON resource not found or failed to load.")
      return []
    }
    #endif

    let parser = GMUGeoJSONParser(data: data)
    parser.parse()
    return parser.features as! [GMUFeature]
  }

  func testInitWithURL() {
    #if SWIFT_PACKAGE
    guard let path = Bundle.module.path(forResource: "GeoJSON_Point_Test", ofType: "geojson") else {
      XCTFail("GeoJSON resource not found.")
      return
    }
    #else
    let bundle = Bundle(for: Self.self)
    guard let path = bundle.path(forResource: "GeoJSON_Point_Test", ofType: "geojson") else {
      XCTFail("GeoJSON resource not found.")
      return
    }
    #endif

    let url = URL(fileURLWithPath: path)
    let parser = GMUGeoJSONParser(url: url)
    parser.parse()
    XCTAssertEqual(parser.features.count, 1)
  }

  func testInitWithStream() {
    #if SWIFT_PACKAGE
    guard let path = Bundle.module.path(forResource: "GeoJSON_Point_Test", ofType: "geojson"),
          let fileContents = try? String(contentsOfFile: path, encoding: .utf8),
          let data = fileContents.data(using: .utf8) else {
      XCTFail("GeoJSON resource not found or failed to load.")
      return
    }
    #else
    let bundle = Bundle(for: Self.self)
    guard let path = bundle.path(forResource: "GeoJSON_Point_Test", ofType: "geojson"),
          let fileContents = try? String(contentsOfFile: path, encoding: .utf8),
          let data = fileContents.data(using: .utf8) else {
      XCTFail("GeoJSON resource not found or failed to load.")
      return
    }
    #endif

    let stream = InputStream(data: data)
    let parser = GMUGeoJSONParser(stream: stream)
    parser.parse()
    XCTAssertEqual(parser.features.count, 1)
  }

  func testParsePoint() {
    let features = features(withResource: "GeoJSON_Point_Test")
    XCTAssertEqual(features.count, 1)

    guard let point = features.first?.geometry as? GMUPoint else {
      XCTFail("Geometry is not a GMUPoint")
      return
    }

    XCTAssertEqual(point.coordinate.latitude, 0.5)
    XCTAssertEqual(point.coordinate.longitude, 102.0)
  }

  func testParseLineString() {
    let features = features(withResource: "GeoJSON_LineString_Test")
    XCTAssertEqual(features.count, 1)

    guard let lineString = features.first?.geometry as? GMULineString else {
      XCTFail("Geometry is not a GMULineString")
      return
    }

    let path = GMSMutablePath()
    path.addLatitude(0.0, longitude: 102.0)
    path.addLatitude(1.0, longitude: 103.0)

    XCTAssertEqual(lineString.path.encodedPath(), path.encodedPath())
  }

  func testParsePolygon() {
    let features = features(withResource: "GeoJSON_Polygon_Test")
    XCTAssertEqual(features.count, 1)

    guard let polygon = features.first?.geometry as? GMUPolygon else {
      XCTFail("Geometry is not a GMUPolygon")
      return
    }


    let outerPath = GMSMutablePath()
    outerPath.addLatitude(10, longitude: 10)
    outerPath.addLatitude(20, longitude: 10)
    outerPath.addLatitude(20, longitude: 20)
    outerPath.addLatitude(10, longitude: 20)
    outerPath.addLatitude(10, longitude: 10)

    let innerPath = GMSMutablePath()
    innerPath.addLatitude(12.5, longitude: 12.5)
    innerPath.addLatitude(17.5, longitude: 12.5)
    innerPath.addLatitude(17.5, longitude: 17.5)
    innerPath.addLatitude(12.5, longitude: 17.5)
    innerPath.addLatitude(12.5, longitude: 12.5)

    XCTAssertEqual(polygon.paths.first?.encodedPath(), outerPath.encodedPath())
    XCTAssertEqual(polygon.paths.last?.encodedPath(), innerPath.encodedPath())
  }

  func testParseMultiPoint() {
    let features = features(withResource: "GeoJSON_MultiPoint_Test")
    XCTAssertEqual(features.count, 1)

    guard let points = features.first?.geometry as? GMUGeometryCollection else {
      XCTFail("Geometry is not a GMUGeometryCollection")
      return
    }

    guard let firstPoint = points.geometries.first as? GMUPoint,
          let secondPoint = points.geometries.last as? GMUPoint else {
      XCTFail("Geometry is not a GMUPoint")
      return
    }

    XCTAssertEqual(firstPoint.coordinate.latitude, 0.0)
    XCTAssertEqual(firstPoint.coordinate.longitude, 100.0)
    XCTAssertEqual(secondPoint.coordinate.latitude, 1.0)
    XCTAssertEqual(secondPoint.coordinate.longitude, 101.0)
  }

  func testParseMultiLineString() {
    let features = features(withResource: "GeoJSON_MultiLineString_Test")
    XCTAssertEqual(features.count, 1)

    guard let lineStrings = features.first?.geometry as? GMUGeometryCollection else {
      XCTFail("Geometry is not a GMUGeometryCollection")
      return
    }

    let firstLineString = lineStrings.geometries.first as! GMULineString
    let secondLineString = lineStrings.geometries.last as! GMULineString

    let firstPath = GMSMutablePath()
    firstPath.addLatitude(0.0, longitude: 100.0)
    firstPath.addLatitude(1.0, longitude: 101.0)

    let secondPath = GMSMutablePath()
    secondPath.addLatitude(2.0, longitude: 102.0)
    secondPath.addLatitude(3.0, longitude: 103.0)

    XCTAssertEqual(firstLineString.path.encodedPath(), firstPath.encodedPath())
    XCTAssertEqual(secondLineString.path.encodedPath(), secondPath.encodedPath())
  }

  func testParseMultiPolygon() {
    let features = features(withResource: "GeoJSON_MultiPolygon_Test")
    XCTAssertEqual(features.count, 1)

    guard let polygons = features.first?.geometry as? GMUGeometryCollection else {
      XCTFail("Geometry is not a GMUPolygon")
      return
    }

    let firstPolygon = polygons.geometries.first as! GMUPolygon
    let secondPolygon = polygons.geometries.last as! GMUPolygon


    let firstPath = GMSMutablePath()
    firstPath.addLatitude(2.0, longitude: 102.0)
    firstPath.addLatitude(2.0, longitude: 103.0)
    firstPath.addLatitude(3.0, longitude: 103.0)
    firstPath.addLatitude(3.0, longitude: 102.0)
    firstPath.addLatitude(2.0, longitude: 102.0)

    let secondPath = GMSMutablePath()
    secondPath.addLatitude(0.0, longitude: 100.0)
    secondPath.addLatitude(0.0, longitude: 101.0)
    secondPath.addLatitude(1.0, longitude: 101.0)
    secondPath.addLatitude(1.0, longitude: 100.0)
    secondPath.addLatitude(0.0, longitude: 100.0)

    XCTAssertEqual(firstPolygon.paths.first?.encodedPath(), firstPath.encodedPath())
    XCTAssertEqual(secondPolygon.paths.last?.encodedPath(), secondPath.encodedPath())
  }

  func testParseGeomeryCollection() {
    let features = features(withResource: "GeoJSON_GeometryCollection_Test")
    XCTAssertEqual(features.count, 1)

    guard let collection = features.first?.geometry as? GMUGeometryCollection else {
      XCTFail("Geometry is not a GMUGeometryCollection")
      return
    }

    guard let point = collection.geometries.first as? GMUPoint else {
      XCTFail("Geometry is not a GMUPoint")
      return
    }

    guard let lineString = collection.geometries.last as? GMULineString else {
      XCTFail("Geometry is not a GMULineString")
      return
    }

    let path = GMSMutablePath()
    path.addLatitude(0.0, longitude: 101.0)
    path.addLatitude(1.0, longitude: 102.0)

    XCTAssertEqual(point.coordinate.latitude, 0.0)
    XCTAssertEqual(point.coordinate.longitude, 100.0)
    XCTAssertEqual(lineString.path.encodedPath(), path.encodedPath())
  }

  func testParseFeature() {
    let features = features(withResource: "GeoJSON_Feature_Test")
    XCTAssertEqual(features.count, 1)

    guard let feature = features.first else {
      XCTFail("No first feature")
      return
    }

    guard let actualPoint = feature.geometry as? GMUPoint else {
      XCTFail("Geometry is not a GMUPoint")
      return
    }

    let northEast: CLLocationCoordinate2D = CLLocationCoordinate2DMake(10, 10)
    let southWest: CLLocationCoordinate2D = CLLocationCoordinate2DMake(-10, -10)
    let bounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
    let description: NSObject = "A feature for unit testing" as NSObject

    XCTAssertEqual(feature.identifier, "Test Feature")
    XCTAssertEqual(feature.properties, ["description": description])
    XCTAssertEqual(feature.boundingBox, bounds)
    XCTAssertEqual(actualPoint.coordinate.latitude, 0.5)
    XCTAssertEqual(actualPoint.coordinate.longitude, 102.0)
  }

  func testParseFeatureCollection() {
    let features = features(withResource: "GeoJSON_FeatureCollection_Test")
    XCTAssertEqual(features.count, 2)

    guard let firstFeature = features.first,
          let secondFeature = features.last else {
      XCTFail("Geometry is not a GMUFeature")
      return
    }

    let point = firstFeature.geometry as! GMUPoint
    let lineString = secondFeature.geometry as! GMULineString

    let path: GMSMutablePath = GMSMutablePath()
    path.addLatitude(0.0, longitude: 102.0)
    path.addLatitude(1.0, longitude: 103.0)

    XCTAssertEqual(point.coordinate.latitude, 0.5)
    XCTAssertEqual(point.coordinate.longitude, 102.0)
    XCTAssertEqual(lineString.path.encodedPath(), path.encodedPath())
  }

}
