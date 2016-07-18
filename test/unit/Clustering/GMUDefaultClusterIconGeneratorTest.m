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

#import "Clustering/View/GMUDefaultClusterIconGenerator+Testing.h"

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

@interface GMUDefaultClusterIconGeneratorTest : XCTestCase
@end

@implementation GMUDefaultClusterIconGeneratorTest {
  NSArray<NSNumber *> *_buckets;
  NSArray<UIImage *> *_backgroundImages;
  GMUDefaultClusterIconGenerator *_generator;
  id _mockGenerator;
}

- (void)setUp {
  [super setUp];
  _buckets = @[ @10, @20, @50, @100, @1000 ];
  _backgroundImages = @[
    [[UIImage alloc] init],
    [[UIImage alloc] init],
    [[UIImage alloc] init],
    [[UIImage alloc] init],
    [[UIImage alloc] init]
  ];
}

- (void)tearDown {
  [super tearDown];
  OCMVerifyAll(_mockGenerator);
}

- (void)testIconForSizeDefaultGenerator {
  [self setUpDefaultGenerator];

  // Small sizes.
  [[[_mockGenerator expect] andReturn:nil] iconForText:@"1" withBucketIndex:0];
  [_generator iconForSize:1];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"2" withBucketIndex:0];
  [_generator iconForSize:2];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"9" withBucketIndex:0];
  [_generator iconForSize:9];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"10+" withBucketIndex:0];
  [_generator iconForSize:10];

  // Other bigger buckets.
  [[[_mockGenerator expect] andReturn:nil] iconForText:@"10+" withBucketIndex:0];
  [_generator iconForSize:11];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"20+" withBucketIndex:1];
  [_generator iconForSize:21];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"50+" withBucketIndex:2];
  [_generator iconForSize:51];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"100+" withBucketIndex:3];
  [_generator iconForSize:500];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"1000+" withBucketIndex:4];
  [_generator iconForSize:1010];
}

- (void)testIconForSizeGeneratorWithBackgroundImages {
  [self setUpGeneratorWithBackgroundImages];

  // Small sizes.
  [[[_mockGenerator expect] andReturn:nil] iconForText:@"1" withBaseImage:_backgroundImages[0]];
  [_generator iconForSize:1];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"2" withBaseImage:_backgroundImages[0]];
  [_generator iconForSize:2];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"9" withBaseImage:_backgroundImages[0]];
  [_generator iconForSize:9];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"10+" withBaseImage:_backgroundImages[0]];
  [_generator iconForSize:10];

  // Other bigger buckets.
  [[[_mockGenerator expect] andReturn:nil] iconForText:@"10+" withBaseImage:_backgroundImages[0]];
  [_generator iconForSize:11];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"20+" withBaseImage:_backgroundImages[1]];
  [_generator iconForSize:21];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"50+" withBaseImage:_backgroundImages[2]];
  [_generator iconForSize:51];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"100+" withBaseImage:_backgroundImages[3]];
  [_generator iconForSize:500];

  [[[_mockGenerator expect] andReturn:nil] iconForText:@"1000+" withBaseImage:_backgroundImages[4]];
  [_generator iconForSize:1010];
}

- (void)testInitThrowsWhenBucketsAndBackgroundImagesAreOfDifferentSize {
  NSArray *buckets = @[ @10, @20, @50, @100, @1000 ];
  NSArray *backgroundImages =
      @[ [[UIImage alloc] init], [[UIImage alloc] init], [[UIImage alloc] init] ];

  XCTAssertThrowsSpecificNamed(
      [[GMUDefaultClusterIconGenerator alloc] initWithBuckets:buckets
                                             backgroundImages:backgroundImages],
      NSException, NSInvalidArgumentException);
}

- (void)testInitThrowsWhenBucketsAreEmpty {
  NSArray *buckets = @[];
  NSArray *backgroundImages = @[];

  XCTAssertThrowsSpecificNamed(
      [[GMUDefaultClusterIconGenerator alloc] initWithBuckets:buckets
                                             backgroundImages:backgroundImages],
      NSException, NSInvalidArgumentException);
}

- (void)testInitThrowsWhenBucketsAreNotStrictlyIncreasing {
  NSArray *buckets = @[ @10, @10 ];

  XCTAssertThrowsSpecificNamed([[GMUDefaultClusterIconGenerator alloc] initWithBuckets:buckets],
                               NSException, NSInvalidArgumentException);
}

- (void)testInitThrowsWhenBucketsHaveNonNegativeValues {
  NSArray *buckets = @[ @(-10), @10 ];

  XCTAssertThrowsSpecificNamed([[GMUDefaultClusterIconGenerator alloc] initWithBuckets:buckets],
                               NSException, NSInvalidArgumentException);
}

#pragma mark Private

- (void)setUpDefaultGenerator {
  _generator = [[GMUDefaultClusterIconGenerator alloc] initWithBuckets:_buckets];
  _mockGenerator = OCMPartialMock(_generator);
}

- (void)setUpGeneratorWithBackgroundImages {
  _generator = [[GMUDefaultClusterIconGenerator alloc] initWithBuckets:_buckets
                                                      backgroundImages:_backgroundImages];
  _mockGenerator = OCMPartialMock(_generator);
}

@end

