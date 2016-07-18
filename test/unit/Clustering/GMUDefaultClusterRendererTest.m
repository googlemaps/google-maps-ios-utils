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

#import "Clustering/View/GMUDefaultClusterRenderer+Testing.h"

#import "Clustering/GMUStaticCluster.h"
#import "Clustering/View/GMUClusterIconGenerator.h"
#import "Common/Model/GMUTestClusterItem.h"

#import <GoogleMaps/GoogleMaps.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface GMUDefaultClusterRendererTest : XCTestCase
@end

static const CLLocationCoordinate2D kCameraPosition = {-35, 151};

@implementation GMUDefaultClusterRendererTest {
  // Object under test.
  GMUDefaultClusterRenderer *_renderer;
  GMSMapView *_mapView;
}

- (void)setUp {
  [super setUp];

  id mapView = OCMClassMock([GMSMapView class]);

  // Stub out camera property.
  GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:kCameraPosition zoom:10];
  [[[mapView stub] andReturn:camera] camera];

  // Stub out projection property.
  id projection = OCMClassMock([GMSProjection class]);
  CLLocationCoordinate2D nearLeft =
      CLLocationCoordinate2DMake(kCameraPosition.latitude - 10, kCameraPosition.longitude - 10);
  CLLocationCoordinate2D nearRight =
      CLLocationCoordinate2DMake(kCameraPosition.latitude - 10, kCameraPosition.longitude + 10);
  CLLocationCoordinate2D farLeft =
      CLLocationCoordinate2DMake(kCameraPosition.latitude + 10, kCameraPosition.longitude - 10);
  CLLocationCoordinate2D farRight =
      CLLocationCoordinate2DMake(kCameraPosition.latitude + 10, kCameraPosition.longitude + 10);
  GMSVisibleRegion visibleRegion = {nearLeft, nearRight, farLeft, farRight};
  [[[projection stub] andReturnValue:OCMOCK_VALUE(visibleRegion)] visibleRegion];
  [[[mapView stub] andReturn:projection] projection];

  id<GMUClusterIconGenerator> iconGenerator = OCMProtocolMock(@protocol(GMUClusterIconGenerator));
  _renderer = [[GMUDefaultClusterRenderer alloc] initWithMapView:mapView
                                            clusterIconGenerator:iconGenerator];
  _renderer.animatesClusters = NO;
  _mapView = mapView;
}

// Large clusters should be rendered as 1 marker and not expanded.
- (void)testRenderClustersLargeClustersNotExpanded {
  // Arrange.
  NSMutableArray<id<GMUCluster>> *clusters = [[NSMutableArray<id<GMUCluster>> alloc] init];
  GMUStaticCluster *cluster1 = [self clusterAroundPosition:kCameraPosition count:10];
  [clusters addObject:cluster1];

  GMUStaticCluster *cluster2 =
      [self clusterAroundPosition:CLLocationCoordinate2DMake(kCameraPosition.latitude + 1.0,
                                                             kCameraPosition.longitude)
                            count:4];
  [clusters addObject:cluster2];

  // Act.
  [_renderer renderClusters:clusters];

  // Assert.
  NSArray<GMSMarker *> *markers = [_renderer markers];
  XCTAssertEqual(markers.count, 2);
  XCTAssertTrue([markers[0].userData conformsToProtocol:@protocol(GMUCluster)]);
  XCTAssertEqual(markers[0].map, _mapView);

  XCTAssertTrue([markers[1].userData conformsToProtocol:@protocol(GMUCluster)]);
  XCTAssertEqual(markers[1].map, _mapView);
}

// Small clusters should be expanded into markers (one per cluster item).
- (void)testRenderClustersSmallClustersExpanded {
  // Arrange.
  NSMutableArray<id<GMUCluster>> *clusters = [[NSMutableArray<id<GMUCluster>> alloc] init];
  GMUStaticCluster *cluster1 = [self clusterAroundPosition:kCameraPosition count:3];
  [clusters addObject:cluster1];

  // Act.
  [_renderer renderClusters:clusters];

  // Assert.
  NSArray<GMSMarker *> *markers = [_renderer markers];
  XCTAssertEqual(markers.count, 3);
  XCTAssertTrue([markers[0].userData conformsToProtocol:@protocol(GMUClusterItem)]);
  XCTAssertEqual(markers[0].map, _mapView);

  XCTAssertTrue([markers[1].userData conformsToProtocol:@protocol(GMUClusterItem)]);
  XCTAssertEqual(markers[1].map, _mapView);

  XCTAssertTrue([markers[2].userData conformsToProtocol:@protocol(GMUClusterItem)]);
  XCTAssertEqual(markers[2].map, _mapView);
}

