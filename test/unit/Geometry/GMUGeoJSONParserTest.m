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

#import "GMUFeature.h"
#import "GMUGeometryCollection.h"
#import "GMULineString.h"
#import "GMUPoint.h"
#import "GMUPolygon.h"

#import "GMUGeoJSONParser.h"

@interface GMUGeoJSONParserTest : XCTestCase
@end

@implementation GMUGeoJSONParserTest

- (NSArray<GMUFeature *> *)featuresWithResource:(NSString *)resource {
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:resource
                                                                    ofType:@"geojson"];
  NSString *file = [[NSString alloc] initWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
  NSData *data = [file dataUsingEncoding:NSUTF8StringEncoding];
  GMUGeoJSONParser *parser = [[GMUGeoJSONParser alloc] initWithData:data];
  [parser parse];
  return parser.features;
}

- (void)testInitWithURL {
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"GeoJSON_Point_Test"
                                                                    ofType:@"geojson"];
  NSURL *url = [NSURL fileURLWithPath:path];
  GMUGeoJSONParser *parser = [[GMUGeoJSONParser alloc] initWithURL:url];
  [parser parse];
  XCTAssertEqual(parser.features.count, 1);
}

- (void)testInitWithStream {
  NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"GeoJSON_Point_Test"
                                                                    ofType:@"geojson"];
  NSString *file = [[NSString alloc] initWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
  NSData *data = [file dataUsingEncoding:NSUTF8StringEncoding];
  NSInputStream *stream = [[NSInputStream alloc] initWithData:data];
  GMUGeoJSONParser *parser = [[GMUGeoJSONParser alloc] initWithStream:stream];
  [parser parse];
  XCTAssertEqual(parser.features.count, 1);
}

- (void)testParsePoint {
  NSArray<GMUFeature *> *features = [self featuresWithResource:@"GeoJSON_Point_Test"];
  XCTAssertEqual(features.count, 1);
  GMUPoint *point = features.firstObject.geometry;
  XCTAssertEqual(point.coordinate.latitude, 0.5);
  XCTAssertEqual(point.coordinate.longitude, 102.0);
}

- (void)testParseLineString {
  NSArray<GMUFeature *> *features = [self featuresWithResource:@"GeoJSON_LineString_Test"];
  XCTAssertEqual(features.count, 1);
  GMSMutablePath *path = [[GMSMutablePath alloc] init];
  [path addLatitude:0.0 longitude:102.0];
  [path addLatitude:1.0 longitude:103.0];
  GMULineString *lineString = features.firstObject.geometry;
  XCTAssertEqualObjects(lineString.path.encodedPath, path.encodedPath);
}

- (void)testParsePolygon {
  NSArray<GMUFeature *> *features = [self featuresWithResource:@"GeoJSON_Polygon_Test"];
  XCTAssertEqual(features.count, 1);
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
  GMUPolygon *polygon = features.firstObject.geometry;
  XCTAssertEqualObjects(polygon.paths.firstObject.encodedPath, outerPath.encodedPath);
  XCTAssertEqualObjects(polygon.paths.lastObject.encodedPath, innerPath.encodedPath);
}

- (void)testParseMultiPoint {
  NSArray<GMUFeature *> *features = [self featuresWithResource:@"GeoJSON_MultiPoint_Test"];
  XCTAssertEqual(features.count, 1);
  GMUGeometryCollection *points = features.firstObject.geometry;
  GMUPoint *firstPoint = points.geometries.firstObject;
  GMUPoint *secondPoint = points.geometries.lastObject;
  XCTAssertEqual(firstPoint.coordinate.latitude, 0.0);
  XCTAssertEqual(firstPoint.coordinate.longitude, 100.0);
  XCTAssertEqual(secondPoint.coordinate.latitude, 1.0);
  XCTAssertEqual(secondPoint.coordinate.longitude, 101.0);
}

- (void)testParseMultiLineString {
  NSArray<GMUFeature *> *features = [self featuresWithResource:@"GeoJSON_MultiLineString_Test"];
  XCTAssertEqual(features.count, 1);
  GMUGeometryCollection *lineStrings = features.firstObject.geometry;
  GMULineString *firstLineString = lineStrings.geometries.firstObject;
  GMULineString *secondLineString = lineStrings.geometries.lastObject;
  GMSMutablePath *firstPath = [[GMSMutablePath alloc] init];
  [firstPath addLatitude:0.0 longitude:100.0];
  [firstPath addLatitude:1.0 longitude:101.0];
  GMSMutablePath *secondPath = [[GMSMutablePath alloc] init];
  [secondPath addLatitude:2.0 longitude:102.0];
  [secondPath addLatitude:3.0 longitude:103.0];
  XCTAssertEqualObjects(firstLineString.path.encodedPath, firstPath.encodedPath);
  XCTAssertEqualObjects(secondLineString.path.encodedPath, secondPath.encodedPath);
}

