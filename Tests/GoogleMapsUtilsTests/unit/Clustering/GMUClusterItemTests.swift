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

/// Unit tests for GMUClusterItem protocol and its implementations
///
final class GMUClusterItemTests: XCTestCase {
    
    // MARK: - Test Properties
    /// Test coordinate for San Francisco
    private let testCoordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    
    /// Alternative test coordinate for New York
    private let alternateCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
    
    /// Test title string
    private let testTitle = "Test Location"
    
    /// Test snippet string
    private let testSnippet = "This is a test location"
    
    // MARK: - Default Implementation Tests
    /// Tests that the default implementation of title returns nil
    ///
    /// Given: A basic cluster item that only implements the required position property
    /// When: Accessing the title property
    /// Then: Should return nil (default implementation)
    func test_defaultImplementation_title_returnsNil() {
        // Given
        let clusterItem = BasicClusterItem(position: testCoordinate)
        
        // When
        let title = clusterItem.title
        
        // Then
        XCTAssertNil(title, "Default implementation should return nil for title")
    }
    
    /// Tests that the default implementation of snippet returns nil
    ///
    /// Given: A basic cluster item that only implements the required position property
    /// When: Accessing the snippet property
    /// Then: Should return nil (default implementation)
    func test_defaultImplementation_snippet_returnsNil() {
        // Given
        let clusterItem = BasicClusterItem(position: testCoordinate)
        
        // When
        let snippet = clusterItem.snippet
        
        // Then
        XCTAssertNil(snippet, "Default implementation should return nil for snippet")
    }
    
    /// Tests that the required position property works correctly
    ///
    /// Given: A basic cluster item with a specific position
    /// When: Accessing the position property
    /// Then: Should return the correct coordinate
    func test_defaultImplementation_position_returnsCorrectValue() {
        // Given
        let clusterItem = BasicClusterItem(position: testCoordinate)
        
        // When
        let position = clusterItem.position
        
        // Then
        XCTAssertEqual(position.latitude, testCoordinate.latitude, accuracy: 0.0001,
                      "Position latitude should match the initialized value")
        XCTAssertEqual(position.longitude, testCoordinate.longitude, accuracy: 0.0001,
                      "Position longitude should match the initialized value")
    }
    
    // MARK: - Custom Implementation Tests
    
    /// Tests that conforming types can override the default title implementation
    ///
    /// Given: A custom cluster item that overrides the title property
    /// When: Accessing the title property
    /// Then: Should return the custom title value
    func test_customImplementation_title_returnsCustomValue() {
        // Given
        let clusterItem = CustomClusterItem(position: testCoordinate,
                                          title: testTitle,
                                          snippet: testSnippet)
        
        // When
        let title = clusterItem.title
        
        // Then
        XCTAssertEqual(title, testTitle, "Custom implementation should return the provided title")
    }
    
    /// Tests that conforming types can override the default snippet implementation
    ///
    /// Given: A custom cluster item that overrides the snippet property
    /// When: Accessing the snippet property
    /// Then: Should return the custom snippet value
    func test_customImplementation_snippet_returnsCustomValue() {
        // Given
        let clusterItem = CustomClusterItem(position: testCoordinate,
                                          title: testTitle,
                                          snippet: testSnippet)
        
        // When
        let snippet = clusterItem.snippet
        
        // Then
        XCTAssertEqual(snippet, testSnippet, "Custom implementation should return the provided snippet")
    }

    /// Tests that custom implementations can have nil values for optional properties
    ///
    /// Given: A custom cluster item with nil title and snippet
    /// When: Accessing the optional properties
    /// Then: Should return nil values
    func test_customImplementation_optionalProperties_canBeNil() {
        // Given
        let clusterItem = CustomClusterItem(position: testCoordinate,
                                          title: nil,
                                          snippet: nil)
        
        // When & Then
        XCTAssertNil(clusterItem.title, "Custom implementation should allow nil title")
        XCTAssertNil(clusterItem.snippet, "Custom implementation should allow nil snippet")
    }

