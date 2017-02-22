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

#import "GMUGeometryCollection.h"
#import "GMUGroundOverlay.h"
#import "GMULineString.h"
#import "GMUPlacemark.h"
#import "GMUPoint.h"
#import "GMUPolygon.h"
#import "GMUStyle.h"

#import "GMUKMLParser.h"

@interface GMUKMLParserTest : XCTestCase
@end

@implementation GMUKMLParserTest

- (GMUKMLParser *)parserWithResource:(NSString *)resource {
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:resource
                                                                    ofType:@"kml"];
  NSString *file = [[NSString alloc] initWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
  NSData *data = [file dataUsingEncoding:NSUTF8StringEncoding];
  GMUKMLParser *parser = [[GMUKMLParser alloc] initWithData:data];
  [parser parse];
  return parser;
}

- (NSArray<GMUPlacemark *> *)placemarksWithResource:(NSString *)resource {
  return [self parserWithResource:resource].placemarks;
}

- (NSArray<GMUStyle *> *)stylesWithResource:(NSString *)resource {
  return [self parserWithResource:resource].styles;
}


- (void)testInitWithURL {
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"KML_Point_Test"
                                                                    ofType:@"kml"];
  NSURL *url = [NSURL fileURLWithPath:path];
  GMUKMLParser *parser = [[GMUKMLParser alloc] initWithURL:url];
  [parser parse];
  XCTAssertEqual(parser.placemarks.count, 1);
  }

- (void)testInitWithStream {
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"KML_Point_Test"
                                                                    ofType:@"kml"];
  NSString *file = [[NSString alloc] initWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
  NSData *data = [file dataUsingEncoding:NSUTF8StringEncoding];
  NSInputStream *stream = [[NSInputStream alloc] initWithData:data];
  GMUKMLParser *parser = [[GMUKMLParser alloc] initWithStream:stream];
  [parser parse];
  XCTAssertEqual(parser.placemarks.count, 1);
}

- (void)testParsePoint {
  NSArray<GMUPlacemark *> *placemarks = [self placemarksWithResource:@"KML_Point_Test"];
  XCTAssertEqual(placemarks.count, 1);
  GMUPoint *point = placemarks.firstObject.geometry;
  XCTAssertEqual(point.coordinate.latitude, 0.5);
  XCTAssertEqual(point.coordinate.longitude, 102.0);
}

- (void)testParseLineString {
  NSArray<GMUPlacemark *> *placemarks = [self placemarksWithResource:@"KML_LineString_Test"];
  XCTAssertEqual(placemarks.count, 1);
  GMSMutablePath *path = [[GMSMutablePath alloc] init];
  [path addLatitude:0.0 longitude:102.0];
  [path addLatitude:1.0 longitude:103.0];
  GMULineString *lineString = placemarks.firstObject.geometry;
  XCTAssertEqualObjects(lineString.path.encodedPath, path.encodedPath);
}

- (void)testParsePolygon {
  NSArray<GMUPlacemark *> *placemarks = [self placemarksWithResource:@"KML_Polygon_Test"];
  XCTAssertEqual(placemarks.count, 1);
  GMSMutablePath *outerPath = [[GMSMutablePath alloc] init];
  [outerPath addLatitude:10 longitude:10];
  [outerPath addLatitude:20 longitude:10];
  [outerPath addLatitude:20 longitude:20];
  [outerPath addLatitude:10 longitude:20];
  [outerPath addLatitude:10 longitude:10];
  GMSMutablePath *innerPath = [[GMSMutablePath alloc] init];
  [innerPath addLatitude:12.5 longitude:12.5];
  [innerPath addLatitude:17.5 longitude:12.5];
  [innerPath addLatitude:17.5 longitude:17.5];
  [innerPath addLatitude:12.5 longitude:17.5];
  [innerPath addLatitude:12.5 longitude:12.5];
  GMUPolygon *polygon = placemarks.firstObject.geometry;
  XCTAssertEqualObjects(polygon.paths.firstObject.encodedPath, outerPath.encodedPath);
  XCTAssertEqualObjects(polygon.paths.lastObject.encodedPath, innerPath.encodedPath);
}

- (void)testParseGroundOverlay {
  NSArray<GMUPlacemark *> *placemarks = [self placemarksWithResource:@"KML_GroundOverlay_Test"];
  XCTAssertEqual(placemarks.count, 1);
  GMUGroundOverlay *groundOverlay = placemarks.firstObject.geometry;
  XCTAssertEqual(groundOverlay.northEast.latitude, 10);
  XCTAssertEqual(groundOverlay.northEast.longitude, 10);
  XCTAssertEqual(groundOverlay.southWest.latitude, -10);
  XCTAssertEqual(groundOverlay.southWest.longitude, -10);
  XCTAssertEqual(groundOverlay.zIndex, 1);
  XCTAssertEqual(groundOverlay.rotation, 315.0);
  XCTAssertEqualObjects(groundOverlay.href, @"https://www.google.com/intl/en/images/logo.gif");
}

- (void)testParseMultiGeometry {
  NSArray<GMUPlacemark *> *placemarks = [self placemarksWithResource:@"KML_MultiGeometry_Test"];
  XCTAssertEqual(placemarks.count, 1);
  GMUGeometryCollection *points = placemarks.firstObject.geometry;
  GMUPoint *firstPoint = points.geometries.firstObject;
  GMUPoint *secondPoint = points.geometries.lastObject;
  XCTAssertEqual(firstPoint.coordinate.latitude, 1.0);
  XCTAssertEqual(firstPoint.coordinate.longitude, 10.0);
  XCTAssertEqual(secondPoint.coordinate.latitude, 2.0);
  XCTAssertEqual(secondPoint.coordinate.longitude, 20.0);
}

- (void)testParseStyle {
  NSArray<GMUStyle *> *styles = [self stylesWithResource:@"KML_Style_Test"];
  XCTAssertEqual(styles.count, 1);
  UIColor *strokeColor = [[UIColor alloc] initWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
  UIColor *fillColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
  GMUStyle *style = styles.firstObject;
  XCTAssertEqualObjects(style.styleID, @"#Test Style");
  XCTAssertEqualObjects(style.strokeColor, strokeColor);
  XCTAssertEqualObjects(style.fillColor, fillColor);
  XCTAssertEqual(style.width, 5);
  XCTAssertEqual(style.scale, 2.5);
  XCTAssertEqual(style.heading, 45.0);
  XCTAssertEqual(style.anchor.x, 0.25);
  XCTAssertEqual(style.anchor.y, 0.75);
  XCTAssertEqualObjects(style.iconUrl, @"https://maps.google.com/mapfiles/kml/pal3/icon55.png");
  XCTAssertEqualObjects(style.title, @"A Point title");
  XCTAssertTrue(style.hasFill);
  XCTAssertTrue(style.hasStroke);
}


- (void)testParsePlacemark {
  NSArray<GMUPlacemark *> *placemarks = [self placemarksWithResource:@"KML_Placemark_Test"];
  XCTAssertEqual(placemarks.count, 1);
  GMUPlacemark *placemark = placemarks.firstObject;
  XCTAssertEqualObjects(placemark.title, @"Test Placemark");
  XCTAssertEqualObjects(placemark.snippet, @"A Placemark for testing purposes.");
  XCTAssertEqualObjects(placemark.styleUrl, @"#exampleStyle");
}

@end
