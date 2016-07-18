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

#import "Clustering/Algo/GMUGridBasedClusterAlgorithm.h"

#import "GMUClusterAlgorithmTest.h"

@interface GMUGridBasedClusterAlgorithmTest : GMUClusterAlgorithmTest
@end

@implementation GMUGridBasedClusterAlgorithmTest

- (void)testClustersAtZoomLowZoomItemsGroupedIntoOneCluster {
  GMUGridBasedClusterAlgorithm *algorithm = [[GMUGridBasedClusterAlgorithm alloc] init];
  NSArray<id<GMUClusterItem>> *items = [self simpleClusterItems];
  [algorithm addItems:items];

  // At low zoom, there should be 1 cluster.
  NSArray<id<GMUCluster>> *clusters = [algorithm clustersAtZoom:3];
  XCTAssertEqual(clusters.count, 1);
  XCTAssertEqual(clusters[0].items.count, 4);
}

- (void)testClustersAtZoomHighZoomItemsGroupedIntoMultipleClusters {
  GMUGridBasedClusterAlgorithm *algorithm = [[GMUGridBasedClusterAlgorithm alloc] init];
  NSArray<id<GMUClusterItem>> *items = [self simpleClusterItems];
  [algorithm addItems:items];

  NSArray<id<GMUCluster>> *clusters = [algorithm clustersAtZoom:10];
  XCTAssertEqual(clusters.count, 4);
  for (int i = 0; i < clusters.count; ++i) {
    XCTAssertEqual(clusters[i].items.count, 1);
  }
  [self assertValidClusters:clusters];
}

@end

