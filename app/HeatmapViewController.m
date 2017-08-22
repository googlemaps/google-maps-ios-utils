/* Copyright (c) 2017 Google Inc.
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

#import "HeatmapViewController.h"

#import <GoogleMaps/GoogleMaps.h>

#import "Heatmap/GMUHeatmapTileLayer.h"
#import "Heatmap/GMUWeightedLatLng.h"

static const NSUInteger kHeatmapItemCount = 10000;
static const double kCameraLatitude = -33.8;
static const double kCameraLongitude = 151.2;

@interface HeatmapViewController ()<GMSMapViewDelegate>
@end

@implementation HeatmapViewController {
  GMSMapView *_mapView;
  GMUHeatmapTileLayer *_heatmap;
}

- (void)loadView {
  GMSCameraPosition *camera =
      [GMSCameraPosition cameraWithLatitude:kCameraLatitude longitude:kCameraLongitude zoom:4];
  _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  self.view = _mapView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _heatmap = [[GMUHeatmapTileLayer alloc] init];
  // Generate and add random items to the heatmap.
  [self generateHeatmapItems];
  _heatmap.map = _mapView;

  UIBarButtonItem *removeButton = [[UIBarButtonItem alloc] initWithTitle:@"Remove"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(removeHeatmap)];
  self.navigationItem.rightBarButtonItems = @[ removeButton ];
}

#pragma mark GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  NSLog(@"Tapped at location: (%lf, %lf)", coordinate.latitude, coordinate.longitude);
}

#pragma mark Private

- (void)generateHeatmapItems {
  const double extent = 0.2;
  NSMutableArray<GMUWeightedLatLng *> *items = [NSMutableArray arrayWithCapacity:kHeatmapItemCount];
  for (int index = 0; index < kHeatmapItemCount; ++index) {
    double lat = kCameraLatitude + extent * [self randomScale];
    double lng = kCameraLongitude + extent * [self randomScale];
    GMUWeightedLatLng *item =
        [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lng)
                                            intensity:1.0];
    items[index] = item;
  }
  _heatmap.weightedData = items;
}

// Returns a random value between -1.0 and 1.0.
- (double)randomScale {
  return (double)arc4random() / UINT32_MAX * 2.0 - 1.0;
}

- (void)removeHeatmap {
  _heatmap.map = nil;
  _heatmap = nil;
}

@end
