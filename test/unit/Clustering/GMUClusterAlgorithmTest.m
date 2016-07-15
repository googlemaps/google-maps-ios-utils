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

#import "GMUClusterAlgorithmTest.h"

#import "Clustering/GMUCluster.h"
#import "GoogleMaps/GMSGeometryUtils.h"

const static CLLocationCoordinate2D kLocation1 = {-1, -1};
const static CLLocationCoordinate2D kLocation2 = {-1, 1};
const static CLLocationCoordinate2D kLocation3 = {1, 1};
const static CLLocationCoordinate2D kLocation4 = {1, -1};

// Returns a random value from 0-1.0.
static double randd() { return (((double)arc4random() / 0x100000000) * 1.0); }

@implementation GMUClusterAlgorithmTest

- (id<GMUClusterItem>)itemAtLocation:(CLLocationCoordinate2D)location {
  return [[GMUTestClusterItem alloc] initWithPosition:location];
}

- (NSArray<id<GMUClusterItem>> *)itemsAroundLocation:(CLLocationCoordinate2D)location
                                               count:(int)count
                                                zoom:(double)zoom
                                              radius:(double)screenPoints {
  double worldUnisPerScreenPoint = pow(2, -7 - zoom);
  double worldUnits = screenPoints * worldUnisPerScreenPoint;
  GMSMapPoint mapPoint = GMSProject(location);
  NSMutableArray<id<GMUClusterItem>> *items = [[NSMutableArray<id<GMUClusterItem>> alloc] init];
  while (count-- > 0) {
    GMSMapPoint nearMapPoint = {mapPoint.x + randd() * worldUnits,
                                mapPoint.y + randd() * worldUnits};
    CLLocationCoordinate2D nearLocation = GMSUnproject(nearMapPoint);
    [items addObject:[[GMUTestClusterItem alloc] initWithPosition:nearLocation]];
  }
  return items;
}

- (void)shuffleMutableArray:(NSMutableArray *)array {
  for (u_int32_t i = 0; i < array.count; ++i) {
    u_int32_t randomIndex = arc4random_uniform((u_int32_t)array.count);
    [array exchangeObjectAtIndex:i withObjectAtIndex:randomIndex];
  }
}

- (NSUInteger)totalItemCountsForClusters:(NSArray<id<GMUCluster>> *)clusters {
  __block NSUInteger sum = 0;
  [clusters enumerateObjectsUsingBlock:^(id<GMUCluster> _Nonnull obj, NSUInteger idx,
                                         BOOL *_Nonnull stop) {
    sum += obj.items.count;
  }];
  return sum;
}

#pragma mark Asserts

- (void)assertCluster:(id<GMUCluster>)cluster1 doesNotOverlapCluster:(id<GMUCluster>)cluster2 {
  NSSet *set1 = [NSSet setWithArray:cluster1.items];
  NSSet *set2 = [NSSet setWithArray:cluster2.items];
  XCTAssertFalse([set1 intersectsSet:set2]);
}

- (void)assertValidClusters:(NSArray<id<GMUCluster>> *)clusters {
  for (int i = 0; i < clusters.count; ++i) {
    for (int j = 0; j < i; ++j) {
      [self assertCluster:clusters[i] doesNotOverlapCluster:clusters[j]];
    }
  }
}

#pragma mark Fixtures

- (NSArray<id<GMUClusterItem>> *)simpleClusterItems {
  NSMutableArray<id<GMUClusterItem>> *items = [[NSMutableArray<id<GMUClusterItem>> alloc] init];
  [items addObject:[self itemAtLocation:kLocation1]];
  [items addObject:[self itemAtLocation:kLocation2]];
  [items addObject:[self itemAtLocation:kLocation3]];
  [items addObject:[self itemAtLocation:kLocation4]];
  return items;
}

- (NSArray<id<GMUClusterItem>> *)randomizedClusterItems {
  const double zoom = 10.0;
  const double radius = 50.0;
  const int count = 10;

  NSMutableArray<id<GMUClusterItem>> *items = [[NSMutableArray<id<GMUClusterItem>> alloc] init];
  NSArray<id<GMUClusterItem>> *items1 =
      [self itemsAroundLocation:kLocation1 count:count zoom:zoom radius:radius];
  NSArray<id<GMUClusterItem>> *items2 =
      [self itemsAroundLocation:kLocation2 count:count zoom:zoom radius:radius];
  NSArray<id<GMUClusterItem>> *items3 =
      [self itemsAroundLocation:kLocation3 count:count zoom:zoom radius:radius];
  NSArray<id<GMUClusterItem>> *items4 =
      [self itemsAroundLocation:kLocation4 count:count zoom:zoom radius:radius];

  [items addObjectsFromArray:items1];
  [items addObjectsFromArray:items2];
  [items addObjectsFromArray:items3];
  [items addObjectsFromArray:items4];

  [self shuffleMutableArray:items];
  return items;
}

@end

