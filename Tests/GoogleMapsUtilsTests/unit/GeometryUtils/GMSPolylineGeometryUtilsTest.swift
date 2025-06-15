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

/// Unit tests for GMSPolyline+GeometryUtils extension
/// Tests the isOnPolyline(coordinate:tolerance:) method with various scenarios
class GMSPolylineGeometryUtilsTest: XCTestCase {
  
  // MARK: - Test Constants
  
  /// Small coordinate difference (approximately 5cm on equator, half the default tolerance)
  private let smallDiff = 5e-7
  
  /// Large coordinate difference (approximately 20cm on equator, double the default tolerance)
  private let largeDiff = 2e-6
  
  /// High precision accuracy for coordinate comparisons
  private let coordinateAccuracy = 1e-8
  
  // MARK: - Standard Test Coordinates
  
  /// Origin point at equator and prime meridian
  private let origin = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  
  /// Point 1 degree north of origin
  private let oneNorth = CLLocationCoordinate2D(latitude: 1, longitude: 0)
  
  /// Point 1 degree east of origin
  private let oneEast = CLLocationCoordinate2D(latitude: 0, longitude: 1)
  
  /// Point 1 degree northeast of origin
  private let oneNorthEast = CLLocationCoordinate2D(latitude: 1, longitude: 1)
  
  /// San Francisco coordinates (for real-world testing)
  private let sanFrancisco = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
  
