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

#import "GMUPoint.h"

@interface GMUPointTest : XCTestCase
@end

static NSString *const kType = @"Point";

@implementation GMUPointTest

- (void)testInitWithCoordinate {
  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(123.456, 456.789);
  GMUPoint *point = [[GMUPoint alloc] initWithCoordinate:coordinate];
  XCTAssertEqualObjects(point.type, kType);
  XCTAssertEqual(point.coordinate.latitude, coordinate.latitude);
  XCTAssertEqual(point.coordinate.longitude, coordinate.longitude);
}

@end