    // MARK: - GMSMarker Extension Tests
    /// Tests that GMSMarker conforms to GMUClusterItem protocol
    ///
    /// Given: A GMSMarker instance
    /// When: Treating it as a GMUClusterItem
    /// Then: Should conform to the protocol and provide all required properties
    func test_gmsMarkerExtension_conformsToProtocol() {
        // Given
        let marker = GMSMarker(position: testCoordinate)
        marker.title = testTitle
        marker.snippet = testSnippet
        
        // When
        let clusterItem: GMUClusterItem = marker
        
        // Then
        XCTAssertEqual(clusterItem.position.latitude, testCoordinate.latitude, accuracy: 0.0001,
                      "GMSMarker should provide correct position latitude")
        XCTAssertEqual(clusterItem.position.longitude, testCoordinate.longitude, accuracy: 0.0001,
                      "GMSMarker should provide correct position longitude")
        XCTAssertEqual(clusterItem.title, testTitle, "GMSMarker should provide correct title")
        XCTAssertEqual(clusterItem.snippet, testSnippet, "GMSMarker should provide correct snippet")
    }

    /// Tests that GMSMarker can have nil title and snippet through the protocol
    ///
    /// Given: A GMSMarker with nil title and snippet
    /// When: Accessing properties through GMUClusterItem protocol
    /// Then: Should return nil values
    func test_gmsMarkerExtension_handlesNilValues() {
        // Given
        let marker = GMSMarker(position: testCoordinate)
        // title and snippet are nil by default
        
        // When
        let clusterItem: GMUClusterItem = marker
        
        // Then
        XCTAssertNil(clusterItem.title, "GMSMarker should handle nil title")
        XCTAssertNil(clusterItem.snippet, "GMSMarker should handle nil snippet")
    }

    // MARK: - Protocol Behavior Tests
    
    /// Tests that different implementations can be used interchangeably through the protocol
    ///
    /// Given: Different types conforming to GMUClusterItem
    /// When: Using them through the protocol interface
    /// Then: Should work correctly regardless of the concrete type
    func test_protocolBehavior_differentImplementations_workInterchangeably() {
        // Given
        let basicItem = BasicClusterItem(position: testCoordinate)
        let customItem = CustomClusterItem(position: alternateCoordinate,
                                         title: testTitle,
                                         snippet: testSnippet)
        let markerItem = GMSMarker(position: testCoordinate)
        markerItem.title = testTitle
        
        let items: [GMUClusterItem] = [basicItem, customItem, markerItem]
        
        // When & Then
        for (index, item) in items.enumerated() {
            switch index {
            case 0: // Basic item
                XCTAssertNil(item.title, "Basic item should have nil title")
                XCTAssertNil(item.snippet, "Basic item should have nil snippet")
                XCTAssertEqual(item.position.latitude, testCoordinate.latitude, accuracy: 0.0001)
                
            case 1: // Custom item
                XCTAssertEqual(item.title, testTitle, "Custom item should have custom title")
                XCTAssertEqual(item.snippet, testSnippet, "Custom item should have custom snippet")
                XCTAssertEqual(item.position.latitude, alternateCoordinate.latitude, accuracy: 0.0001)
                
            case 2: // Marker item
                XCTAssertEqual(item.title, testTitle, "Marker item should have set title")
                XCTAssertNil(item.snippet, "Marker item should have nil snippet")
                XCTAssertEqual(item.position.latitude, testCoordinate.latitude, accuracy: 0.0001)
                
            default:
                XCTFail("Unexpected item index")
            }
        }
    }
    
    /// Tests that the protocol enforces AnyObject constraint
    ///
    /// This test ensures that only reference types can conform to GMUClusterItem
    /// Note: This is more of a compile-time test, but we include it for completeness
    func test_protocolBehavior_anyObjectConstraint_enforcesReferenceTypes() {
        // Given
        let clusterItem = BasicClusterItem(position: testCoordinate)
        
        // When
        let clusterItemRef: AnyObject = clusterItem
        
        // Then
        XCTAssertTrue(clusterItemRef is GMUClusterItem,
                     "GMUClusterItem should be a reference type (AnyObject)")
    }
}

// MARK: - Test Helper Classes
/// Basic cluster item that only implements the required position property
/// Used to test default implementations
private final class BasicClusterItem: GMUClusterItem {
    let position: CLLocationCoordinate2D
    
    init(position: CLLocationCoordinate2D) {
        self.position = position
    }
}

/// Custom cluster item that overrides all properties
/// Used to test custom implementations
private final class CustomClusterItem: GMUClusterItem {
    let position: CLLocationCoordinate2D
    let title: String?
    let snippet: String?
    
    init(position: CLLocationCoordinate2D, title: String?, snippet: String?) {
        self.position = position
        self.title = title
        self.snippet = snippet
    }
}

