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
import CoreLocation
import GoogleMaps

@testable import GoogleMapsUtils

class GMSPolygonGeometryUtilsTest: XCTestCase {
  
  // MARK: - Test Constants
  /// Standard accuracy for area calculations (0.4 square meters)
  private let areaAccuracy = 0.4
  /// High precision accuracy for signed area calculations
  private let signedAreaAccuracy = 1e-6
  /// Tolerance for small coordinate differences (approximately 5cm on equator)
  private let smallCoordinateDiff = 5e-7

  // MARK: - Standard Test Coordinates
  /// North pole coordinate
  private let northPole = CLLocationCoordinate2D(latitude: 90, longitude: 0)
  /// South pole coordinate
  private let southPole = CLLocationCoordinate2D(latitude: -90, longitude: 0)
  /// Equator at prime meridian
  private let equatorPrime = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  /// Equator at 90° East
  private let equator90E = CLLocationCoordinate2D(latitude: 0, longitude: 90)
  /// Equator at 180° meridian
  private let equator180 = CLLocationCoordinate2D(latitude: 0, longitude: 180)
  /// Equator at 90° West
  private let equator90W = CLLocationCoordinate2D(latitude: 0, longitude: -90)
}

// MARK: - Tests for contains(coordinate:)

extension GMSPolygonGeometryUtilsTest {
  
  /// Test point-in-polygon detection with a polygon that has no path
  func testContains_WithNilPath_ReturnsFalse() {
    // Given: A polygon with no path
    let polygon = GMSPolygon()
    XCTAssertNil(polygon.path, "Polygon should have nil path for this test")
    let testPoint = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    // When: Testing if point is contained
    let result = polygon.contains(coordinate: testPoint)
    // Then: Should return false
    XCTAssertFalse(result, "Polygon with nil path should not contain any point")
  }

  /// Test point-in-polygon detection with an empty path
  func testContains_WithEmptyPath_ReturnsFalse() {
    // Given: A polygon with empty path
    let polygon = GMSPolygon(path: GMSMutablePath())
    let testPoint = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    // When: Testing if point is contained
    let result = polygon.contains(coordinate: testPoint)

    // Then: Should return false
    XCTAssertFalse(result, "Polygon with empty path should not contain any point")
  }

