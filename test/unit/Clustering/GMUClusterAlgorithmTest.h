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

#import <XCTest/XCTest.h>

#import "Clustering/GMUClusterItem.h"

#import "Common/Model/GMUTestClusterItem.h"

@protocol GMUCluster;

/**
 * Base class for cluster algorithm tests.
 */
@interface GMUClusterAlgorithmTest : XCTestCase

// Randomly shuffle a mutable array.
- (void)shuffleMutableArray:(NSMutableArray *)array;

// Creates a cluster item at given |location|.
- (id<GMUClusterItem>)itemAtLocation:(CLLocationCoordinate2D)location;

// Randomly generates cluster items around a |location|.
- (NSArray<id<GMUClusterItem>> *)itemsAroundLocation:(CLLocationCoordinate2D)location
                                               count:(int)count
                                                zoom:(double)zoom
                                              radius:(double)screenPoints;

// Sum of all clusters' item counts.
- (NSUInteger)totalItemCountsForClusters:(NSArray<id<GMUCluster>> *)clusters;

// Asserts 2 clusters do not share common items.
- (void)assertCluster:(id<GMUCluster>)cluster1 doesNotOverlapCluster:(id<GMUCluster>)cluster2;

- (void)assertValidClusters:(NSArray<id<GMUCluster>> *)clusters;

#pragma mark Fixtures

// Generates a fixed number of items for the simple test cases.
- (NSArray<id<GMUClusterItem>> *)simpleClusterItems;

// Randomly generates a number of items around fixed centroids.
- (NSArray<id<GMUClusterItem>> *)randomizedClusterItems;

@end

