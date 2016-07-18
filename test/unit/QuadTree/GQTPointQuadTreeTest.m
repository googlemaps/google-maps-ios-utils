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

#import "QuadTree/GQTPointQuadTree.h"

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

static double randd(double min, double max) {
  double range = max - min;
  return min + range * arc4random_uniform(1000) / 1000;
}

@interface GQTPointQuadTreeTest : XCTestCase
@end

@implementation GQTPointQuadTreeTest

- (id<GQTPointQuadTreeItem>)itemAtPoint:(GQTPoint)point {
  id item = OCMProtocolMock(@protocol(GQTPointQuadTreeItem));
  [[[item stub] andReturnValue:OCMOCK_VALUE(point)] point];
  return item;
}

- (void)testAddInsideItemAdded {
  GQTPointQuadTree *tree = [[GQTPointQuadTree alloc] init];
  id<GQTPointQuadTreeItem> item = [self itemAtPoint:(GQTPoint){0.5, 0.5}];
  BOOL result = [tree add:item];

  XCTAssertTrue(result);
  XCTAssertEqual(tree.count, 1);
}

- (void)testAddInsideItemIgnored {
  GQTPointQuadTree *tree =
      [[GQTPointQuadTree alloc] initWithBounds:(GQTBounds){-0.2, -0.2, 0.2, 0.2}];
  id<GQTPointQuadTreeItem> item = [self itemAtPoint:(GQTPoint){0.5, 0.5}];
  BOOL result = [tree add:item];

  XCTAssertFalse(result);
  XCTAssertEqual(tree.count, 0);
}

- (void)testAddNilItemIgnored {
  GQTPointQuadTree *tree = [[GQTPointQuadTree alloc] init];
  BOOL result = [tree add:nil];

  XCTAssertFalse(result);
  XCTAssertEqual(tree.count, 0);
}

- (void)testRemoveAddedItemRemoved {
  GQTPointQuadTree *tree = [[GQTPointQuadTree alloc] init];
  id<GQTPointQuadTreeItem> item = [self itemAtPoint:(GQTPoint){0.5, 0.5}];
  [tree add:item];

  BOOL result = [tree remove:item];

  XCTAssertTrue(result);
  XCTAssertEqual(tree.count, 0);
}

- (void)testRemoveNonExistingItemIgnored {
  GQTPointQuadTree *tree = [[GQTPointQuadTree alloc] init];
  id<GQTPointQuadTreeItem> item = [self itemAtPoint:(GQTPoint){0.5, 0.5}];
  [tree add:item];

  id<GQTPointQuadTreeItem> newItem = [self itemAtPoint:(GQTPoint){0.5, 0.5}];
  BOOL result = [tree remove:newItem];

  XCTAssertFalse(result);
  XCTAssertEqual(tree.count, 1);
}

- (void)testRemoveOutsideItemIgnored {
  GQTPointQuadTree *tree = [[GQTPointQuadTree alloc] init];

  id<GQTPointQuadTreeItem> item = [self itemAtPoint:(GQTPoint){1.5, 1.5}];
  BOOL result = [tree remove:item];

  XCTAssertFalse(result);
  XCTAssertEqual(tree.count, 0);
}

- (void)testClear {
  GQTPointQuadTree *tree = [[GQTPointQuadTree alloc] init];
  [tree add:[self itemAtPoint:(GQTPoint){0.5, 0.5}]];
  [tree add:[self itemAtPoint:(GQTPoint){1.0, 1.0}]];
  XCTAssertEqual(tree.count, 2);

  [tree clear];

  XCTAssertEqual(tree.count, 0);
}

- (void)testSearchWithBounds {
  GQTPointQuadTree *tree = [[GQTPointQuadTree alloc] init];
  [tree add:[self itemAtPoint:(GQTPoint){0.5, 0.5}]];
  [tree add:[self itemAtPoint:(GQTPoint){-0.5, 0.5}]];
  [tree add:[self itemAtPoint:(GQTPoint){-0.5, -0.5}]];
  [tree add:[self itemAtPoint:(GQTPoint){-0.5, -0.5}]];

  NSArray *items = [tree searchWithBounds:(GQTBounds){-1, -1, 1, 1}];
  XCTAssertEqual(items.count, 4);

  items = [tree searchWithBounds:(GQTBounds){-1, -1, -0.6, -0.6}];
  XCTAssertEqual(items.count, 0);

  items = [tree searchWithBounds:(GQTBounds){0.6, 0.6, 1, 1}];
  XCTAssertEqual(items.count, 0);

  items = [tree searchWithBounds:(GQTBounds){0, 0, 0.6, 0.6}];
  XCTAssertEqual(items.count, 1);

  items = [tree searchWithBounds:(GQTBounds){-1, -1, 1, 0}];
  XCTAssertEqual(items.count, 2);
}

- (void)testSearchWithBoundsRandomizedItems {
  GQTPointQuadTree *tree = [[GQTPointQuadTree alloc] init];
  for (id item in [self itemsFullyInside:(GQTBounds) { -1, -1, 0, 0 } count:10]) {
    [tree add:item];
  }
  for (id item in [self itemsFullyInside:(GQTBounds) { -1, 0, 0, 1 } count:20]) {
    [tree add:item];
  }
  for (id item in [self itemsFullyInside:(GQTBounds) { 0, 0, 1, 1 } count:30]) {
    [tree add:item];
  }
  for (id item in [self itemsFullyInside:(GQTBounds) { 0, -1, 1, 0 } count:40]) {
    [tree add:item];
  }

  NSArray *items = [tree searchWithBounds:(GQTBounds){-1, -1, 1, 1}];
  XCTAssertEqual(items.count, 100);

  items = [tree searchWithBounds:(GQTBounds){-1, -1, 0, 0}];
  XCTAssertEqual(items.count, 10);

  items = [tree searchWithBounds:(GQTBounds){-1, 0, 0, 1}];
  XCTAssertEqual(items.count, 20);

  items = [tree searchWithBounds:(GQTBounds){0, 0, 1, 1}];
  XCTAssertEqual(items.count, 30);

  items = [tree searchWithBounds:(GQTBounds){0, -1, 1, 0}];
  XCTAssertEqual(items.count, 40);
}

#pragma mark Utilities

- (NSArray *)itemsFullyInside:(GQTBounds)bounds count:(NSUInteger)count {
  NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:count];
  while (count-- > 0) {
    [items addObject:[self itemAtPoint:(GQTPoint){randd(bounds.minX + DBL_EPSILON,
                                                        bounds.maxX - DBL_EPSILON),
                                                  randd(bounds.minY + DBL_EPSILON,
                                                        bounds.maxY - DBL_EPSILON)}]];
  }
  return items;
}

@end