  /// Test point-in-polygon detection with a simple triangular polygon
  func testContains_SimpleTriangle_DetectsPointsCorrectly() {
    // Given: A simple right triangle with vertices at (0,0), (10,0), (0,10)
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))   // Bottom-left
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 10))  // Bottom-right  
    path.add(CLLocationCoordinate2D(latitude: 10, longitude: 0))  // Top-left

    let polygon = GMSPolygon(path: path)

    // Test points inside the triangle
    let insidePoints = [
      CLLocationCoordinate2D(latitude: 1, longitude: 1),    // Near bottom-left vertex
      CLLocationCoordinate2D(latitude: 3, longitude: 3),    // Center area
      CLLocationCoordinate2D(latitude: 2, longitude: 7),    // Near bottom edge
      CLLocationCoordinate2D(latitude: 7, longitude: 2)     // Near left edge
    ]

    // Test points outside the triangle
    let outsidePoints = [
      CLLocationCoordinate2D(latitude: -1, longitude: 5),   // Below triangle
      CLLocationCoordinate2D(latitude: 15, longitude: 5),   // Above triangle
      CLLocationCoordinate2D(latitude: 5, longitude: -1),   // Left of triangle
      CLLocationCoordinate2D(latitude: 5, longitude: 15),   // Right of triangle
      CLLocationCoordinate2D(latitude: 8, longitude: 8)     // Outside hypotenuse
    ]

    // When & Then: Test inside points
    for point in insidePoints {
      XCTAssertTrue(
        polygon.contains(coordinate: point),
        "Point \(point) should be inside the triangle"
      )
    }

    // When & Then: Test outside points
    for point in outsidePoints {
      XCTAssertFalse(
        polygon.contains(coordinate: point),
        "Point \(point) should be outside the triangle"
      )
    }
  }

  /// Test point-in-polygon with a polygon covering the North Pole
  func testContains_NorthPolePolygon_HandlesExtremeCases() {
    // Given: A polygon around the North Pole
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 89, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 89, longitude: 120))
    path.add(CLLocationCoordinate2D(latitude: 89, longitude: -120))

    let polygon = GMSPolygon(path: path)

    // Points that should be inside (North Pole region)
    let insidePoints = [
      northPole,                                            // Exact North Pole
      CLLocationCoordinate2D(latitude: 90, longitude: 45),  // North Pole at different longitude
      CLLocationCoordinate2D(latitude: 89.5, longitude: 60) // Point between path vertices
    ]

    // Points that should be outside
    let outsidePoints = [
      southPole,                                            // South Pole
      equatorPrime,                                         // Equator
      CLLocationCoordinate2D(latitude: 88, longitude: 0)    // Below the polygon boundary
    ]

    // When & Then: Test inside points
    for point in insidePoints {
      XCTAssertTrue(
        polygon.contains(coordinate: point),
        "Point \(point) should be inside the North Pole polygon"
      )
    }

    // When & Then: Test outside points
    for point in outsidePoints {
      XCTAssertFalse(
        polygon.contains(coordinate: point),
        "Point \(point) should be outside the North Pole polygon"
      )
    }
  }

  /// Test point-in-polygon with a square polygon
  func testContains_SquarePolygon_DetectsVerticesAndEdges() {
    // Given: A square polygon
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 10))
    path.add(CLLocationCoordinate2D(latitude: 10, longitude: 10))
    path.add(CLLocationCoordinate2D(latitude: 10, longitude: 0))

    let polygon = GMSPolygon(path: path)

    // Test vertices (should be considered inside)
    let vertices = [
      CLLocationCoordinate2D(latitude: 0, longitude: 0),
      CLLocationCoordinate2D(latitude: 0, longitude: 10),
      CLLocationCoordinate2D(latitude: 10, longitude: 10),
      CLLocationCoordinate2D(latitude: 10, longitude: 0)
    ]

    // Test center point
    let centerPoint = CLLocationCoordinate2D(latitude: 5, longitude: 5)

    // Test points near edges (slightly inside to avoid boundary ambiguity)
    let nearEdgePoints = [
      CLLocationCoordinate2D(latitude: 1, longitude: 5),    // Near bottom edge
      CLLocationCoordinate2D(latitude: 5, longitude: 9),    // Near right edge
      CLLocationCoordinate2D(latitude: 9, longitude: 5),    // Near top edge
      CLLocationCoordinate2D(latitude: 5, longitude: 1)     // Near left edge
    ]

    // When & Then: Test vertices
    for vertex in vertices {
      XCTAssertTrue(
        polygon.contains(coordinate: vertex),
        "Vertex \(vertex) should be considered inside the polygon"
      )
    }

    // When & Then: Test center
    XCTAssertTrue(
      polygon.contains(coordinate: centerPoint),
      "Center point should be inside the polygon"
    )

    // When & Then: Test near edge points
    for nearEdgePoint in nearEdgePoints {
      XCTAssertTrue(
        polygon.contains(coordinate: nearEdgePoint),
        "Near edge point \(nearEdgePoint) should be considered inside the polygon"
      )
    }
  }
}

// MARK: - Tests for area(radius:)
extension GMSPolygonGeometryUtilsTest {

  /// Test area calculation with a polygon that has no path
  func testArea_WithNilPath_ReturnsNil() {
    // Given: A polygon with no path
    let polygon = GMSPolygon()
    XCTAssertNil(polygon.path, "Polygon should have nil path for this test")

    // When: Calculating area
    let area = polygon.area()

    // Then: Should return nil
    XCTAssertNil(area, "Area calculation should return nil for polygon with nil path")
  }

