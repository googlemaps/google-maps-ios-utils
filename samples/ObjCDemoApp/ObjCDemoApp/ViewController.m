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

#import "ViewController.h"

#import <GoogleMaps/GoogleMaps.h>
@import GoogleMapsUtils;

// Point of Interest Item which implements the GMUClusterItem protocol.
@interface POIItem : NSObject<GMUClusterItem>

@property(nonatomic, readonly) CLLocationCoordinate2D position;
@property(nonatomic, readonly) NSString *name;

- (instancetype)initWithPosition:(CLLocationCoordinate2D)position name:(NSString *)name;

@end

@implementation POIItem

- (instancetype)initWithPosition:(CLLocationCoordinate2D)position name:(NSString *)name {
  if ((self = [super init])) {
    _position = position;
    _name = [name copy];
  }
  return self;
}

@end

static const NSUInteger kClusterItemCount = 10000;
static const double kCameraLatitude = -33.8;
static const double kCameraLongitude = 151.2;

@interface ViewController ()<GMSMapViewDelegate>
@end

@implementation ViewController {
  GMSMapView *_mapView;
  GMUClusterManager *_clusterManager;
}

- (void)loadView {
  GMSCameraPosition *camera =
      [GMSCameraPosition cameraWithLatitude:kCameraLatitude longitude:kCameraLongitude zoom:10];
  GMSMapViewOptions *options = [[GMSMapViewOptions alloc] init];
  options.camera = camera;
  _mapView = [[GMSMapView alloc] initWithOptions:options];
  self.view = _mapView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Set up the cluster manager with default icon generator and renderer.
  id<GMUClusterAlgorithm> algorithm = [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
  id<GMUClusterIconGenerator> iconGenerator = [[GMUDefaultClusterIconGenerator alloc] init];
  id<GMUClusterRenderer> renderer =
      [[GMUDefaultClusterRenderer alloc] initWithMapView:_mapView
                                    clusterIconGenerator:iconGenerator];
  _clusterManager =
      [[GMUClusterManager alloc] initWithMap:_mapView algorithm:algorithm renderer:renderer];

  // Register self to listen to GMSMapViewDelegate events.
  [_clusterManager setMapDelegate:self];
  
  // Generate and add random items to the cluster manager.
  [self generateClusterItems];

  // Call cluster() after items have been added to perform the clustering and rendering on map.
  [_clusterManager cluster];
}

#pragma mark GMSMapViewDelegate

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
  [_mapView animateToLocation:marker.position];
  if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
    [_mapView animateToZoom:_mapView.camera.zoom +1];
    NSLog(@"Did tap marker cluster");
    return YES;
  }
  NSLog(@"Did tap marker");
  return NO;
}

#pragma mark Private

// Randomly generates cluster items within some extent of the camera and adds them to the
// cluster manager.
- (void)generateClusterItems {
  const double extent = 0.2;
  for (int index = 1; index <= kClusterItemCount; ++index) {
    double lat = kCameraLatitude + extent * [self randomScale];
    double lng = kCameraLongitude + extent * [self randomScale];
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat, lng);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    [_clusterManager addItem:marker];
  }
}

// Returns a random value between -1.0 and 1.0.
- (double)randomScale {
  return (double)arc4random() / UINT32_MAX * 2.0 - 1.0;
}

@end
