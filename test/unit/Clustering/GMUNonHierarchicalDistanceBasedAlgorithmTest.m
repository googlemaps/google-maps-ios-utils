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

#import "Clustering/Algo/GMUNonHierarchicalDistanceBasedAlgorithm.h"

#import "GMUClusterAlgorithmTest.h"

@interface GMUNonHierarchicalDistanceBasedAlgorithmTest : GMUClusterAlgorithmTest
@end

@implementation GMUNonHierarchicalDistanceBasedAlgorithmTest

- (void)testClustersAtZoomLowZoomItemsGroupedIntoOneCluster {
  NSArray<id<GMUClusterItem>> *items = [self simpleClusterItems];

  // Act.
  GMUNonHierarchicalDistanceBasedAlgorithm *algorithm =
      [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
  [algorithm addItems:items];
  NSArray<id<GMUCluster>> *clusters;
  clusters = [algorithm clustersAtZoom:4];

  // Assert.
  XCTAssertEqual(clusters.count, 1);
  XCTAssertEqual([self totalItemCountsForClusters:clusters], items.count);
}

- (void)testClustersAtZoomHighZoomItemsGroupedIntoMultipleClusters {
  NSArray<id<GMUClusterItem>> *items = [self simpleClusterItems];

  // Act.
  GMUNonHierarchicalDistanceBasedAlgorithm *algorithm =
      [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
  [algorithm addItems:items];
  NSArray<id<GMUCluster>> *clusters;
  clusters = [algorithm clustersAtZoom:14];

  // Assert.
  XCTAssertEqual(clusters.count, 4);
  XCTAssertEqual([self totalItemCountsForClusters:clusters], items.count);
}

/**
 * Generates a bunch of random points around a number of "centroids", then shuffle them up and
 * verify number of clusters should be equal to number of centroids.
 */
- (void)testClustersAtZoomRandomClusters {
  // Arrange.
  NSArray<id<GMUClusterItem>> *items = [self randomizedClusterItems];

  // Act.
  GMUNonHierarchicalDistanceBasedAlgorithm *algorithm =
      [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
  [algorithm addItems:items];
  NSArray<id<GMUCluster>> *clusters;
  clusters = [algorithm clustersAtZoom:10];

  // Assert.
  XCTAssertEqual(clusters.count, 4);
  XCTAssertEqual([self totalItemCountsForClusters:clusters], items.count);
  for (id<GMUCluster> cluster in clusters) {
    XCTAssertEqual(cluster.items.count, items.count / 4);
  }
  [self assertValidClusters:clusters];

  // Test on high zoom, should split into multiple clusters.
  clusters = [algorithm clustersAtZoom:18];

  // Assert.
  XCTAssertEqual([self totalItemCountsForClusters:clusters], items.count);
  [self assertValidClusters:clusters];
}

/**
 * Verifies at high zoom, all clusters are distinct and total size is the same
 * as input size.
 */
- (void)testClustersProducesDistinctClustersAtHighZoom {
  // Arrange.
  NSArray<id<GMUClusterItem>> *items = [self randomizedClusterItems];

  // Act.
  GMUNonHierarchicalDistanceBasedAlgorithm *algorithm =
      [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
  [algorithm addItems:items];
  NSArray<id<GMUCluster>> *clusters;
  clusters = [algorithm clustersAtZoom:18];

  // Assert.
  XCTAssertEqual([self totalItemCountsForClusters:clusters], items.count);
  [self assertValidClusters:clusters];
}

@end
