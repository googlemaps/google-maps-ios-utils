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
#import "GMUGeometryCollection.h"
#import "GMULineString.h"
#import "GMUPlacemark.h"
#import "GMUPoint.h"
#import "GMUPolygon.h"

#import "GMUGeometryRenderer+Testing.h"

@interface GMUGeometryRendererTest : XCTestCase
@end

static NSString *const kTitleText = @"Test Title";
static NSString *const kSnippetText = @"Snippet Text";
static NSString *const kStyleId = @"#style";

@implementation GMUGeometryRendererTest {
  GMSMapView *_mapView;
}

- (void)setUp {
  _mapView = OCMClassMock([GMSMapView class]);
}

- (void)testClear {
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(45.123, 90.456);
  GMUPoint *point = [[GMUPoint alloc] initWithCoordinate:position];
  GMUFeature *feature = [[GMUFeature alloc] initWithGeometry:point
                                                  identifier:nil
                                                  properties:nil
                                                 boundingBox:nil];
  NSArray<GMUFeature *> *features = @[ feature ];
  GMUGeometryRenderer *renderer = [[GMUGeometryRenderer alloc] initWithMap:_mapView
                                                                geometries:features];
  [renderer render];
  NSArray *mapOverlays = renderer.mapOverlays;
  XCTAssertEqual(mapOverlays.count, 1);
  [renderer clear];
  mapOverlays = renderer.mapOverlays;
  XCTAssertEqual(mapOverlays.count, 0);
}

- (void)testRenderMarker {
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(45.123, 90.456);
  GMUPoint *point = [[GMUPoint alloc] initWithCoordinate:position];
  GMUStyle *style = [self styleForTest];
  GMUPlacemark *placemark = [[GMUPlacemark alloc] initWithGeometry:point
                                                             title:kTitleText
                                                           snippet:kSnippetText
                                                             style:style
                                                          styleUrl:nil];
  NSArray<GMUPlacemark *> *placemarks = @[ placemark ];
  GMUGeometryRenderer *renderer = [[GMUGeometryRenderer alloc] initWithMap:_mapView
                                                                geometries:placemarks];
  [renderer render];
  NSArray *mapOverlays = renderer.mapOverlays;
  XCTAssertEqual(mapOverlays.count, 1);
  GMSMarker *marker = mapOverlays.firstObject;
  XCTAssertEqual(marker.map, _mapView);
  XCTAssertEqual(marker.position.latitude, position.latitude);
  XCTAssertEqual(marker.position.longitude, position.longitude);
  XCTAssertEqual(marker.rotation, 1.0f);
  XCTAssertEqual(marker.title, kTitleText);
  XCTAssertEqual(marker.snippet, kSnippetText);
}

