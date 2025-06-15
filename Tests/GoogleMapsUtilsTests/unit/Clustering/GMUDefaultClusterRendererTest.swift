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

class GMUDefaultClusterRendererTest: XCTestCase {

    // MARK: - Properties
    // Object under test.
    private var renderer: GMUDefaultClusterRenderer!
    var mapView: MockGMSMapView!
    var camera: GMSCameraPosition!
    var projection: MockGMSProjection!
    var iconGenerator: GMUClusterIconGenerator!
    private let kCameraPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(-35), longitude: CLLocationDegrees(151))
    private let kCameraZoom: Float = 1.0

    // MARK: - Set Up
    override func setUp() {
        super.setUp()
        GMSServices.provideAPIKey("MOCK_API_KEY")
        mapView = MockGMSMapView()
        camera = GMSCameraPosition(target: kCameraPosition, zoom: kCameraZoom)
        mapView.mockCamera = camera

        // Stub out projection property.
        projection = MockGMSProjection()
        let nearLeft = CLLocationCoordinate2D(latitude: kCameraPosition.latitude - 10,
                                              longitude: kCameraPosition.longitude - 10)
        let nearRight = CLLocationCoordinate2D(latitude: kCameraPosition.latitude - 10,
                                               longitude: kCameraPosition.longitude + 10)
        let farLeft = CLLocationCoordinate2D(latitude: kCameraPosition.latitude + 10,
                                             longitude: kCameraPosition.longitude - 10)
        let farRight = CLLocationCoordinate2D(latitude: kCameraPosition.latitude + 10,
                                              longitude: kCameraPosition.longitude + 10)
        
        let visibleRegion = GMSVisibleRegion(nearLeft: nearLeft,
                                             nearRight: nearRight,
                                             farLeft: farLeft,
                                             farRight: farRight)
        projection.mockVisibleRegion = visibleRegion
        mapView.mockProjection = projection

        iconGenerator = MockClusterIconGenerator()
        renderer = GMUDefaultClusterRenderer(
            mapView: mapView,
            clusterIconGenerator: iconGenerator)
        renderer.animatesClusters = false
    }

    // MARK: - Teardown
    override func tearDown() {
        mapView = nil
        renderer = nil
        projection = nil
        iconGenerator = nil
        super.tearDown()
    }

    // MARK: - Tests
    /// Large clusters should be rendered as 1 marker and not expanded.
    func testRenderClustersLargeClustersNotExpanded() {
        // Arrange.
        var clusters: [GMUCluster] = []
        let cluster1 = clusterAroundPosition(kCameraPosition, count: 10)
        clusters.append(cluster1)

        let cluster2 = clusterAroundPosition(
            CLLocationCoordinate2DMake(
                kCameraPosition.latitude + 1.0,
                kCameraPosition.longitude),
            count: 4)
        clusters.append(cluster2)

        // Act.
        renderer.renderClusters(clusters)

        // Assert.
        let markers = renderer.currentActivemarkers
        XCTAssertEqual(markers.count, 2)
        XCTAssertTrue(markers[0].userData is GMUCluster)
        XCTAssertEqual(markers[0].map, mapView)

        XCTAssertTrue(markers[1].userData is GMUCluster)
        XCTAssertEqual(markers[1].map, mapView)
    }

    func testRenderClustersWithAnimationAndClearingAllMarkers() {
        // Arrange.
        var clusters: [GMUCluster] = []
        let cluster1 = clusterAroundPosition(kCameraPosition, count: 10)
        clusters.append(cluster1)

        let cluster2 = clusterAroundPosition(
            CLLocationCoordinate2DMake(
                kCameraPosition.latitude + 1.0,
                kCameraPosition.longitude),
            count: 4)
        clusters.append(cluster2)

        // Act.
        renderer.animatesClusters = true
        renderer.renderClusters(clusters)
        renderer.update()

        // Assert.
        let markers = renderer.currentActivemarkers
        markers[0].position = CLLocationCoordinate2DMake(kCameraPosition.latitude + 20.0, kCameraPosition.longitude + 20.0)
        renderer.clearMarkersAnimated(markers)
        XCTAssertEqual(2, markers.count)
    }

    func testVisibleClustersFromClustersWithClustersArray() {
        // Arrange.
        var clusters: [GMUCluster] = []
        let cluster1 = clusterAroundPosition(kCameraPosition, count: 10)
        clusters.append(cluster1)

        let cluster2 = clusterAroundPosition(
            CLLocationCoordinate2DMake(
                kCameraPosition.latitude + 1.0,
                kCameraPosition.longitude),
            count: 4)
        clusters.append(cluster2)

        // Act.
        guard let clustersValue: [GMUCluster] = renderer.visibleClusters(from: clusters) else {
            XCTFail("visibleClusters(from:) returned nil")
            return
        }

        // Assert.
        XCTAssertEqual(clusters.count, clustersValue.count, "Cluster count mismatch")

        for (expected, actual) in zip(clusters, clustersValue) {
            XCTAssertEqual(expected.position.latitude, actual.position.latitude, accuracy: 0.0001, "Latitude mismatch")
            XCTAssertEqual(expected.position.longitude, actual.position.longitude, accuracy: 0.0001, "Longitude mismatch")
            XCTAssertEqual(expected.count, actual.count, "Cluster count mismatch")
            
            // Optionally compare cluster items
            XCTAssertEqual(expected.items.count, actual.items.count, "Cluster items count mismatch")
        }
    }
    
    func testAddingClusterItemsWithTitleAndSnippet() {
        var clusters: [GMUCluster] = []
        let cluster = clusterAroundPosition(kCameraPosition, count: 1, title: "Title", snippet: "Snippet")
        clusters.append(cluster)

        renderer.renderClusters(clusters)
        let markers = renderer.currentActivemarkers
        XCTAssertEqual(1, markers.count)

        let marker = markers[0]
        XCTAssertTrue(marker.userData is GMUClusterItem)
        XCTAssertEqual(mapView, marker.map)
        XCTAssertEqual("Title", marker.title)
        XCTAssertEqual("Snippet", marker.snippet)
    }

    /// Small clusters should be expanded into markers (one per cluster item).
    func testRenderClustersSmallClustersExpanded() {
        // Arrange.
        var clusters: [GMUCluster] = []
        let cluster1 = clusterAroundPosition(kCameraPosition, count: 3)
        clusters.append(cluster1)

        // Act.
        renderer.renderClusters(clusters)

        // Assert.
        let markers = renderer.currentActivemarkers
        XCTAssertEqual(markers.count, 3)
        XCTAssertTrue(markers[0].userData is GMUClusterItem)
        XCTAssertEqual(markers[0].map, mapView)

        XCTAssertTrue(markers[1].userData is GMUClusterItem)
        XCTAssertEqual(markers[1].map, mapView)

        XCTAssertTrue(markers[2].userData is GMUClusterItem)
        XCTAssertEqual(markers[2].map, mapView)
    }

    /// Clusters outside the camera's visible region should not be rendered.
    func testRenderClustersInvisibleClustersNotRendered() {
        // Arrange.
        var clusters: [GMUCluster] = []
        let cluster1 = clusterAroundPosition(kCameraPosition, count: 10)
        clusters.append(cluster1)

        // Outside cluster.
        let cluster2 = clusterAroundPosition(
            CLLocationCoordinate2DMake(
                kCameraPosition.latitude + 20.0,
                kCameraPosition.longitude + 20.0),
            count: 10)
        clusters.append(cluster2)

        // Act.
        renderer.renderClusters(clusters)

        // Assert.
        let markers = renderer.currentActivemarkers
        XCTAssertEqual(markers.count, 1)
        XCTAssertEqual(markers[0].map, mapView)
        // XCTAssertEqual(markers[0].userData, cluster1) // Only cluster1 is rendered
    }

    /// Clusters outside the camera's visible region should not be rendered.
    func testRenderClustersPreviousMarkersRemovedFromMap() {
        // Arrange.
        var clusters: [GMUCluster] = []
        let cluster1 = clusterAroundPosition(kCameraPosition, count: 10)
        clusters.append(cluster1)

        // Initial render.
        renderer.renderClusters(clusters)
        let previousMarkers = renderer.currentActivemarkers
        XCTAssertEqual(previousMarkers.count, 1)
        XCTAssertEqual(previousMarkers[0].map, mapView)

        // Act: renderClusters again.
        renderer.renderClusters(clusters)

        // Assert.
        let markers = renderer.currentActivemarkers
        XCTAssertEqual(markers.count, 1)
        XCTAssertEqual(markers[0].map, mapView)

        // Assert previous marker removed from map.
        XCTAssertNil(previousMarkers[0].map)
    }

    func testShouldRenderAsClusterAtZoom() {
        // Small cluster.
        XCTAssertFalse(
            renderer.shouldRenderAsCluster(clusterAroundPosition(kCameraPosition, count: 3), atZoom: 10))
        
        // Large cluster but high zoom.
        XCTAssertFalse(
            renderer.shouldRenderAsCluster(clusterAroundPosition(kCameraPosition, count: 10), atZoom: 21))
        
        // Large cluster and normal zoom.
        XCTAssertTrue(
            renderer.shouldRenderAsCluster(clusterAroundPosition(kCameraPosition, count: 10), atZoom: 20))
        XCTAssertTrue(
            renderer.shouldRenderAsCluster(clusterAroundPosition(kCameraPosition, count: 10), atZoom: 2))
    }

    func testDeallocMarkersCleared() {
        // Arrange.
        var clusters: [GMUCluster] = []
        let cluster1 = clusterAroundPosition(kCameraPosition, count: 10)
        clusters.append(cluster1)

        let cluster2 = clusterAroundPosition(
            CLLocationCoordinate2DMake(
                kCameraPosition.latitude + 1.0,
                kCameraPosition.longitude),
            count: 4)
        clusters.append(cluster2)
        renderer.renderClusters(clusters)
        let markers = renderer.currentActivemarkers
        XCTAssertEqual(markers.count, 2)

        // Act.
        renderer = nil

        // Assert markers are removed from the map.
        XCTAssertEqual(markers.count, 2)
        for marker in markers {
            XCTAssertNil(marker.map)
        }
    }

    // MARK:- Private
    /// Returns a new cluster around a |position| with |count| items in it.
    private func clusterAroundPosition(
        _ position: CLLocationCoordinate2D,
        count: Int
    ) -> GMUStaticCluster {
        return clusterAroundPosition(position, count: count, title: nil, snippet: nil)
    }

    /// Creates a cluster centered around a given position with a specified number of items.
    ///
    /// - Parameters:
    ///   - position: The central coordinate for the cluster.
    ///   - count: The number of items to add to the cluster.
    ///   - title: The optional title for each cluster item.
    ///   - snippet: The optional snippet for each cluster item.
    /// - Returns: A `GMUStaticCluster` containing the generated cluster items.
    private func clusterAroundPosition(
        _ position: CLLocationCoordinate2D,
        count: Int,
        title: String?,
        snippet: String?
    ) -> GMUStaticCluster {
        let cluster = GMUStaticCluster(position: position)
        var count = count
        while count > 0 {
            count -= 1
            let deltaLatitude = (Double(arc4random_uniform(200)) - 100.0) / 100.0
            let deltaLongitude = (Double(arc4random_uniform(200)) - 100.0) / 100.0
            let itemPosition = CLLocationCoordinate2DMake(CLLocationDegrees(position.latitude + deltaLatitude), CLLocationDegrees(position.longitude + deltaLongitude))
            cluster.addItem(GMUTestClusterItem(position: itemPosition, title: title, snippet: snippet))
        }
        count -= 1
        return cluster
    }
}
