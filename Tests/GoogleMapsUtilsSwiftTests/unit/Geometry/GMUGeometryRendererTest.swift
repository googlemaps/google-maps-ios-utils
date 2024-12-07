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

final class GMSMapViewMock: GMSMapView {
    var addedOverlays: [GMSOverlay] = []
    var clearCalled = false

    func add(_ overlay: GMSOverlay) {
        addedOverlays.append(overlay)
    }

    override func clear() {
        clearCalled = true
        addedOverlays.removeAll()
    }
}


final class GMUGeometryRendererTest: XCTestCase {
    private var mapView: GMSMapViewMock!
    private let titleText: String = "Test Title"
    private let snippetText: String = "Snippet Text"
    private let styleId: String = "#style"
    private let type: String = "GroundOverlay"
    private let href: String = "image.jpg"
    private let zIndex: Int = 1
    private let rotation: Double = 45.0
    
    override func setUp() {
        super.setUp()
        GMSServices.provideAPIKey("MOCK_API_KEY")
        mapView = GMSMapViewMock()
    }

    func testClear() {
         let position = CLLocationCoordinate2D(latitude: 45.123, longitude: 90.456)
         let point = GMUPoint1(coordinate: position)
         let feature = GMUFeature1(geometry: point, identifier: nil, properties: nil, boundingBox: nil)
         let features = [feature]
         
         let renderer = GMUGeometryRenderer1(map: mapView, geometries: features)
         renderer.render()
         
         var mapOverlays = renderer.getMapOverlays()
         XCTAssertEqual(mapOverlays.count, 1)
         
         renderer.clear()
         
         mapOverlays = renderer.getMapOverlays()
         XCTAssertEqual(mapOverlays.count, 0)
     }
    
    func testRenderMarker() {
        let position = CLLocationCoordinate2D(latitude: 45.123, longitude: 90.456)
        let point = GMUPoint1(coordinate: position)
        let style = self.styleForTest()
        let placemark = GMUPlacemark1(geometry: point, style: style, title: titleText, snippet: snippetText, styleUrl: nil)
        let placemarks = [placemark]
        
        let renderer = GMUGeometryRenderer1(map: mapView, geometries: placemarks)
        renderer.render()
        
        let mapOverlays = renderer.getMapOverlays()
        XCTAssertEqual(mapOverlays.count, 1)
        
        let marker = mapOverlays.first as? GMSMarker
        XCTAssertEqual(marker?.map, mapView)
        XCTAssertEqual(marker?.position.latitude, position.latitude)
        XCTAssertEqual(marker?.position.longitude, position.longitude)
        XCTAssertEqual(marker?.rotation, 1.0)
        XCTAssertEqual(marker?.title, titleText)
        XCTAssertEqual(marker?.snippet, snippetText)
    }

    
    func testRenderPolyLine() {
        let firstCoordinate = CLLocationCoordinate2D(latitude: 1.234, longitude: -3.456)
        let secondCoordinate = CLLocationCoordinate2D(latitude: 5.678, longitude: -6.789)
        let thirdCoordinate = CLLocationCoordinate2D(latitude: 4.567, longitude: -2.345)
        
        let path = GMSMutablePath()
        path.add(firstCoordinate)
        path.add(secondCoordinate)
        path.add(thirdCoordinate)
        
        let modelLineString = GMULineString1(path: path)
        
        let strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let style = self.styleForTest()
        
        let placemark = GMUPlacemark1(geometry: modelLineString, style: style, title: titleText, snippet: nil, styleUrl: nil)
        let placemarks = [placemark]
        
        let renderer = GMUGeometryRenderer1(map: mapView, geometries: placemarks)
        renderer.render()
        
        let mapOverlays = renderer.getMapOverlays()
        XCTAssertEqual(mapOverlays.count, 1)
        
        let polyline = mapOverlays.first as? GMSPolyline
        XCTAssertEqual(polyline?.map, mapView)
        XCTAssertEqual(polyline?.path?.encodedPath(), path.encodedPath())
        XCTAssertEqual(polyline?.title, titleText)
        XCTAssertEqual(polyline?.strokeColor, strokeColor)
        XCTAssertEqual(polyline?.strokeWidth, 1.0)
    }

    func testGroundOverlay() {
        let northEast = CLLocationCoordinate2D(latitude: 234.567, longitude: 345.678)
        let southWest = CLLocationCoordinate2D(latitude: 123.456, longitude: 456.789)
        let groundOverlay = GMUGroundOverlay1(northEast: northEast, southWest: southWest, zIndex: zIndex, rotation: rotation, href: href)
        
        let feature = GMUFeature1(geometry: groundOverlay, identifier: nil, properties: nil, boundingBox: nil)
        let features = [feature]
        
        let renderer = GMUGeometryRenderer1(map: mapView, geometries: features)
        renderer.render()
        
        let mapOverlays = renderer.getMapOverlays()
        XCTAssertEqual(mapOverlays.count, 1)
    }

