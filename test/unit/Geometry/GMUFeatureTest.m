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

#import "GMUFeature.h"

@interface GMUFeatureTest : XCTestCase
@end

static NSString *const kIdentifier = @"TestFeature";

@implementation GMUFeatureTest

- (void)testInitWithGeometry {
  id geometry = OCMProtocolMock(@protocol(GMUGeometry));
  id boundingBox = OCMClassMock([GMSCoordinateBounds class]);
  NSDictionary *properties = @{@"Key1" : @"Value1", @"Key2" : @"Value2"};
  GMUFeature *feature = [[GMUFeature alloc] initWithGeometry:geometry
                                                  identifier:kIdentifier
                                                  properties:properties
                                                 boundingBox:boundingBox];
  XCTAssertEqual(feature.geometry, geometry);
  XCTAssertEqualObjects(feature.identifier, kIdentifier);
  XCTAssertEqualObjects(feature.properties, properties);
  XCTAssertEqual(feature.boundingBox, boundingBox);
}

@end