- (void)testParseMultiPolygon {
  NSArray<GMUFeature *> *features = [self featuresWithResource:@"GeoJSON_MultiPolygon_Test"];
  XCTAssertEqual(features.count, 1);
  GMUGeometryCollection *polygons = features.firstObject.geometry;
  GMUPolygon *firstPolygon = polygons.geometries.firstObject;
  GMUPolygon *secondPolygon = polygons.geometries.lastObject;
  GMSMutablePath *firstPath = [[GMSMutablePath alloc] init];
  [firstPath addLatitude:2.0 longitude:102.0];
  [firstPath addLatitude:2.0 longitude:103.0];
  [firstPath addLatitude:3.0 longitude:103.0];
  [firstPath addLatitude:3.0 longitude:102.0];
  [firstPath addLatitude:2.0 longitude:102.0];
  GMSMutablePath *secondPath = [[GMSMutablePath alloc] init];
  [secondPath addLatitude:0.0 longitude:100.0];
  [secondPath addLatitude:0.0 longitude:101.0];
  [secondPath addLatitude:1.0 longitude:101.0];
  [secondPath addLatitude:1.0 longitude:100.0];
  [secondPath addLatitude:0.0 longitude:100.0];
  XCTAssertEqualObjects(firstPolygon.paths.firstObject.encodedPath, firstPath.encodedPath);
  XCTAssertEqualObjects(secondPolygon.paths.firstObject.encodedPath, secondPath.encodedPath);
}

- (void)testParseGeometryCollection {
  NSArray<GMUFeature *> *features = [self featuresWithResource:@"GeoJSON_GeometryCollection_Test"];
  XCTAssertEqual(features.count, 1);
  GMUGeometryCollection *geometries = features.firstObject.geometry;
  GMUPoint *point = geometries.geometries.firstObject;
  GMULineString *lineString = geometries.geometries.lastObject;
  GMSMutablePath *path = [[GMSMutablePath alloc] init];
  [path addLatitude:0.0 longitude:101.0];
  [path addLatitude:1.0 longitude:102.0];
  XCTAssertEqual(point.coordinate.latitude, 0.0);
  XCTAssertEqual(point.coordinate.longitude, 100.0);
  XCTAssertEqualObjects(lineString.path.encodedPath, path.encodedPath);
}

- (void)testParseFeature {
  NSArray<GMUFeature *> *features = [self featuresWithResource:@"GeoJSON_Feature_Test"];
  XCTAssertEqual(features.count, 1);
  GMUFeature *feature = features.firstObject;
  GMUPoint *actualPoint = feature.geometry;
  CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(10, 10);
  CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(-10, -10);
  GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                     coordinate:southWest];
  XCTAssertEqualObjects(feature.identifier, @"Test Feature");
  XCTAssertEqualObjects(feature.properties, @{ @"description" : @"A feature for unit testing" });
  XCTAssertEqualObjects(feature.boundingBox, bounds);
  XCTAssertEqual(actualPoint.coordinate.latitude, 0.5);
  XCTAssertEqual(actualPoint.coordinate.longitude, 102.0);
}

- (void)testParseFeatureCollection {
  NSArray<GMUFeature *> *features = [self featuresWithResource:@"GeoJSON_FeatureCollection_Test"];
  XCTAssertEqual(features.count, 2);
  GMUFeature *firstFeature = features.firstObject;
  GMUPoint *point = firstFeature.geometry;
  XCTAssertEqual(point.coordinate.latitude, 0.5);
  XCTAssertEqual(point.coordinate.longitude, 102.0);
  GMUFeature *secondFeature = features.lastObject;
  GMULineString *lineString = secondFeature.geometry;
  GMSMutablePath *path = [[GMSMutablePath alloc] init];
  [path addLatitude:0.0 longitude:102.0];
  [path addLatitude:1.0 longitude:103.0];
  XCTAssertEqualObjects(lineString.path.encodedPath, path.encodedPath);
}

@end
