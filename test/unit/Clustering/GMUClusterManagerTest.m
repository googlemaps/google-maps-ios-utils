/* Copyright (c) 2016 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "Clustering/GMUClusterManager+Testing.h"

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface GMUClusterManagerTest : XCTestCase
@end

static const CLLocationCoordinate2D kCameraPosition = {-35, 151};
static const double kCameraZoom = 10.0;

@implementation GMUClusterManagerTest {
  // Object under test.
  GMUClusterManager *_clusterManager;
  id _mapView;
  id _algorithm;
  id _renderer;
  id _delegate;
  id _mapDelegate;
  GMSCameraPosition *_camera;
}

- (void)setUp {
  [super setUp];

  _mapView = OCMClassMock([GMSMapView class]);
  _camera = [GMSCameraPosition cameraWithTarget:kCameraPosition zoom:kCameraZoom];
  [[[_mapView stub] andDo:^(NSInvocation *invocation) {
    [invocation setReturnValue:&_camera];
  }] camera];

  _algorithm = OCMProtocolMock(@protocol(GMUClusterAlgorithm));
  _renderer = OCMProtocolMock(@protocol(GMUClusterRenderer));

  _clusterManager =
      [[GMUClusterManager alloc] initWithMap:_mapView algorithm:_algorithm renderer:_renderer];

  _delegate = OCMProtocolMock(@protocol(GMUClusterManagerDelegate));
  _mapDelegate = OCMProtocolMock(@protocol(GMSMapViewDelegate));
  [_clusterManager setDelegate:_delegate mapDelegate:_mapDelegate];
}

- (void)tearDown {
  [super tearDown];

  OCMVerifyAll(_algorithm);
  OCMVerifyAll(_renderer);
  OCMVerifyAll(_delegate);
  OCMVerifyAll(_mapDelegate);
}

// Tests that clusterManager does not set mapView.delegate to itself on init.
- (void)testInitMapDelegateNotHookedByDefault {
  [[_mapView reject] setDelegate:OCMOCK_ANY];
  _clusterManager =
      [[GMUClusterManager alloc] initWithMap:_mapView algorithm:_algorithm renderer:_renderer];
  OCMVerifyAll(_mapView);
}

- (void)testInit {
  XCTAssertEqual(_clusterManager.algorithm, _algorithm);
  XCTAssertEqual(_clusterManager.delegate, _delegate);
  XCTAssertEqual(_clusterManager.mapDelegate, _mapDelegate);
}

- (void)testAddItem {
  // Arrange.
  id item1 = OCMProtocolMock(@protocol(GMUClusterItem));
  [[_algorithm expect] addItems:@[ item1 ]];

  // Act.
  [_clusterManager addItem:item1];
}

- (void)testAddItems {
  // Arrange.
  id item1 = OCMProtocolMock(@protocol(GMUClusterItem));
  id item2 = OCMProtocolMock(@protocol(GMUClusterItem));
  [[_algorithm expect] addItems:@[ item1, item2 ]];

  // Act.
  [_clusterManager addItems:@[ item1, item2 ]];
}

- (void)testRemoveItem {
  // Arrange.
  id item1 = OCMProtocolMock(@protocol(GMUClusterItem));
  [[_algorithm expect] removeItem:item1];
  [_clusterManager addItem:item1];

  // Act.
  [_clusterManager removeItem:item1];
}

- (void)testClearItems {
  // Arrange.
  id item1 = OCMProtocolMock(@protocol(GMUClusterItem));
  id item2 = OCMProtocolMock(@protocol(GMUClusterItem));
  [[_algorithm expect] clearItems];
  [_clusterManager addItems:@[ item1, item2 ]];

  // Act.
  NSUInteger requestCount = [_clusterManager clusterRequestCount];
  [_clusterManager clearItems];
  XCTAssertEqual([_clusterManager clusterRequestCount], requestCount + 1);
}

- (void)testCluster {
  NSArray<id<GMUCluster>> *clusters = @[ OCMProtocolMock(@protocol(GMUCluster)) ];
  [[[_algorithm expect] andReturn:clusters] clustersAtZoom:kCameraZoom];
  [[_renderer expect] renderClusters:clusters];

  [_clusterManager cluster];
}

- (void)testCameraChangedReclusterRequested {
  // Arrange.
  NSArray<id<GMUCluster>> *clusters = @[ OCMProtocolMock(@protocol(GMUCluster)) ];
  [[[_algorithm expect] andReturn:clusters] clustersAtZoom:kCameraZoom];
  [[_renderer expect] renderClusters:clusters];
  // Intial cluster.
  [_clusterManager cluster];

  // Act.
  _camera = [GMSCameraPosition cameraWithTarget:kCameraPosition zoom:kCameraZoom + 2];
  [_clusterManager observeValueForKeyPath:@"camera" ofObject:_mapView change:nil context:nil];
  XCTAssertEqual([_clusterManager clusterRequestCount], 1);
}

// Small camera change should not trigger re-clustering.
- (void)testCameraChangedALittleReclusterNotRequested {
  // Arrange.
  NSArray<id<GMUCluster>> *clusters = @[ OCMProtocolMock(@protocol(GMUCluster)) ];
  [[[_algorithm expect] andReturn:clusters] clustersAtZoom:kCameraZoom];
  [[_renderer expect] renderClusters:clusters];
  // Intial cluster.
  [_clusterManager cluster];

  // Act.
  _camera = [GMSCameraPosition cameraWithTarget:kCameraPosition zoom:kCameraZoom + 0.3];
  [_clusterManager observeValueForKeyPath:@"camera" ofObject:_mapView change:nil context:nil];
  XCTAssertEqual([_clusterManager clusterRequestCount], 0);
}

- (void)testTapOnClusterMarkerEventRaised {
  id<GMUCluster> cluster1 = OCMProtocolMock(@protocol(GMUCluster));
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.map = _mapView;
  marker.userData = cluster1;

  // Expect and reject.
  [[_delegate expect] clusterManager:_clusterManager didTapCluster:cluster1];
  [[_delegate reject] clusterManager:_clusterManager didTapClusterItem:OCMOCK_ANY];

  // Act.
  [_clusterManager mapView:_mapView didTapMarker:marker];
}

- (void)testTapOnClusterItemMarkerEventRaised {
  id<GMUClusterItem> item1 = OCMProtocolMock(@protocol(GMUClusterItem));
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.map = _mapView;
  marker.userData = item1;

  // Expect and reject.
  [[_delegate reject] clusterManager:_clusterManager didTapCluster:OCMOCK_ANY];
  [[_delegate expect] clusterManager:_clusterManager didTapClusterItem:item1];

  // Act.
  [_clusterManager mapView:_mapView didTapMarker:marker];
}

- (void)testTapOnClusterItemMarkerNoDelegateEventRaisedOnMapDelegate {
  id<GMUClusterItem> item1 = OCMProtocolMock(@protocol(GMUClusterItem));
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.map = _mapView;
  marker.userData = item1;
  [_clusterManager setDelegate:nil mapDelegate:_mapDelegate];

  // Expect and reject.
  [[_delegate reject] clusterManager:_clusterManager didTapCluster:OCMOCK_ANY];
  [[_delegate reject] clusterManager:_clusterManager didTapClusterItem:item1];
  [[_mapDelegate expect] mapView:_mapView didTapMarker:marker];

  // Act.
  [_clusterManager mapView:_mapView didTapMarker:marker];
}

- (void)testTapOnClusterItemMarkerDelegateRetusnNOEventRaisedOnMapDelegate {
  id<GMUClusterItem> item1 = OCMProtocolMock(@protocol(GMUClusterItem));
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.map = _mapView;
  marker.userData = item1;
  [_clusterManager setDelegate:_delegate mapDelegate:_mapDelegate];

  // Expect and reject.
  [[_delegate reject] clusterManager:_clusterManager didTapCluster:OCMOCK_ANY];

  // Set _delegate to not handle the event.
  [[[_delegate stub] andReturnValue:OCMOCK_VALUE(NO)] clusterManager:_clusterManager
                                                   didTapClusterItem:item1];
  [[_mapDelegate expect] mapView:_mapView didTapMarker:marker];

  // Act.
  [_clusterManager mapView:_mapView didTapMarker:marker];
}

- (void)testTapOnClusterMarkerDelegateRetusnNOEventRaisedOnMapDelegate {
  id<GMUCluster> cluster1 = OCMProtocolMock(@protocol(GMUCluster));
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.map = _mapView;
  marker.userData = cluster1;

  // Expect and reject.
  // Set _delegate to not handle the event.
  [[[_delegate stub] andReturnValue:OCMOCK_VALUE(NO)] clusterManager:_clusterManager
                                                       didTapCluster:cluster1];
  [[_delegate reject] clusterManager:_clusterManager didTapClusterItem:OCMOCK_ANY];
  [[_mapDelegate expect] mapView:_mapView didTapMarker:marker];

  // Act.
  [_clusterManager mapView:_mapView didTapMarker:marker];
}

- (void)testTapOnNormalMarkerEventRaisedOnMapDelegate {
  GMSMarker *marker = [[GMSMarker alloc] init];
  marker.map = _mapView;

  // Expect and reject.
  [[_delegate reject] clusterManager:_clusterManager didTapCluster:OCMOCK_ANY];
  [[_delegate reject] clusterManager:_clusterManager didTapClusterItem:OCMOCK_ANY];
  [[_mapDelegate expect] mapView:_mapView didTapMarker:marker];

  // Act.
  [_clusterManager mapView:_mapView didTapMarker:marker];
}

- (void)testMapEventsForwardedToMapDelegate {
  GMSMarker *marker = [[GMSMarker alloc] init];
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:kCameraPosition zoom:kCameraZoom];

  // Expect and reject.
  [[_mapDelegate expect] mapView:_mapView willMove:YES];
  [[_mapDelegate expect] mapView:_mapView didChangeCameraPosition:camera];
  [[_mapDelegate expect] mapView:_mapView idleAtCameraPosition:camera];
  [[_mapDelegate expect] mapView:_mapView didTapAtCoordinate:kCameraPosition];
  [[_mapDelegate expect] mapView:_mapView didLongPressAtCoordinate:kCameraPosition];
  [[_mapDelegate expect] mapView:_mapView didTapInfoWindowOfMarker:marker];
  [[_mapDelegate expect] mapView:_mapView didLongPressInfoWindowOfMarker:marker];
  [[_mapDelegate expect] mapView:_mapView didTapOverlay:marker];
  [[_mapDelegate expect] mapView:_mapView markerInfoWindow:marker];
  [[_mapDelegate expect] mapView:_mapView markerInfoContents:marker];
  [[_mapDelegate expect] mapView:_mapView didCloseInfoWindowOfMarker:marker];
  [[_mapDelegate expect] mapView:_mapView didBeginDraggingMarker:marker];
  [[_mapDelegate expect] mapView:_mapView didEndDraggingMarker:marker];
  [[_mapDelegate expect] didTapMyLocationButtonForMapView:_mapView];
  [[_mapDelegate expect] mapViewDidStartTileRendering:_mapView];
  [[_mapDelegate expect] mapViewDidFinishTileRendering:_mapView];

  // Act.
  [_clusterManager mapView:_mapView willMove:YES];
  [_clusterManager mapView:_mapView didChangeCameraPosition:camera];
  [_clusterManager mapView:_mapView idleAtCameraPosition:camera];
  [_clusterManager mapView:_mapView didTapAtCoordinate:kCameraPosition];
  [_clusterManager mapView:_mapView didLongPressAtCoordinate:kCameraPosition];
  [_clusterManager mapView:_mapView didTapInfoWindowOfMarker:marker];
  [_clusterManager mapView:_mapView didLongPressInfoWindowOfMarker:marker];
  [_clusterManager mapView:_mapView didTapOverlay:marker];
  [_clusterManager mapView:_mapView markerInfoWindow:marker];
  [_clusterManager mapView:_mapView markerInfoContents:marker];
  [_clusterManager mapView:_mapView didCloseInfoWindowOfMarker:marker];
  [_clusterManager mapView:_mapView didBeginDraggingMarker:marker];
  [_clusterManager mapView:_mapView didEndDraggingMarker:marker];
  [_clusterManager didTapMyLocationButtonForMapView:_mapView];
  [_clusterManager mapViewDidStartTileRendering:_mapView];
  [_clusterManager mapViewDidFinishTileRendering:_mapView];
}

@end

