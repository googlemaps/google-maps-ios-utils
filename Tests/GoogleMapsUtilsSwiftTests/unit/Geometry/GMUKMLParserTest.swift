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

class GMUKMLParserTest: XCTestCase {

  // Helper function to load GeoJSON data
  func parserWithResource(_ resource: String) -> GMUKMLParser {
    #if SWIFT_PACKAGE
    guard let path = Bundle.module.path(forResource: resource, ofType: "kml"),
          let fileContents = try? String(contentsOfFile: path, encoding: .utf8),
          let data = fileContents.data(using: .utf8) else {
      XCTFail("GeoJSON resource not found or failed to load.")
      return GMUKMLParser()
    }
    #else
    let bundle = Bundle(for: Self.self)
    guard let path = bundle.path(forResource: resource, ofType: "kml"),
          let fileContents = try? String(contentsOfFile: path, encoding: .utf8),
          let data = fileContents.data(using: .utf8) else {
      XCTFail("GeoJSON resource not found or failed to load.")
      return GMUKMLParser()
    }
    #endif
    let parser = GMUKMLParser(data: data)
    parser.parse()
    return parser
  }

  func placemarksWithResource(_ resource: String) -> [GMUPlacemark] {
    guard let placemarks = parserWithResource(resource).placemarks as? [GMUPlacemark] else {
      XCTFail("Geometry is not a GMUPlacemark")
      return []
    }
    return placemarks
  }

  func stylesWithResource(_ resource: String) -> [GMUStyle] {
    return parserWithResource(resource).styles
  }

  func testInitWithURL() {
    #if SWIFT_PACKAGE
    guard let path = Bundle.module.path(forResource: "KML_Point_Test", ofType: "kml") else {
      XCTFail("GeoJSON resource not found or failed to load.")
      return
    }
    #else
    let bundle = Bundle(for: Self.self)
    guard let path = bundle.path(forResource: "KML_Point_Test", ofType: "kml") else {
      XCTFail("GeoJSON resource not found or failed to load.")
      return
    }
    #endif
    let url = URL(fileURLWithPath: path)
    let parser = GMUKMLParser(url: url)
    parser.parse()
    XCTAssertEqual(parser.placemarks.count, 1)
  }

  func testInitWithStream() {
    #if SWIFT_PACKAGE
    guard let path = Bundle.module.path(forResource: "KML_Point_Test", ofType: "kml") else {
      XCTFail("GeoJSON resource not found or failed to load.")
      return
    }
    #else
    let bundle = Bundle(for: Self.self)
    guard let path = bundle.path(forResource: "KML_Point_Test", ofType: "kml") else {
      XCTFail("GeoJSON resource not found or failed to load.")
      return
    }
    #endif
    let file = try! String(contentsOfFile: path, encoding: .utf8)
    let data = file.data(using: .utf8)!
    let stream = InputStream(data: data)
    let parser = GMUKMLParser(stream: stream)
    parser.parse()
    XCTAssertEqual(parser.placemarks.count, 1)
  }

  func testParsePoint() {
    let placemarks = placemarksWithResource("KML_Point_Test")
    XCTAssertEqual(placemarks.count, 1)
    let point = placemarks.first!.geometry as! GMUPoint
    XCTAssertEqual(point.coordinate.latitude, 0.5)
    XCTAssertEqual(point.coordinate.longitude, 102.0)
  }

  func testParseLineString() {
    let placemarks = placemarksWithResource("KML_LineString_Test")
    XCTAssertEqual(placemarks.count, 1)
    let path = GMSMutablePath()
    path.addLatitude(0.0, longitude: 102.0)
    path.addLatitude(1.0, longitude: 103.0)
    let lineString = placemarks.first!.geometry as! GMULineString
    XCTAssertEqual(lineString.path.encodedPath(), path.encodedPath())
  }

