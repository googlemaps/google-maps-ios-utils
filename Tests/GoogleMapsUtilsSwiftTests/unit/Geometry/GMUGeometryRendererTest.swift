/*

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
@testable import GoogleMapsUtilsSwift

final class GMUGeometryRendererTest: XCTestCase {

  private var mapView: MockMapView = MockMapView()
  private var renderer: GMUGeometryRenderer!

  static let titleText: String = "Test Title"
  static let snippetText: String = "Snippet Text"
  static let styleId: String = "#style"
  static let type: String = "GroundOverlay"
  static let hRef: String = "image.jpg"
  static let zIndex: Int32 = 1
  static let rotation: Double = 45.0
  static let strokeColor: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
  static let fillColor: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
  static let styleForTest: GMUStyle = GMUStyle(styleID: styleId, stroke: strokeColor, fill: fillColor, width: 1.0, scale: 0.0, heading: 1.0, anchor: CGPointZero, iconUrl: nil, title: titleText, hasFill: true, hasStroke: true)

  override func setUp() {
    super.setUp()
    renderer = GMUGeometryRenderer()
  }

  override func tearDown() {
    renderer = nil
    super.tearDown()
  }

  func testInitialization() {
    XCTAssertNotNil(renderer)
    XCTAssertEqual(renderer.mapOverlays().count, 0)
  }
    
  func testRenderPointWithStyle() {
    let point = GMUPoint(coordinate: CLLocationCoordinate2D(latitude: 37.7, longitude: -122.4))
    let placemark = GMUPlacemark(geometry: point, title: GMUGeometryRendererTest.titleText, snippet: nil, style: nil, styleUrl: GMUGeometryRendererTest.styleId)

    renderer = GMUGeometryRenderer(map: mapView, geometries: [placemark], styles: [GMUGeometryRendererTest.styleForTest])
    renderer.render()

    XCTAssertEqual(renderer.mapOverlays().count, 1)
    let marker = renderer.mapOverlays().first as? GMSMarker
    XCTAssertNotNil(marker)
    XCTAssertEqual(marker?.position.latitude, 37.7)
    XCTAssertEqual(marker?.position.longitude, -122.4)
    XCTAssertEqual(marker?.title, "Test Point")
  }

  func testRenderLineStringWithStyle() {
    let path = GMSMutablePath()
    path.addLatitude(37.7, longitude: -122.4)
    path.addLatitude(37.8, longitude: -122.5)
    let lineString = GMULineString(path: path)
    let placeMark = GMUPlacemark(geometry: lineString, title: GMUGeometryRendererTest.titleText, snippet: GMUGeometryRendererTest.snippetText, style: GMUGeometryRendererTest.styleForTest, styleUrl: nil)

    renderer = GMUGeometryRenderer(map: mapView, geometries: [placeMark], styles: [GMUGeometryRendererTest.styleForTest])
    renderer.render()

    XCTAssertEqual(renderer.mapOverlays().count, 1)
    let polyline = renderer.mapOverlays().first as? GMSPolyline
    XCTAssertNotNil(polyline)
    XCTAssertEqual(polyline?.map, mapView)
    XCTAssertEqual(polyline?.path?.encodedPath(), path.encodedPath())
    XCTAssertEqual(polyline?.path?.count(), 2)
    XCTAssertEqual(polyline?.strokeColor, GMUGeometryRendererTest.strokeColor)
    XCTAssertEqual(polyline?.strokeWidth, 1.0)
  }

  func testRenderPolygon() {
    // Create outer path
    let outerPath = GMSMutablePath()
    outerPath.addLatitude(37.7, longitude: -122.4)
    outerPath.addLatitude(37.8, longitude: -122.4)
    outerPath.addLatitude(37.8, longitude: -122.5)
    outerPath.addLatitude(37.7, longitude: -122.5)

    // Create inner path (hole) - optional
    let innerPath = GMSMutablePath()
    innerPath.addLatitude(37.75, longitude: -122.45)
    innerPath.addLatitude(37.78, longitude: -122.45)
    innerPath.addLatitude(37.78, longitude: -122.48)
    innerPath.addLatitude(37.75, longitude: -122.48)

    // Create polygon
    let polygon = GMUPolygon(paths: [outerPath, innerPath])
    let placeMark = GMUPlacemark(geometry: polygon, title: GMUGeometryRendererTest.titleText, snippet: GMUGeometryRendererTest.snippetText, style: GMUGeometryRendererTest.styleForTest, styleUrl: nil)

    renderer = GMUGeometryRenderer(map: mapView, geometries: [placeMark])

    XCTAssertEqual(renderer.mapOverlays().count, 1)
    let gmsPolygon = renderer.mapOverlays().first as? GMSPolygon
    XCTAssertNotNil(gmsPolygon)
    XCTAssertEqual(gmsPolygon?.path?.count(), 4) // Outer path count
    XCTAssertEqual(gmsPolygon?.holes?.count, 1)  // Inner path (hole) count
    XCTAssertEqual(gmsPolygon?.title, GMUGeometryRendererTest.titleText)
    XCTAssertEqual(gmsPolygon?.fillColor, GMUGeometryRendererTest.fillColor)
    XCTAssertEqual(gmsPolygon?.strokeColor, GMUGeometryRendererTest.strokeColor)
  }

  func testRenderGroundOverlay() {
    let northEast = CLLocationCoordinate2D(latitude: 37.9, longitude: -122.6)
    let southWest = CLLocationCoordinate2D(latitude: 32.9, longitude: -120.6)
    let groundOverlay = GMUGroundOverlay(coordinate: northEast, southWest: southWest, zIndex: GMUGeometryRendererTest.zIndex, rotation: GMUGeometryRendererTest.rotation, href: GMUGeometryRendererTest.hRef)
    let feature = GMUFeature(geometry: groundOverlay, identifier: nil, properties: nil, boundingBox: nil)

    renderer = GMUGeometryRenderer(map: mapView, geometries: [feature])
    renderer.render()

    XCTAssertEqual(renderer.mapOverlays().count, 1)
  }

  func testRenderMultiGeometry() {
    let point = GMUPoint(coordinate: CLLocationCoordinate2D(latitude: 37.7, longitude: -122.4))
    let placemark = GMUPlacemark(geometry: point, title: GMUGeometryRendererTest.titleText, snippet: nil, style: nil, styleUrl: GMUGeometryRendererTest.styleId)

    let path = GMSMutablePath()
    path.addLatitude(37.7, longitude: -122.4)
    path.addLatitude(37.8, longitude: -122.5)
    let lineString = GMULineString(path: path)
    let polyline = GMUPlacemark(geometry: lineString, title: GMUGeometryRendererTest.titleText, snippet: GMUGeometryRendererTest.snippetText, style: GMUGeometryRendererTest.styleForTest, styleUrl: nil)


    renderer = GMUGeometryRenderer(map: mapView, geometries: [placemark, polyline], styles: [GMUGeometryRendererTest.styleForTest])
    renderer.render()

    XCTAssertEqual(renderer.mapOverlays().count, 2)
  }

  func testImageFromPathWithUrlNil() {
    XCTAssertNil(GMUGeometryRenderer.image(fromPath: nil))
  }

  func testClear() {
    let position = CLLocationCoordinate2D(latitude: 45.123, longitude: 90.456)
    let point = GMUPoint(coordinate: position)
    let feature = GMUFeature(geometry: point, identifier: nil, properties: nil, boundingBox: nil)

    renderer = GMUGeometryRenderer(map: mapView, geometries: [feature])
    renderer.render()

    XCTAssertEqual(renderer.mapOverlays().count, 1)
    renderer.clear()
    XCTAssertEqual(renderer.mapOverlays().count, 0)
  }

}

*/