  /// Test area calculation with default radius parameter
  func testArea_WithDefaultRadius_UsesEarthRadius() {
    // Given: A simple triangular polygon
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 1))
    path.add(CLLocationCoordinate2D(latitude: 1, longitude: 0))

    let polygon = GMSPolygon(path: path)

    // When: Calculating area with default radius
    let areaDefault = polygon.area()
    let areaExplicit = polygon.area(radius: kGMSEarthRadius)

    // Then: Both should be equal and non-nil
    XCTAssertNotNil(areaDefault, "Area calculation should not return nil")
    XCTAssertNotNil(areaExplicit, "Area calculation should not return nil")
    XCTAssertEqual(
      areaDefault!, areaExplicit!,
      accuracy: signedAreaAccuracy,
      "Default radius should equal explicit Earth radius"
    )
  }

  /// Test area calculation with custom radius
  func testArea_WithCustomRadius_ScalesCorrectly() {
    // Given: A simple square polygon
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 1))
    path.add(CLLocationCoordinate2D(latitude: 1, longitude: 1))
    path.add(CLLocationCoordinate2D(latitude: 1, longitude: 0))

    let polygon = GMSPolygon(path: path)

    // When: Calculating area with different radii
    let areaRadius1 = polygon.area(radius: 1.0)
    let areaRadius2 = polygon.area(radius: 2.0)

    // Then: Area should scale with radius squared
    XCTAssertNotNil(areaRadius1, "Area calculation should not return nil")
    XCTAssertNotNil(areaRadius2, "Area calculation should not return nil")
    XCTAssertEqual(
      areaRadius2!, areaRadius1! * 4.0,
      accuracy: signedAreaAccuracy,
      "Area should scale with radius squared"
    )
  }

  /// Test area calculation with a hemisphere-sized polygon
  func testArea_LargePolygon_CalculatesCorrectly() {
    // Given: A large polygon covering approximately a hemisphere
    let path = GMSMutablePath()
    path.add(equator90E)
    path.add(northPole)
    path.add(equatorPrime)
    path.add(southPole)
    path.add(equator90E)

    let polygon = GMSPolygon(path: path)

    // When: Calculating area
    let area = polygon.area()

    // Then: Should be approximately π * R²
    let expectedArea = .pi * pow(kGMSEarthRadius, 2)
    XCTAssertNotNil(area, "Area calculation should not return nil")
    XCTAssertEqual(
      area!, expectedArea,
      accuracy: areaAccuracy,
      "Large polygon area should be approximately π * R²"
    )
  }

  /// Test area calculation with empty path
  func testArea_WithEmptyPath_ReturnsZero() {
    // Given: A polygon with empty path
    let polygon = GMSPolygon(path: GMSMutablePath())

    // When: Calculating area
    let area = polygon.area()

    // Then: Should return zero
    XCTAssertNotNil(area, "Area calculation should not return nil for empty path")
    XCTAssertEqual(area!, 0.0, accuracy: signedAreaAccuracy, "Empty polygon should have zero area")
  }
}

// MARK: - Tests for signedArea(radius:)
extension GMSPolygonGeometryUtilsTest {

  /// Test signed area calculation with a polygon that has no path
  func testSignedArea_WithNilPath_ReturnsNil() {
    // Given: A polygon with no path
    let polygon = GMSPolygon()
    XCTAssertNil(polygon.path, "Polygon should have nil path for this test")

    // When: Calculating signed area
    let signedArea = polygon.signedArea()

    // Then: Should return nil
    XCTAssertNil(signedArea, "Signed area calculation should return nil for polygon with nil path")
  }

