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

#import "GMUStyle.h"

@interface GMUStyleTest : XCTestCase
@end

static NSString *const kStyleID = @"#test";
static NSString *const kIconUrl = @"test.png";
static NSString *const kTitle = @"Test Placemark";
static const CGFloat kWidth = 1.0f;
static const CGFloat kScale = 1.0f;
static const CGFloat kHeading = 45.0f;
static const BOOL kHasFill = YES;
static const BOOL kHasStroke = YES;
static UIColor *const kStrokeColor = [[UIColor alloc] initWithRed:1.0f
                                                            green:1.0f
                                                             blue:1.0f
                                                            alpha:1.0f];
static UIColor *const kFillColor = [[UIColor alloc] initWithRed:1.0f
                                                          green:0.0f
                                                           blue:0.0f
                                                          alpha:0.5f];
static const CGPoint anchor = {0.5f, 0.5f};

@implementation GMUStyleTest

- (void)testInitWithProperties {
  GMUStyle *style = [[GMUStyle alloc] initWithStyleID:kStyleID
                                          strokeColor:kStrokeColor
                                            fillColor:kFillColor
                                                width:kWidth
                                                scale:kScale
                                              heading:kHeading
                                               anchor:anchor
                                              iconUrl:kIconUrl
                                                title:kTitle
                                              hasFill:kHasFill
                                            hasStroke:kHasStroke];
  XCTAssertEqualObjects(style.styleID, kStyleID);
  XCTAssertEqualObjects(style.strokeColor, kStrokeColor);
  XCTAssertEqualObjects(style.fillColor, kFillColor);
  XCTAssertEqual(style.width, kWidth);
  XCTAssertEqual(style.scale, kScale);
  XCTAssertEqual(style.heading, kHeading);
  XCTAssertEqual(style.anchor.x, anchor.x);
  XCTAssertEqual(style.anchor.y, anchor.y);
  XCTAssertEqualObjects(style.iconUrl, kIconUrl);
  XCTAssertEqualObjects(style.title, kTitle);
  XCTAssertEqual(style.hasFill, kHasFill);
  XCTAssertEqual(style.hasStroke, kHasStroke);
}

@end
