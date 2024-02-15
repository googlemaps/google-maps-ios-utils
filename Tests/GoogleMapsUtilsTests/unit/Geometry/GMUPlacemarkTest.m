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

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "GMUPlacemark.h"

@interface GMUPlacemarkTest : XCTestCase
@end

static NSString *const kTitle = @"Placemark";
static NSString *const kSnippet = @"A test placemark.";
static NSString *const kStyleUrl = @"#test";

@implementation GMUPlacemarkTest

- (void)testInitWithGeometry {
  id geometry = OCMProtocolMock(@protocol(GMUGeometry));
  id style = OCMClassMock([GMUStyle class]);
  GMUPlacemark *placemark = [[GMUPlacemark alloc] initWithGeometry:geometry
                                                             title:kTitle
                                                           snippet:kSnippet
                                                             style:style
                                                          styleUrl:kStyleUrl];
  XCTAssertEqualObjects(placemark.geometry, geometry);
  XCTAssertEqualObjects(placemark.title, kTitle);
  XCTAssertEqualObjects(placemark.snippet, kSnippet);
  XCTAssertEqualObjects(placemark.style, style);
  XCTAssertEqualObjects(placemark.styleUrl, kStyleUrl);
}

@end
