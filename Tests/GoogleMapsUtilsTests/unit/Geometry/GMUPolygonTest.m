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

#import "GMUPolygon.h"

@interface GMUPolygonTest : XCTestCase
@end

static NSString *const kType = @"Polygon";
static const CLLocationDegrees kFirstLatitude = 50.0;
static const CLLocationDegrees kFirstLongitude = 45.0;
static const CLLocationDegrees kSecondLatitude = 55.0;
static const CLLocationDegrees kSecondLongitude = 50.0;
static const CLLocationDegrees kThirdLatitude = 60.0;
static const CLLocationDegrees kThirdLongitude = 55.0;

@implementation GMUPolygonTest

- (void)testInitWithCoordinatesArray {
  CLLocationCoordinate2D firstCoordinate =
      CLLocationCoordinate2DMake(kFirstLatitude, kFirstLongitude);
  CLLocationCoordinate2D secondCoordinate =
      CLLocationCoordinate2DMake(kSecondLatitude, kSecondLongitude);
  CLLocationCoordinate2D thirdCoordinate =
      CLLocationCoordinate2DMake(kThirdLatitude, kThirdLongitude);
  GMSMutablePath *path = [[GMSMutablePath alloc] init];
  [path addCoordinate:firstCoordinate];
  [path addCoordinate:secondCoordinate];
  [path addCoordinate:thirdCoordinate];
  [path addCoordinate:firstCoordinate];
  NSArray *paths = [NSArray arrayWithObject:path];
  GMUPolygon *polygon =
  [[GMUPolygon alloc] initWithPaths:paths];
  XCTAssertEqualObjects(polygon.type, kType);
  XCTAssertEqualObjects(polygon.paths, paths);
}

@end
