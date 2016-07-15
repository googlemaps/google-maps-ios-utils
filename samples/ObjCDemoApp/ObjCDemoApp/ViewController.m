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

#import <Google-Maps-iOS-Utils/GMUMarkerClustering.h>
#import <GoogleMaps/GoogleMaps.h>

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

@interface ViewController ()<GMUClusterManagerDelegate, GMSMapViewDelegate>
@end

@implementation ViewController {
  GMSMapView *_mapView;
  GMUClusterManager *_clusterManager;
}

- (void)loadView {
  GMSCameraPosition *camera =
      [GMSCameraPosition cameraWithLatitude:kCameraLatitude longitude:kCameraLongitude zoom:10];
  _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
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

  // Generate and add random items to the cluster manager.
  [self generateClusterItems];

  // Call cluster() after items have been added to perform the clustering and rendering on map.
  [_clusterManager cluster];

  // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
  [_clusterManager setDelegate:self mapDelegate:self];
}

#pragma mark GMUClusterManagerDelegate

- (void)clusterManager:(GMUClusterManager *)clusterManager didTapCluster:(id<GMUCluster>)cluster {
  GMSCameraPosition *newCamera =
      [GMSCameraPosition cameraWithTarget:cluster.position zoom:_mapView.camera.zoom + 1];
  GMSCameraUpdate *update = [GMSCameraUpdate setCamera:newCamera];
  [_mapView moveCamera:update];
}

#pragma mark GMSMapViewDelegate

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
  POIItem *poiItem = marker.userData;
  if (poiItem != nil) {
    NSLog(@"Did tap marker for cluster item %@", poiItem.name);
  } else {
    NSLog(@"Did tap a normal marker");
  }
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
    NSString *name = [NSString stringWithFormat:@"Item %d", index];
    id<GMUClusterItem> item =
        [[POIItem alloc] initWithPosition:CLLocationCoordinate2DMake(lat, lng) name:name];
    [_clusterManager addItem:item];
  }
}

// Returns a random value between -1.0 and 1.0.
- (double)randomScale {
  return (double)arc4random() / UINT32_MAX * 2.0 - 1.0;
}

@end
