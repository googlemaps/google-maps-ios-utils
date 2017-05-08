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

#import "Clustering/GMUStaticCluster.h"

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#define XCTAssertCoordsEqual(c1, c2, descr)        \
  XCTAssertEqual(c1.latitude, c2.latitude, descr); \
  XCTAssertEqual(c1.longitude, c2.longitude, descr);

@interface GMUStaticClusterTest : XCTestCase
@end

static const CLLocationCoordinate2D kClusterPosition = {-35, 151};

@implementation GMUStaticClusterTest

- (void)testInitWithPosition {
  GMUStaticCluster *cluster = [[GMUStaticCluster alloc] initWithPosition:kClusterPosition];
  XCTAssertCoordsEqual(cluster.position, kClusterPosition,
                       @"Cluster position failed to initialize.");
}

- (void)testAddItem {
  GMUStaticCluster *cluster = [[GMUStaticCluster alloc] initWithPosition:kClusterPosition];

  // Add 1 item.
  id<GMUClusterItem> item1 = OCMProtocolMock(@protocol(GMUClusterItem));
  [cluster addItem:item1];
  XCTAssertEqual(cluster.count, 1);

  // Add another item.
  id<GMUClusterItem> item2 = OCMProtocolMock(@protocol(GMUClusterItem));
  [cluster addItem:item2];
  XCTAssertEqual(cluster.count, 2);

  // Assert items are in added order.
  XCTAssertEqual(cluster.items[0], item1);
  XCTAssertEqual(cluster.items[1], item2);
}


- (void)testRemoveItem {
  GMUStaticCluster *cluster = [[GMUStaticCluster alloc] initWithPosition:kClusterPosition];

  id<GMUClusterItem> item1 = OCMProtocolMock(@protocol(GMUClusterItem));
  id<GMUClusterItem> item2 = OCMProtocolMock(@protocol(GMUClusterItem));

  // Add 1 item.
  [cluster addItem:item1];
  XCTAssertEqual(cluster.count, 1);

  // Remove item which does not exist is OK.
  [cluster removeItem:item2];
  XCTAssertEqual(cluster.count, 1);

  // Remove item1.
  [cluster removeItem:item1];
  XCTAssertEqual(cluster.count, 0);
}

@end