- (void)testRenderPolyLine {
  CLLocationCoordinate2D firstCoordinate = CLLocationCoordinate2DMake(1.234, -3.456);
  CLLocationCoordinate2D secondCoordinate = CLLocationCoordinate2DMake(5.678, -6.789);
  CLLocationCoordinate2D thirdCoordinate = CLLocationCoordinate2DMake(4.567, -2.345);
  GMSMutablePath *path = [[GMSMutablePath alloc] init];
  [path addCoordinate:firstCoordinate];
  [path addCoordinate:secondCoordinate];
  [path addCoordinate:thirdCoordinate];
  GMULineString *modelLineString = [[GMULineString alloc] initWithPath:path];

  UIColor *strokeColor = [[UIColor alloc] initWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
  GMUStyle *style = [self styleForTest];

  GMUPlacemark *placemark = [[GMUPlacemark alloc] initWithGeometry:modelLineString
                                                             title:kTitleText
                                                           snippet:nil
                                                             style:style
                                                          styleUrl:nil];
  NSArray<GMUPlacemark *> *placemarks = @[ placemark ];
  GMUGeometryRenderer *renderer = [[GMUGeometryRenderer alloc] initWithMap:_mapView
                                                                geometries:placemarks];
  [renderer render];
  NSArray *mapOverlays = renderer.mapOverlays;
  XCTAssertEqual(mapOverlays.count, 1);
  GMSPolyline *polyline = mapOverlays.firstObject;
  XCTAssertEqual(polyline.map, _mapView);
  XCTAssertEqualObjects(polyline.path.encodedPath, path.encodedPath);
  XCTAssertEqual(polyline.title, kTitleText);
  XCTAssertEqualObjects(polyline.strokeColor, strokeColor);
  XCTAssertEqual(polyline.strokeWidth, 1.0f);
}

- (void)testRenderPolygon {
  CLLocationCoordinate2D firstCoord = CLLocationCoordinate2DMake(10, 10);
  CLLocationCoordinate2D secondCoord = CLLocationCoordinate2DMake(20, 10);
  CLLocationCoordinate2D thirdCoord = CLLocationCoordinate2DMake(20, 20);
  CLLocationCoordinate2D fourthCoord = CLLocationCoordinate2DMake(10, 20);
  GMSMutablePath *outerPath = [[GMSMutablePath alloc] init];
  [outerPath addCoordinate:firstCoord];
  [outerPath addCoordinate:secondCoord];
  [outerPath addCoordinate:thirdCoord];
  [outerPath addCoordinate:fourthCoord];
  [outerPath addCoordinate:firstCoord];

  firstCoord = CLLocationCoordinate2DMake(12.5, 12.5);
  secondCoord = CLLocationCoordinate2DMake(17.5, 12.5);
  thirdCoord = CLLocationCoordinate2DMake(17.5, 17.5);
  fourthCoord = CLLocationCoordinate2DMake(12.5, 17.5);
  GMSMutablePath *innerPath = [[GMSMutablePath alloc] init];
  [innerPath addCoordinate:firstCoord];
  [innerPath addCoordinate:secondCoord];
  [innerPath addCoordinate:thirdCoord];
  [innerPath addCoordinate:fourthCoord];
  [innerPath addCoordinate:firstCoord];

  NSArray *paths = @[ outerPath, innerPath ];
  GMUPolygon *modelPolygon = [[GMUPolygon alloc] initWithPaths:paths];
  UIColor *strokeColor = [[UIColor alloc] initWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
  UIColor *fillColor = [[UIColor alloc] initWithRed:0.5f green:0.5f blue:0.5f alpha:0.5f];
  GMUStyle *style = [self styleForTest];

  GMUPlacemark *placemark = [[GMUPlacemark alloc] initWithGeometry:modelPolygon
                                                             title:kTitleText
                                                           snippet:nil
                                                             style:style
                                                          styleUrl:nil];
  NSArray<GMUPlacemark *> *placemarks = @[ placemark ];
  GMUGeometryRenderer *renderer = [[GMUGeometryRenderer alloc] initWithMap:_mapView
                                                                geometries:placemarks];
  [renderer render];
  NSArray *mapOverlays = renderer.mapOverlays;
  XCTAssertEqual(mapOverlays.count, 1);
  GMSPolygon *polygon = mapOverlays.firstObject;
  XCTAssertEqual(polygon.map, _mapView);
  XCTAssertEqualObjects(polygon.path.encodedPath, outerPath.encodedPath);
  XCTAssertEqualObjects(polygon.holes.firstObject.encodedPath, innerPath.encodedPath);
  XCTAssertEqual(polygon.title, kTitleText);
  XCTAssertEqualObjects(polygon.strokeColor, strokeColor);
  XCTAssertEqual(polygon.strokeWidth, 1.0f);
  XCTAssertEqualObjects(polygon.fillColor, fillColor);
}

- (void)testRenderMultiGeometry {
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(45.123, 90.456);
  GMUPoint *firstPoint = [[GMUPoint alloc] initWithCoordinate:position];
  position = CLLocationCoordinate2DMake(12.345, 23.456);
  GMUPoint *secondPoint = [[GMUPoint alloc] initWithCoordinate:position];
  GMUGeometryCollection *geometryCollection =
      [[GMUGeometryCollection alloc] initWithGeometries:@[ firstPoint, secondPoint ]];
  GMUPlacemark *placemark = [[GMUPlacemark alloc] initWithGeometry:geometryCollection
                                                             title:nil
                                                           snippet:nil
                                                             style:nil
                                                          styleUrl:nil];
  NSArray<GMUPlacemark *> *placemarks = @[ placemark ];
  GMUGeometryRenderer *renderer = [[GMUGeometryRenderer alloc] initWithMap:_mapView
                                                                geometries:placemarks
                                                                    styles:nil];
  [renderer render];
  NSArray *mapOverlays = renderer.mapOverlays;
  XCTAssertEqual(mapOverlays.count, 2);
}

- (void)testRenderGeometryWithExternalStyle {
  CLLocationCoordinate2D position = CLLocationCoordinate2DMake(45.123, 90.456);
  GMUPoint *point = [[GMUPoint alloc] initWithCoordinate:position];
  GMUPlacemark *placemark = [[GMUPlacemark alloc] initWithGeometry:point
                                                             title:nil
                                                           snippet:nil
                                                             style:nil
                                                          styleUrl:kStyleId];
  NSArray<GMUPlacemark *> *placemarks = @[ placemark ];
  GMUStyle *style = [self styleForTest];
  NSArray<GMUStyle *> *styles = @[ style ];
  GMUGeometryRenderer *renderer = [[GMUGeometryRenderer alloc] initWithMap:_mapView
                                                                geometries:placemarks
                                                                    styles:styles];
  [renderer render];
  NSArray *mapOverlays = renderer.mapOverlays;
  XCTAssertEqual(mapOverlays.count, 1);
  GMSMarker *marker = mapOverlays.firstObject;
  XCTAssertEqualObjects(marker.map, _mapView);
  XCTAssertEqualObjects(marker.title, kTitleText);
}

- (GMUStyle *)styleForTest {
  UIColor *strokeColor = [[UIColor alloc] initWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
  UIColor *fillColor = [[UIColor alloc] initWithRed:0.5f green:0.5f blue:0.5f alpha:0.5f];
  return [[GMUStyle alloc] initWithStyleID:kStyleId
                               strokeColor:strokeColor
                                 fillColor:fillColor
                                     width:1.0f
                                     scale:0.0f
                                   heading:1.0f
                                    anchor:CGPointZero
                                   iconUrl:nil
                                     title:kTitleText
                                   hasFill:YES
                                 hasStroke:YES];
}

@end
