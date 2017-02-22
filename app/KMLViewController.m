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

#import "KMLViewController.h"

#import <GoogleMaps/GoogleMaps.h>

#import "GMUKMLParser.h"
#import "GMUGeometryRenderer.h"

static const double kCameraLatitude = 37.4220;
static const double kCameraLongitude = -122.0841;

@implementation KMLViewController {
  GMSMapView *_mapView;
}

- (void)loadView {
  GMSCameraPosition *camera =
      [GMSCameraPosition cameraWithLatitude:kCameraLatitude longitude:kCameraLongitude zoom:17];
  _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  self.view = _mapView;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *path = [[NSBundle mainBundle] pathForResource:@"KML_Sample" ofType:@"kml"];
  NSURL *url = [NSURL fileURLWithPath:path];
  GMUKMLParser *parser = [[GMUKMLParser alloc] initWithURL:url];
  [parser parse];
  GMUGeometryRenderer *renderer = [[GMUGeometryRenderer alloc] initWithMap:_mapView
                                                                geometries:parser.placemarks
                                                                    styles:parser.styles];
  [renderer render];
}

@end