  func testParsePolygon() {
    let placemarks = placemarksWithResource("KML_Polygon_Test")
    XCTAssertEqual(placemarks.count, 1)
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
    let polygon = placemarks.first!.geometry as! GMUPolygon
    XCTAssertEqual(polygon.paths.first!.encodedPath(), outerPath.encodedPath())
    XCTAssertEqual(polygon.paths.last!.encodedPath(), innerPath.encodedPath())
  }

  func testParseGroundOverlay() {
    let placemarks = placemarksWithResource("KML_GroundOverlay_Test")
    XCTAssertEqual(placemarks.count, 1)
    let groundOverlay = placemarks.first!.geometry as! GMUGroundOverlay
    XCTAssertEqual(groundOverlay.northEast.latitude, 10)
    XCTAssertEqual(groundOverlay.northEast.longitude, 10)
    XCTAssertEqual(groundOverlay.southWest.latitude, -10)
    XCTAssertEqual(groundOverlay.southWest.longitude, -10)
    XCTAssertEqual(groundOverlay.zIndex, 1)
    XCTAssertEqual(groundOverlay.rotation, 315.0)
    XCTAssertEqual(groundOverlay.href, "https://www.google.com/intl/en/images/logo.gif")
  }

  func testParseMultiGeometry() {
    let placemarks = placemarksWithResource("KML_MultiGeometry_Test")
    XCTAssertEqual(placemarks.count, 1)
    let points = placemarks.first!.geometry as! GMUGeometryCollection
    let firstPoint = points.geometries.first as! GMUPoint
    let secondPoint = points.geometries.last as! GMUPoint
    XCTAssertEqual(firstPoint.coordinate.latitude, 1.0)
    XCTAssertEqual(firstPoint.coordinate.longitude, 10.0)
    XCTAssertEqual(secondPoint.coordinate.latitude, 2.0)
    XCTAssertEqual(secondPoint.coordinate.longitude, 20.0)
  }

  func testParseStyle() {
    let styles = stylesWithResource("KML_Style_Test")
    XCTAssertEqual(styles.count, 1)
    let strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let fillColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    let style = styles.first!
    XCTAssertEqual(style.styleID, "#Test Style")
    XCTAssertEqual(style.strokeColor, strokeColor)
    XCTAssertEqual(style.fillColor, fillColor)
    XCTAssertEqual(style.width, 5)
    XCTAssertEqual(style.scale, 2.5)
    XCTAssertEqual(style.heading, 45.0)
    XCTAssertEqual(style.anchor.x, 0.25)
    XCTAssertEqual(style.anchor.y, 0.75)
    XCTAssertEqual(style.iconUrl, "https://maps.google.com/mapfiles/kml/pal3/icon55.png")
    XCTAssertEqual(style.title, "A Point title")
    XCTAssertTrue(style.hasFill)
    XCTAssertTrue(style.hasStroke)
  }

  func testParseStyleMap() {
    let parser = parserWithResource("KML_StyleMap_Test")
    XCTAssertEqual(1, parser.styleMaps.count)
    XCTAssertEqual(2, parser.styles.count)
    XCTAssertEqual(2, parser.styleMaps.first!.pairs.count)

    let style1 = findStyleWithName("#line-FF0000-5000-nodesc-normal", in: parser.styles)
    XCTAssertEqual(style1.strokeColor, UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0))

    let style2 = findStyleWithName("#line-FF0000-5000-nodesc-highlight", in: parser.styles)
    XCTAssertEqual(style2.strokeColor, UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0))
  }

  func findStyleWithName(_ name: String, in array: [GMUStyle]) -> GMUStyle {
    return array.first(where: { $0.styleID == name })!
  }

  func testParsePlacemark() {
    let placemarks = placemarksWithResource("KML_Placemark_Test")
    XCTAssertEqual(placemarks.count, 1)
    let placemark = placemarks.first!
    XCTAssertEqual(placemark.title, "Test Placemark")
    XCTAssertEqual(placemark.snippet, "A Placemark for testing purposes.")
    XCTAssertEqual(placemark.styleUrl, "#exampleStyle")
  }
}
