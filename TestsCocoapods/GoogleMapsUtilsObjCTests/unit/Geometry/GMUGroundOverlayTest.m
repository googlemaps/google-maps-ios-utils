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

#import "GMUGroundOverlay.h"

@interface GMUGroundOverlayTest : XCTestCase
@end

@implementation GMUGroundOverlayTest

static NSString *const kType = @"GroundOverlay";
static NSString *const kHref = @"image.jpg";
static const int kZIndex = 1;
static const double kRotation = 45.0;

- (void)testInitWithProperties {
  CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(234.567, 345.678);
  CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(123.456, 456.789);
  GMUGroundOverlay *groundOverlay = [[GMUGroundOverlay alloc] initWithCoordinate:northEast
                                                                       southWest:southWest
                                                                          zIndex:kZIndex
                                                                        rotation:kRotation
                                                                            href:kHref];
  XCTAssertEqualObjects(groundOverlay.type, kType);
  XCTAssertEqual(groundOverlay.northEast.longitude, northEast.longitude);
  XCTAssertEqual(groundOverlay.northEast.latitude, northEast.latitude);
  XCTAssertEqual(groundOverlay.southWest.latitude, southWest.latitude);
  XCTAssertEqual(groundOverlay.southWest.longitude, southWest.longitude);
  XCTAssertEqual(groundOverlay.zIndex, kZIndex);
  XCTAssertEqual(groundOverlay.rotation, kRotation);
  XCTAssertEqual(groundOverlay.href, kHref);
}

@end