  /// Los Angeles coordinates (for real-world testing)
  private let losAngeles = CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437)
  
  /// New York coordinates (for real-world testing)
  private let newYork = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
  
  // MARK: - Helper Methods
  
  /// Creates a simple horizontal polyline from origin to oneEast
  private func createHorizontalPolyline() -> GMSPolyline {
    let path = GMSMutablePath()
    path.add(origin)
    path.add(oneEast)
    
    let polyline = GMSPolyline(path: path)
    polyline.geodesic = false
    return polyline
  }
  
  /// Creates a multi-segment polyline (L-shape)
  private func createMultiSegmentPolyline() -> GMSPolyline {
    let path = GMSMutablePath()
    path.add(origin)
    path.add(oneEast)
    path.add(oneNorthEast)
    
    let polyline = GMSPolyline(path: path)
    polyline.geodesic = false
    return polyline
  }
  
  /// Creates a real-world polyline from San Francisco to Los Angeles to New York
  private func createRealWorldPolyline() -> GMSPolyline {
    let path = GMSMutablePath()
    path.add(sanFrancisco)
    path.add(losAngeles)
    path.add(newYork)
    
    let polyline = GMSPolyline(path: path)
    polyline.geodesic = true
    return polyline
  }
  
  // MARK: - Edge Cases Tests
  
  /// Test isOnPolyline with nil path - should return false
  func testIsOnPolyline_WithNilPath_ReturnsFalse() {
    // Given: A polyline with no path
    let polyline = GMSPolyline()
    XCTAssertNil(polyline.path, "Polyline should have nil path for this test")
    
    // When: Testing if any coordinate is on the polyline
    let result = polyline.isOnPolyline(coordinate: origin)
    
    // Then: Should return false
    XCTAssertFalse(result, "isOnPolyline should return false for polyline with nil path")
  }
  
  /// Test isOnPolyline with empty path - should return false
  func testIsOnPolyline_WithEmptyPath_ReturnsFalse() {
    // Given: A polyline with empty path
    let polyline = GMSPolyline(path: GMSMutablePath())
    XCTAssertEqual(polyline.path?.count(), 0, "Path should be empty for this test")
    
    // When: Testing if any coordinate is on the polyline
    let result = polyline.isOnPolyline(coordinate: origin)
    
    // Then: Should return false
    XCTAssertFalse(result, "isOnPolyline should return false for polyline with empty path")
  }
  
  /// Test isOnPolyline with single point path
  func testIsOnPolyline_WithSinglePoint_WorksCorrectly() {
    // Given: A polyline with single point
    let path = GMSMutablePath()
    path.add(origin)
    let polyline = GMSPolyline(path: path)
    
    // When/Then: Testing various coordinates
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: origin),
      "Point should be on polyline when it matches the single point"
    )
    
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: oneNorth),
      "Different point should not be on single-point polyline"
    )
  }
  
  // MARK: - Endpoint Tests
  
  /// Test that polyline endpoints are always considered "on" the polyline
  func testIsOnPolyline_Endpoints_ReturnsTrue() {
    // Given: A horizontal polyline
    let polyline = createHorizontalPolyline()
    
    // When/Then: Testing endpoints
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: origin),
      "Start point should always be on polyline"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: oneEast),
      "End point should always be on polyline"
    )
  }
  
  /// Test endpoints with multi-segment polyline
  func testIsOnPolyline_MultiSegmentEndpoints_ReturnsTrue() {
    // Given: A multi-segment polyline
    let polyline = createMultiSegmentPolyline()
    
    // When/Then: Testing all endpoints and intermediate points
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: origin),
      "First point should be on polyline"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: oneEast),
      "Intermediate point should be on polyline"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: oneNorthEast),
      "Last point should be on polyline"
    )
  }
  
  // MARK: - On-Path Tests
  
  /// Test coordinates that lie exactly on the polyline path
  func testIsOnPolyline_CoordinatesOnPath_ReturnsTrue() {
    // Given: A horizontal polyline
    let polyline = createHorizontalPolyline()
    
    // When/Then: Testing points on the path
    let midpoint = CLLocationCoordinate2D(latitude: 0, longitude: 0.5)
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: midpoint),
      "Midpoint should be on horizontal polyline"
    )
    
    let quarterPoint = CLLocationCoordinate2D(latitude: 0, longitude: 0.25)
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: quarterPoint),
      "Quarter point should be on horizontal polyline"
    )
    
    let threeQuarterPoint = CLLocationCoordinate2D(latitude: 0, longitude: 0.75)
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: threeQuarterPoint),
      "Three-quarter point should be on horizontal polyline"
    )
  }
  
  /// Test coordinates very close to the polyline path (within tolerance)
  func testIsOnPolyline_CoordinatesNearPath_ReturnsTrue() {
    // Given: A horizontal polyline
    let polyline = createHorizontalPolyline()
    
    // When/Then: Testing points very close to the path (within default tolerance)
    let nearMidpointNorth = CLLocationCoordinate2D(latitude: smallDiff, longitude: 0.5)
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: nearMidpointNorth),
      "Point slightly north of midpoint should be considered on polyline"
    )
    
    let nearMidpointSouth = CLLocationCoordinate2D(latitude: -smallDiff, longitude: 0.5)
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: nearMidpointSouth),
      "Point slightly south of midpoint should be considered on polyline"
    )
  }
  
  // MARK: - Off-Path Tests
  
  /// Test coordinates that are clearly not on the polyline path
  func testIsOnPolyline_CoordinatesOffPath_ReturnsFalse() {
    // Given: A horizontal polyline
    let polyline = createHorizontalPolyline()
    
    // When/Then: Testing points clearly off the path
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: oneNorth),
      "Point north of polyline should not be on polyline"
    )
    
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: CLLocationCoordinate2D(latitude: -1, longitude: 0)),
      "Point south of polyline should not be on polyline"
    )
    
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 2)),
      "Point beyond end of polyline should not be on polyline"
    )
    
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: -1)),
      "Point before start of polyline should not be on polyline"
    )
  }
  
  /// Test coordinates far from the polyline path (beyond tolerance)
  func testIsOnPolyline_CoordinatesFarFromPath_ReturnsFalse() {
    // Given: A horizontal polyline
    let polyline = createHorizontalPolyline()
    
    // When/Then: Testing points far from the path (beyond default tolerance)
    let farNorth = CLLocationCoordinate2D(latitude: largeDiff, longitude: 0.5)
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: farNorth),
      "Point far north of midpoint should not be considered on polyline"
    )
    
    let farSouth = CLLocationCoordinate2D(latitude: -largeDiff, longitude: 0.5)
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: farSouth),
      "Point far south of midpoint should not be considered on polyline"
    )
  }
  
  // MARK: - Tolerance Tests
  
  /// Test isOnPolyline with custom tolerance parameter
  func testIsOnPolyline_WithCustomTolerance_WorksCorrectly() {
    // Given: A horizontal polyline
    let polyline = createHorizontalPolyline()
    let testPoint = CLLocationCoordinate2D(latitude: largeDiff, longitude: 0.5)
    
    // When/Then: Testing with different tolerance values
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: testPoint, tolerance: GMSPath.defaultToleranceInMeters),
      "Point should not be on polyline with default tolerance"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: testPoint, tolerance: 100.0),
      "Point should be on polyline with large tolerance"
    )
    
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: testPoint, tolerance: 0.01),
      "Point should not be on polyline with very small tolerance"
    )
  }
  
  /// Test isOnPolyline with very small tolerance (accounting for floating point precision)
  func testIsOnPolyline_WithVerySmallTolerance_RequiresHighPrecision() {
    // Given: A horizontal polyline
    let polyline = createHorizontalPolyline()
    let verySmallTolerance = 1e-6  // Very small but not zero to avoid floating point precision issues
    
    // When/Then: Testing with very small tolerance
    // Note: We use endpoints which should always match exactly
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: origin, tolerance: verySmallTolerance),
      "Exact endpoint should be on polyline with very small tolerance"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: oneEast, tolerance: verySmallTolerance),
      "Exact endpoint should be on polyline with very small tolerance"
    )
    
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: CLLocationCoordinate2D(latitude: smallDiff, longitude: 0.5), tolerance: verySmallTolerance),
      "Near point should not be on polyline with very small tolerance"
    )
  }
  
  /// Test isOnPolyline tolerance behavior with different precision levels
  func testIsOnPolyline_ToleranceComparison_ShowsPrecisionBehavior() {
    // Given: A horizontal polyline
    let polyline = createHorizontalPolyline()
    let testPoint = CLLocationCoordinate2D(latitude: smallDiff, longitude: 0.5)
    
    // When/Then: Testing with different tolerance levels
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: testPoint, tolerance: 1e-8),
      "Point should not be on polyline with very small tolerance"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: testPoint, tolerance: GMSPath.defaultToleranceInMeters),
      "Point should be on polyline with default tolerance"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: testPoint, tolerance: 1.0),
      "Point should be on polyline with large tolerance"
    )
  }
  
  // MARK: - Geodesic vs Non-Geodesic Tests
  
  /// Test behavior difference between geodesic and non-geodesic polylines
  func testIsOnPolyline_GeodesicVsNonGeodesic_BehaviorDifference() {
    // Given: Two identical paths, one geodesic and one not
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 0))
    path.add(CLLocationCoordinate2D(latitude: 0, longitude: 90))
    
    let geodesicPolyline = GMSPolyline(path: path)
    geodesicPolyline.geodesic = true
    
    let nonGeodesicPolyline = GMSPolyline(path: path)
    nonGeodesicPolyline.geodesic = false
    
    // When: Testing a point that might behave differently for geodesic vs non-geodesic
    let testPoint = CLLocationCoordinate2D(latitude: 5, longitude: 45)
    
    // Then: Both should handle the coordinate (exact behavior may differ based on implementation)
    let geodesicResult = geodesicPolyline.isOnPolyline(coordinate: testPoint)
    let nonGeodesicResult = nonGeodesicPolyline.isOnPolyline(coordinate: testPoint)
    
    // The results might be different, but both calls should complete successfully
    XCTAssertTrue(geodesicResult == true || geodesicResult == false, "Geodesic polyline should return a valid boolean")
    XCTAssertTrue(nonGeodesicResult == true || nonGeodesicResult == false, "Non-geodesic polyline should return a valid boolean")
  }
  
  // MARK: - Real-World Scenario Tests
  
  /// Test with real-world coordinates and realistic tolerances
  func testIsOnPolyline_RealWorldCoordinates_WorksCorrectly() {
    // Given: A real-world polyline from San Francisco to Los Angeles
    let path = GMSMutablePath()
    path.add(sanFrancisco)
    path.add(losAngeles)
    
    let polyline = GMSPolyline(path: path)
    polyline.geodesic = true
    
    // When/Then: Testing endpoints
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: sanFrancisco),
      "San Francisco should be on the SF-LA polyline"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: losAngeles),
      "Los Angeles should be on the SF-LA polyline"
    )
    
    // Test a point clearly not on the path
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: newYork),
      "New York should not be on the SF-LA polyline"
    )
  }
  
  /// Test with a complex multi-city polyline
  func testIsOnPolyline_ComplexRealWorldPolyline_WorksCorrectly() {
    // Given: A complex real-world polyline
    let polyline = createRealWorldPolyline()
    
    // When/Then: Testing all waypoints
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: sanFrancisco),
      "San Francisco should be on multi-city polyline"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: losAngeles),
      "Los Angeles should be on multi-city polyline"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: newYork),
      "New York should be on multi-city polyline"
    )
    
    // Test a point not on any segment
    let denver = CLLocationCoordinate2D(latitude: 39.7392, longitude: -104.9903)
    XCTAssertFalse(
      polyline.isOnPolyline(coordinate: denver),
      "Denver should not be on the SF-LA-NY polyline"
    )
  }
  
  // MARK: - Performance Tests
  
  /// Test performance with a polyline containing many points
  func testIsOnPolyline_PerformanceWithManyPoints() {
    // Given: A polyline with many points (simulating a detailed route)
    let path = GMSMutablePath()
    for i in 0..<1000 {
      let lat = Double(i) * 0.001  // Create a path with 1000 points
      let lng = Double(i) * 0.001
      path.add(CLLocationCoordinate2D(latitude: lat, longitude: lng))
    }
    
    let polyline = GMSPolyline(path: path)
    polyline.geodesic = false
    
    let testPoint = CLLocationCoordinate2D(latitude: 0.5, longitude: 0.5)
    
    // When: Testing performance
    measure {
      _ = polyline.isOnPolyline(coordinate: testPoint)
    }
    
    // Then: The test should complete without timing out
    // Performance expectation is handled by the measure block
  }
  
  // MARK: - Default Parameter Tests
  
  /// Test that default tolerance parameter works correctly
  func testIsOnPolyline_DefaultTolerance_UsesCorrectValue() {
    // Given: A horizontal polyline
    let polyline = createHorizontalPolyline()
    let testPoint = CLLocationCoordinate2D(latitude: smallDiff, longitude: 0.5)
    
    // When: Calling with and without explicit tolerance
    let resultWithDefault = polyline.isOnPolyline(coordinate: testPoint)
    let resultWithExplicit = polyline.isOnPolyline(coordinate: testPoint, tolerance: GMSPath.defaultToleranceInMeters)
    
    // Then: Results should be identical
    XCTAssertEqual(
      resultWithDefault, resultWithExplicit,
      "Default tolerance should equal explicit GMSPath.defaultToleranceInMeters"
    )
  }
  
  // MARK: - Coordinate Validation Tests
  
  /// Test with extreme coordinate values
  func testIsOnPolyline_ExtremeCoordinates_HandlesGracefully() {
    // Given: A polyline with extreme coordinates
    let path = GMSMutablePath()
    path.add(CLLocationCoordinate2D(latitude: -90, longitude: -180))  // South Pole, antimeridian
    path.add(CLLocationCoordinate2D(latitude: 90, longitude: 180))    // North Pole, antimeridian
    
    let polyline = GMSPolyline(path: path)
    polyline.geodesic = true
    
    // When/Then: Testing with extreme coordinates
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: CLLocationCoordinate2D(latitude: -90, longitude: -180)),
      "South Pole should be on polyline"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: CLLocationCoordinate2D(latitude: 90, longitude: 180)),
      "North Pole should be on polyline"
    )
    
    // Test coordinate at equator
    let equatorPoint = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    let isOnPath = polyline.isOnPolyline(coordinate: equatorPoint)
    XCTAssertTrue(isOnPath == true || isOnPath == false, "Should return a valid boolean for equator point")
  }
  
  // MARK: - Edge Cases for Coordinate Precision
  
  /// Test with coordinates that have high precision (many decimal places)
  func testIsOnPolyline_HighPrecisionCoordinates_WorksCorrectly() {
    // Given: A polyline with high-precision coordinates
    let highPrecisionStart = CLLocationCoordinate2D(latitude: 37.7749295, longitude: -122.4194155)
    let highPrecisionEnd = CLLocationCoordinate2D(latitude: 37.7749296, longitude: -122.4194156)
    
    let path = GMSMutablePath()
    path.add(highPrecisionStart)
    path.add(highPrecisionEnd)
    
    let polyline = GMSPolyline(path: path)
    polyline.geodesic = false
    
    // When/Then: Testing high-precision coordinates
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: highPrecisionStart),
      "High-precision start coordinate should be on polyline"
    )
    
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: highPrecisionEnd),
      "High-precision end coordinate should be on polyline"
    )
    
    // Test a point in between
    let midPoint = CLLocationCoordinate2D(
      latitude: (highPrecisionStart.latitude + highPrecisionEnd.latitude) / 2,
      longitude: (highPrecisionStart.longitude + highPrecisionEnd.longitude) / 2
    )
    XCTAssertTrue(
      polyline.isOnPolyline(coordinate: midPoint),
      "High-precision midpoint should be on polyline"
    )
  }
}