// Clusters outside the camera's visible region should not be rendered.
- (void)testRenderClustersInvisibleClustersNotRendered {
  // Arrange.
  NSMutableArray<id<GMUCluster>> *clusters = [[NSMutableArray<id<GMUCluster>> alloc] init];
  GMUStaticCluster *cluster1 = [self clusterAroundPosition:kCameraPosition count:10];
  [clusters addObject:cluster1];

  // Outside cluster.
  GMUStaticCluster *cluster2 =
      [self clusterAroundPosition:CLLocationCoordinate2DMake(kCameraPosition.latitude + 20.0,
                                                             kCameraPosition.longitude + 20.0)
                            count:10];
  [clusters addObject:cluster2];

  // Act.
  [_renderer renderClusters:clusters];

  // Assert.
  NSArray<GMSMarker *> *markers = [_renderer markers];
  XCTAssertEqual(markers.count, 1);
  XCTAssertEqual(markers[0].map, _mapView);
  XCTAssertEqual(markers[0].userData, cluster1);  // Only cluster1 is rendered
}

// Clusters outside the camera's visible region should not be rendered.
- (void)testRenderClustersPreviousMarkersRemovedFromMap {
  // Arrange.
  NSMutableArray<id<GMUCluster>> *clusters = [[NSMutableArray<id<GMUCluster>> alloc] init];
  GMUStaticCluster *cluster1 = [self clusterAroundPosition:kCameraPosition count:10];
  [clusters addObject:cluster1];

  // Initial render.
  [_renderer renderClusters:clusters];
  NSArray<GMSMarker *> *previousMarkers = [_renderer markers];
  XCTAssertEqual(previousMarkers.count, 1);
  XCTAssertEqual(previousMarkers[0].map, _mapView);

  // Act: renderClusters again.
  [_renderer renderClusters:clusters];

  // Assert.
  NSArray<GMSMarker *> *markers = [_renderer markers];
  XCTAssertEqual(markers.count, 1);
  XCTAssertEqual(markers[0].map, _mapView);

  // Assert previous marker removed from map.
  XCTAssertNil(previousMarkers[0].map);
}

- (void)testShouldRenderAsClusterAtZoom {
  // Small cluster.
  XCTAssertFalse([_renderer
      shouldRenderAsCluster:[self clusterAroundPosition:kCameraPosition count:3]
                     atZoom:10]);

  // Large cluster but high zoom.
  XCTAssertFalse([_renderer
      shouldRenderAsCluster:[self clusterAroundPosition:kCameraPosition count:10]
                     atZoom:21]);

  // Large cluster and normal zoom.
  XCTAssertTrue([_renderer
      shouldRenderAsCluster:[self clusterAroundPosition:kCameraPosition count:10]
                     atZoom:20]);
  XCTAssertTrue([_renderer
      shouldRenderAsCluster:[self clusterAroundPosition:kCameraPosition count:10]
                     atZoom:2]);
}

- (void)testDeallocMarkersCleared {
  // Arrange.
  NSMutableArray<id<GMUCluster>> *clusters = [[NSMutableArray<id<GMUCluster>> alloc] init];
  GMUStaticCluster *cluster1 = [self clusterAroundPosition:kCameraPosition count:10];
  [clusters addObject:cluster1];

  GMUStaticCluster *cluster2 =
  [self clusterAroundPosition:CLLocationCoordinate2DMake(kCameraPosition.latitude + 1.0,
                                                         kCameraPosition.longitude)
                        count:4];
  [clusters addObject:cluster2];
  [_renderer renderClusters:clusters];
  NSArray<GMSMarker *> *markers = [[_renderer markers] copy];
  XCTAssertEqual(markers.count, 2);

  // Act.
  _renderer = nil;

  // Assert markers are removed from the map.
  XCTAssertEqual(markers.count, 2);
  for (GMSMarker *marker in markers) {
    XCTAssertNil(marker.map);
  }
}

#pragma mark Private

// Returns a new cluster around a |position| with |count| items in it.
- (GMUStaticCluster *)clusterAroundPosition:(CLLocationCoordinate2D)position
                                      count:(NSUInteger)count {
  GMUStaticCluster *cluster = [[GMUStaticCluster alloc] initWithPosition:position];
  while (count-- > 0) {
    double deltaLatitude = (arc4random_uniform(200) - 100.0) / 100.0;
    double deltaLongitude = (arc4random_uniform(200) - 100.0) / 100.0;
    CLLocationCoordinate2D itemPosition = CLLocationCoordinate2DMake(
        position.latitude + deltaLatitude, position.longitude + deltaLongitude);
    [cluster addItem:[[GMUTestClusterItem alloc] initWithPosition:itemPosition]];
  }
  return cluster;
}

@end