  /// Test signed area calculation with counter-clockwise polygon (positive area)
  func testSignedArea_CounterClockwise_ReturnsPositiveArea() {
    // Given: A counter-clockwise triangle (positive orientation)
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0.1))
    path.add(CLLocationCoordinate2D(latitude: 0.1, longitude: 0.1))

    let polygon = GMSPolygon(path: path)

    // When: Calculating signed area with unit radius
    let signedArea = polygon.signedArea(radius: 1)

    // Then: Should be positive
    XCTAssertNotNil(signedArea, "Signed area calculation should not return nil")
    XCTAssertGreaterThan(signedArea!, 0, "Counter-clockwise polygon should have positive signed area")

    // Verify expected value (approximately (0.1 radians)² / 2)
    let expectedArea = pow(0.1.degreesToRadians, 2) / 2
    XCTAssertEqual(
      signedArea!, expectedArea,
      accuracy: signedAreaAccuracy,
      "Signed area should match expected calculation"
    )
  }

  /// Test signed area calculation with clockwise polygon (negative area)
  func testSignedArea_Clockwise_ReturnsNegativeArea() {
    // Given: A clockwise triangle (negative orientation)
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 0.1, longitude: 0.1))
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0.1))

    let polygon = GMSPolygon(path: path)

    // When: Calculating signed area with unit radius
    let signedArea = polygon.signedArea(radius: 1)

    // Then: Should be negative
    XCTAssertNotNil(signedArea, "Signed area calculation should not return nil")
    XCTAssertLessThan(signedArea!, 0, "Clockwise polygon should have negative signed area")
  }
  
  /// Test signed area with opposite orientations have opposite signs
  func testSignedArea_OppositeOrientations_HaveOppositeSigns() {
    // Given: Two triangles with opposite orientations
    let pathCCW = GMSMutablePath()
    pathCCW.add(equator90E)
    pathCCW.add(northPole)
    pathCCW.add(equatorPrime)

    let pathCW = GMSMutablePath()
    pathCW.add(equatorPrime)
    pathCW.add(northPole)
    pathCW.add(equator90E)

    let polygonCCW = GMSPolygon(path: pathCCW)
    let polygonCW = GMSPolygon(path: pathCW)

    // When: Calculating signed areas
    let signedAreaCCW = polygonCCW.signedArea(radius: 1)
    let signedAreaCW = polygonCW.signedArea(radius: 1)

    // Then: Should have opposite signs and equal magnitudes
    XCTAssertNotNil(signedAreaCCW, "CCW signed area should not be nil")
    XCTAssertNotNil(signedAreaCW, "CW signed area should not be nil")

    XCTAssertEqual(
      signedAreaCCW!, .pi / 2,
      accuracy: signedAreaAccuracy,
      "CCW triangle should have area π/2"
    )

    XCTAssertEqual(
      signedAreaCW!, -.pi / 2,
      accuracy: signedAreaAccuracy,
      "CW triangle should have area -π/2"
    )

    XCTAssertEqual(
      signedAreaCCW!, -signedAreaCW!,
      accuracy: signedAreaAccuracy,
      "Opposite orientations should have opposite signed areas"
    )
  }

  /// Test signed area with custom radius parameter
  func testSignedArea_WithCustomRadius_ScalesCorrectly() {
    // Given: A simple triangle
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 1))
    path.add(CLLocationCoordinate2D(latitude: 1, longitude: 0))

    let polygon = GMSPolygon(path: path)

    // When: Calculating signed area with different radii
    let signedAreaRadius1 = polygon.signedArea(radius: 1.0)
    let signedAreaRadius3 = polygon.signedArea(radius: 3.0)

    // Then: Should scale with radius squared
    XCTAssertNotNil(signedAreaRadius1, "Signed area calculation should not return nil")
    XCTAssertNotNil(signedAreaRadius3, "Signed area calculation should not return nil")
    XCTAssertEqual(
      signedAreaRadius3!, signedAreaRadius1! * 9.0,
      accuracy: signedAreaAccuracy,
      "Signed area should scale with radius squared"
    )
  }

  /// Test signed area with default radius parameter
  func testSignedArea_WithDefaultRadius_UsesEarthRadius() {
    // Given: A simple triangle
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 1))
    path.add(CLLocationCoordinate2D(latitude: 1, longitude: 0))

    let polygon = GMSPolygon(path: path)

    // When: Calculating signed area with default and explicit radius
    let signedAreaDefault = polygon.signedArea()
    let signedAreaExplicit = polygon.signedArea(radius: kGMSEarthRadius)

    // Then: Should be equal
    XCTAssertNotNil(signedAreaDefault, "Default signed area should not be nil")
    XCTAssertNotNil(signedAreaExplicit, "Explicit signed area should not be nil")
    XCTAssertEqual(
      signedAreaDefault!, signedAreaExplicit!,
      accuracy: signedAreaAccuracy,
      "Default radius should equal explicit Earth radius"
    )
  }
}

// MARK: - Helper Extensions for Testing
private extension Double {
  /// Converts degrees to radians
  var degreesToRadians: Double {
    return self * .pi / 180.0
  }
}

// MARK: - Test Utilities
extension GMSPolygonGeometryUtilsTest {

  /// Helper method to create a simple rectangular polygon for testing
  /// - Parameters:
  ///   - minLat: Minimum latitude
  ///   - maxLat: Maximum latitude
  ///   - minLng: Minimum longitude
  ///   - maxLng: Maximum longitude
  /// - Returns: GMSPolygon representing the rectangle
  private func createRectangularPolygon(
    minLat: Double,
    maxLat: Double,
    minLng: Double,
    maxLng: Double
  ) -> GMSPolygon {
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: minLat, longitude: minLng))
    path.add(CLLocationCoordinate2D(latitude: minLat, longitude: maxLng))
    path.add(CLLocationCoordinate2D(latitude: maxLat, longitude: maxLng))
    path.add(CLLocationCoordinate2D(latitude: maxLat, longitude: minLng))
    return GMSPolygon(path: path)
  }
}
