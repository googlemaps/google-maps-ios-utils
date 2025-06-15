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
import GoogleMaps

@testable import GoogleMapsUtils

class GMUClusterManagerTests: XCTestCase {

    // MARK: - Properties
    var mapView: MockGMSMapView!
    var camera: GMSCameraPosition!
    var algorithm: MockClusterAlgorithm!
    var renderer: MockClusterRenderer!
    var clusterManager: GMUClusterManager!
    var delegate: MockClusterManagerDelegate!
    var mapDelegate: MockMapDelegate!
    private let kCameraPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(-35), longitude: CLLocationDegrees(151))
    private let kCameraZoom: Float = 1.0

    // MARK: - Setup()
    override func setUp() {
        super.setUp()
        GMSServices.provideAPIKey("MOCK_API_KEY")
        mapView = MockGMSMapView()
        camera = GMSCameraPosition(target: kCameraPosition, zoom: kCameraZoom)
        mapView.mockCamera = camera
        algorithm = MockClusterAlgorithm()
        renderer = MockClusterRenderer()
        delegate = MockClusterManagerDelegate()
        mapDelegate = MockMapDelegate()
        clusterManager = GMUClusterManager(mapView: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager.setDelegate(delegate, mapDelegate: mapDelegate)
    }

    // MARK: - Teardown
    override func tearDown() {
        algorithm = nil
        renderer = nil
        delegate = nil
        mapDelegate = nil
        clusterManager = nil
        mapView = nil
        super.tearDown()
    }

    // MARK: - Tests
    func testInitMapDelegateNotHookedByDefault() {
        // Act.
        clusterManager = GMUClusterManager(mapView: mapView, algorithm: algorithm, renderer: renderer)
        // Assert
        XCTAssertNil(mapView.delegate, "MapView delegate should not be set by default")
    }

    func testInit() {
        // Assert
        XCTAssertEqual(clusterManager.algorithm as? MockClusterAlgorithm, algorithm)
        XCTAssertEqual(clusterManager.delegate as? MockClusterManagerDelegate, delegate)
        XCTAssertEqual(clusterManager.mapDelegate as? MockMapDelegate, mapDelegate)
    }

    func testAddItem() {
        // Arrange.
        let item1 = MockGMUClusterItem(position: kCameraPosition)
        algorithm.addItems([item1])
        // Act.
        clusterManager.addItem(item1)
    }

    func testAddItems() {
        // Arrange.
        let item1 = MockGMUClusterItem(position: kCameraPosition)
        let item2 = MockGMUClusterItem(position: CLLocationCoordinate2D(latitude: 1, longitude: 1))
        algorithm.addItems([item1, item2])
        // Act.
        clusterManager.addItems([item1, item2])
    }

    func testRemoveItem() {
        // Arrange.
        let item1 = MockGMUClusterItem(position: kCameraPosition)
        algorithm.removeItem(item1)
        clusterManager.addItem(item1)
        // Act.
        clusterManager.removeItem(item1)
    }

    func testClearItems() {
        // Arrange.
        let item1 = MockGMUClusterItem(position: kCameraPosition)
        let item2 = MockGMUClusterItem(position: CLLocationCoordinate2D(latitude: 1, longitude: 1))
        algorithm.clearItems()
        clusterManager.addItems([item1, item2])
        // Act.
        let requestCount = clusterManager.currentClusterRequestCount
        clusterManager.clearItems()
        // Assert
        XCTAssertEqual(clusterManager.currentClusterRequestCount, requestCount + 1)
    }

    func testCluster() {
        // Arrange.
        let clusters = [MockCluster(position: kCameraPosition, items: [])]
        _ = algorithm.clusters(atZoom: kCameraZoom)
        renderer.renderClusters(clusters)
        // Act.
        clusterManager.cluster()
    }

    func testCameraChangedReclusterRequested() {
        // Arrange.
        let clusters = [MockCluster(position: kCameraPosition, items: [])]
        _ = algorithm.clusters(atZoom: kCameraZoom)
        renderer.renderClusters(clusters)
        // Intial cluster.
        clusterManager.cluster()
        // Act.
        mapView.mockCamera = GMSCameraPosition(target: kCameraPosition, zoom: kCameraZoom + 2)
        clusterManager.observeValue(forKeyPath: "camera", of: mapView, change: nil, context: nil)
        // Assert
        XCTAssertEqual(clusterManager.currentClusterRequestCount, 1)
    }
    
    func testCameraChangedALittleReclusterNotRequested() {
        // Arrange.
        let clusters = [MockCluster(position: kCameraPosition, items: [])]
        _ = algorithm.clusters(atZoom: kCameraZoom)
        renderer.renderClusters(clusters)
        // Intial cluster.
        clusterManager.cluster()
        // Act.
        mapView.mockCamera = GMSCameraPosition(target: kCameraPosition, zoom: kCameraZoom + 0.3)
        clusterManager.observeValue(forKeyPath: "camera", of: mapView, change: nil, context: nil)
        // Assert
        XCTAssertEqual(clusterManager.currentClusterRequestCount, 0)
    }
    
    func testTapOnClusterMarkerEventRaised() {
        // Arrange.
        let cluster1 = MockCluster(position: kCameraPosition, items: [])
        let item1 = MockGMUClusterItem(position: kCameraPosition)
        let marker = GMSMarker()
        marker.map = mapView
        marker.userData = cluster1
        // Expect and reject.
        _ = delegate.clusterManager(clusterManager, didTapCluster: cluster1)
        _ = delegate.clusterManager(clusterManager, didTapClusterItem: item1)
        // Act.
        _ = clusterManager.mapView(mapView, didTap: marker)
        // Assert
        XCTAssertTrue(mapDelegate.didTapMarkerCalled, "Expected mapView(_:didTap:) to be called on the map delegate")
    }

    func testTapOnClusterItemMarkerNoDelegateEventRaisedOnMapDelegate() {
        // Arrange.
        let cluster1 = MockCluster(position: kCameraPosition, items: [])
        let item1 = MockGMUClusterItem(position: kCameraPosition)
        let marker = GMSMarker()
        marker.map = mapView
        marker.userData = item1
        // Expect and reject.
        _ = delegate.clusterManager(clusterManager, didTapCluster: cluster1)
        _ = delegate.clusterManager(clusterManager, didTapClusterItem: item1)
        // Act.
        _ = clusterManager.mapView(mapView, didTap: marker)
        // Assert
        XCTAssertTrue(mapDelegate.didTapMarkerCalled, "Expected mapView(_:didTap:) to be called on the map delegate")
    }
    
        
    func testTapOnClusterItemMarkerDelegateReturnsNoEventRaisedOnMapDelegate() {
        // Arrange.
        let item1 = MockGMUClusterItem(position: kCameraPosition)
        let marker = GMSMarker()
        marker.map = mapView
        marker.userData = item1
        clusterManager.setDelegate(delegate, mapDelegate: mapDelegate)
        
        // Act.
        _ = clusterManager.mapView(mapView, didTap: marker)
        // Assert
        XCTAssertFalse(delegate.clusterManager(clusterManager, didTapClusterItem: item1),
                       "Expected clusterManager(_:didTapClusterItem:) to return false")
        XCTAssertTrue(mapDelegate.didTapMarkerCalled,
                      "Expected mapView(_:didTap:) to be called on map delegate")
    }

    func testTapOnClusterMarkerDelegateReturnsNoEventRaisedOnMapDelegate() {
        // Arrange.
        let cluster1 = MockCluster(position: kCameraPosition, items: [])
        let marker = GMSMarker()
        marker.map = mapView
        marker.userData = cluster1
        clusterManager.setDelegate(delegate, mapDelegate: mapDelegate)
        // Act.
        _ = clusterManager.mapView(mapView, didTap: marker)
        // Assert
        XCTAssertFalse(delegate.clusterManager(clusterManager, didTapCluster: cluster1),
                       "Expected clusterManager(_:didTapCluster:) to return false")
        XCTAssertTrue(mapDelegate.didTapMarkerCalled,
                      "Expected mapView(_:didTap:) to be called on map delegate")
    }
    
    func testSetMapDelegate() {
        // Arrange.
        let clusterManager = GMUClusterManager(mapView: mapView,
                                               algorithm: MockClusterAlgorithm(),
                                               renderer: MockClusterRenderer())
        let mockMapDelegate = MockMapDelegate()
        // Act
        clusterManager.setMapDelegate(mockMapDelegate)
        // Assert
        XCTAssertTrue(mapView.delegate === clusterManager, "Expected mapView's delegate to be set to clusterManager")
        XCTAssertTrue(clusterManager.mapDelegate === mockMapDelegate, "Expected mapDelegate to be stored correctly")
    }
    
    func testTapOnNormalMarkerEventRaisedOnMapDelegate() {
        // Arrange.
        let mapDelegate = MockMapDelegate()
        let marker = GMSMarker()
        marker.map = mapView
        // Act
        clusterManager.setDelegate(nil, mapDelegate: mapDelegate)
        _ = clusterManager.mapView(mapView, didTap: marker)
        // Assert
        XCTAssertTrue(mapDelegate.didTapMarkerCalled,
                      "Expected mapView(_:didTap:) to be called on map delegate")
    }
    
    func testMapViewDidTapOverlay() {
        // Arrange.
        let mockMapDelegate = MockMapDelegate()
        let overlay = GMSCircle(position: kCameraPosition, radius: 100)
        // Act
        clusterManager.setMapDelegate(mockMapDelegate)
        clusterManager.mapView(mapView, didTap: overlay)
        // Assert
        XCTAssertTrue(mockMapDelegate.didTapOverlayCalled, "Expected mapView(_:didTap:) to be forwarded to the map delegate")
    }

    func testMapEventsForwardedToMapDelegate() {
        // Arrange.
        let mapDelegate = MockMapDelegate()
        let marker = GMSMarker()
        let cameraPosition = GMSCameraPosition.camera(withTarget: kCameraPosition, zoom: 10)
        
        // Act
        clusterManager.setDelegate(nil, mapDelegate: mapDelegate)
        clusterManager.mapView(mapView, willMove: true)
        clusterManager.mapView(mapView, didChange: cameraPosition)
        clusterManager.mapView(mapView, idleAt: cameraPosition)
        clusterManager.mapView(mapView, didTapAt: kCameraPosition)
        clusterManager.mapView(mapView, didLongPressAt: kCameraPosition)
        clusterManager.mapView(mapView, didTapInfoWindowOf: marker)
        clusterManager.mapView(mapView, didLongPressInfoWindowOf: marker)
        _ = clusterManager.mapView(mapView, didTap: marker)
        _ = clusterManager.mapView(mapView, markerInfoWindow: marker)
        _ = clusterManager.mapView(mapView, markerInfoContents: marker)
        clusterManager.mapView(mapView, didCloseInfoWindowOf: marker)
        clusterManager.mapView(mapView, didBeginDragging: marker)
        clusterManager.mapView(mapView, didDrag: marker)
        clusterManager.mapView(mapView, didEndDragging: marker)
        clusterManager.mapView(mapView, didTapPOIWithPlaceID: "", name: "", location: kCameraPosition)
        _ = clusterManager.didTapMyLocationButton(for: mapView)
        clusterManager.mapViewDidStartTileRendering(mapView)
        clusterManager.mapViewDidFinishTileRendering(mapView)
        // Assert
        XCTAssertTrue(mapDelegate.didTapMarkerCalled, "Expected various map events to be forwarded to the map delegate")
    }

}