    func testRenderPolygon() {
        var firstCoord = CLLocationCoordinate2D(latitude: 10, longitude: 10)
        var secondCoord = CLLocationCoordinate2D(latitude: 20, longitude: 10)
        var thirdCoord = CLLocationCoordinate2D(latitude: 20, longitude: 20)
        var fourthCoord = CLLocationCoordinate2D(latitude: 10, longitude: 20)
        
        let outerPath = GMSMutablePath()
        outerPath.add(firstCoord)
        outerPath.add(secondCoord)
        outerPath.add(thirdCoord)
        outerPath.add(fourthCoord)
        outerPath.add(firstCoord)
        
        firstCoord = CLLocationCoordinate2D(latitude: 12.5, longitude: 12.5)
        secondCoord = CLLocationCoordinate2D(latitude: 17.5, longitude: 12.5)
        thirdCoord = CLLocationCoordinate2D(latitude: 17.5, longitude: 17.5)
        fourthCoord = CLLocationCoordinate2D(latitude: 12.5, longitude: 17.5)
        
        let innerPath = GMSMutablePath()
        innerPath.add(firstCoord)
        innerPath.add(secondCoord)
        innerPath.add(thirdCoord)
        innerPath.add(fourthCoord)
        innerPath.add(firstCoord)
        
        let paths = [outerPath, innerPath]
        let modelPolygon = GMUPolygon1(paths: paths)
        
        let strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let fillColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        let style = self.styleForTest()
        let placemark = GMUPlacemark1(geometry: modelPolygon, style: style, title: titleText, snippet: nil, styleUrl: nil)
        let placemarks = [placemark]
        
        let renderer = GMUGeometryRenderer1(map: mapView, geometries: placemarks)
        renderer.render()
        
        let mapOverlays = renderer.getMapOverlays()
        XCTAssertEqual(mapOverlays.count, 1)
        
        let polygon = mapOverlays.first as? GMSPolygon
        XCTAssertEqual(polygon?.map, mapView)
        XCTAssertEqual(polygon?.path?.encodedPath(), outerPath.encodedPath())
        XCTAssertEqual(polygon?.holes?[0].encodedPath(), innerPath.encodedPath())
        XCTAssertEqual(polygon?.title, titleText)
        XCTAssertEqual(polygon?.strokeColor, strokeColor)
        XCTAssertEqual(polygon?.strokeWidth, 1.0)
        XCTAssertEqual(polygon?.fillColor, fillColor)
    }

    func testRenderMultiGeometry() {
        var position = CLLocationCoordinate2D(latitude: 45.123, longitude: 90.456)
        let firstPoint = GMUPoint1(coordinate: position)
        
        position = CLLocationCoordinate2D(latitude: 12.345, longitude: 23.456)
        let secondPoint = GMUPoint1(coordinate: position)
        
        let geometryCollection = GMUGeometryCollection1(geometries: [firstPoint, secondPoint])
        let placemark = GMUPlacemark1(geometry: geometryCollection, style: nil, title: nil, snippet: nil, styleUrl: nil)
        let placemarks = [placemark]
        
        let renderer = GMUGeometryRenderer1(map: mapView, geometries: placemarks, styles: nil)
        renderer.render()
        
        let mapOverlays = renderer.getMapOverlays()
        XCTAssertEqual(mapOverlays.count, 2)
    }
    
    func testRenderGeometryWithExternalStyle() {
        let position = CLLocationCoordinate2D(latitude: 45.123, longitude: 90.456)
        let point = GMUPoint1(coordinate: position)
        let placemark = GMUPlacemark1(geometry: point, style: nil, title: titleText, snippet: nil, styleUrl: styleId)
        let placemarks = [placemark]
        
        let style = self.styleForTest()
        let styles = [style]
        
        let renderer = GMUGeometryRenderer1(map: mapView, geometries: placemarks, styles: styles)
        renderer.render()
        
        let mapOverlays = renderer.getMapOverlays()
        XCTAssertEqual(mapOverlays.count, 1)
        
        let marker = mapOverlays.first as! GMSMarker
        XCTAssertEqual(marker.map, mapView)
        XCTAssertEqual(marker.title, titleText)
    }

    func testImageFromPathWithURLNotNil() {
        XCTAssertNotNil(GMUGeometryRenderer1.image(fromPath: "https://maps.google.com/mapfiles/kml/pal3/icon55.png"))
    }

    func testImageFromPathWithURLNil() {
        XCTAssertNil(GMUGeometryRenderer1.image(fromPath: nil))
    }

    func testGetStyleFromStyleMapsEqualsExpectedStyle() {
        let position = CLLocationCoordinate2D(latitude: 45.123, longitude: 90.456)
        let point = GMUPoint1(coordinate: position)
        let placemark = GMUPlacemark1(geometry: point, style: nil, title: titleText, snippet: nil, styleUrl: styleId)
        let placemarks = [placemark]
        let style = self.styleForTest()
        let styles = [style]
        
        let pair = GMUPair1(key: "normal", styleUrl: "#style")
        let pairArray = [pair]
        
        let styleMap = GMUStyleMap1(styleMapId: "styles", pairs: pairArray)
        let styleMapArray = [styleMap]
        
        let renderer = GMUGeometryRenderer1(map: mapView, geometries: placemarks, styles: styles, styleMaps: styleMapArray)
        XCTAssertEqual(style, renderer.getStyle(fromStyleMaps: "styles"))
    }

    func testGetStyleFromStyleMapsWithEmptyURLAndNilStyleMapObject() {
        let position = CLLocationCoordinate2D(latitude: 45.123, longitude: 90.456)
        let point = GMUPoint1(coordinate: position)
        let placemark = GMUPlacemark1(geometry: point, style: nil, title: titleText, snippet: nil, styleUrl: styleId)
        let placemarks = [placemark]
        let style = self.styleForTest()
        let styles = [style]
        
        let renderer = GMUGeometryRenderer1(map: mapView, geometries: placemarks, styles: styles, styleMaps: nil)
        XCTAssertNil(renderer.getStyle(fromStyleMaps: ""))
    }
    
    func styleForTest() -> GMUStyle1 {
        let strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let fillColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        return GMUStyle1(styleID: styleId,
                      strokeColor: strokeColor,
                      fillColor: fillColor,
                      width: 1.0,
                      scale: 0.0,
                      heading: 1.0,
                      anchor: CGPoint.zero,
                      iconUrl: nil,
                      title: titleText,
                      hasFill: true,
                      hasStroke: true)
    }
}
