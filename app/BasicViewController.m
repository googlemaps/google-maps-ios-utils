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

#import "BasicViewController.h"

#import <GoogleMaps/GoogleMaps.h>

#import "Clustering/Algo/GMUGridBasedClusterAlgorithm.h"
#import "Clustering/Algo/GMUNonHierarchicalDistanceBasedAlgorithm.h"
#import "Clustering/GMUClusterManager.h"
#import "Clustering/View/GMUDefaultClusterIconGenerator.h"
#import "Clustering/View/GMUDefaultClusterRenderer.h"
#import "POIItem.h"

static const NSUInteger kClusterItemCount = 10000;
static const double kCameraLatitude = -33.8;
static const double kCameraLongitude = 151.2;

@interface BasicViewController ()<GMUClusterManagerDelegate, GMSMapViewDelegate,
                                  GMUClusterRendererDelegate>
@end

typedef NS_ENUM(NSInteger, ClusterAlgorithmMode) {
  kClusterAlgorithmGridBased,
  kClusterAlgorithmQuadTreeBased,
};

@implementation BasicViewController {
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

  id<GMUClusterAlgorithm> algorithm = [self algorithmForMode:kClusterAlgorithmQuadTreeBased];
  id<GMUClusterIconGenerator> iconGenerator = [self defaultIconGenerator];
  GMUDefaultClusterRenderer *renderer =
      [[GMUDefaultClusterRenderer alloc] initWithMapView:_mapView
                                    clusterIconGenerator:iconGenerator];
  renderer.delegate = self;
  _clusterManager =
      [[GMUClusterManager alloc] initWithMap:_mapView algorithm:algorithm renderer:renderer];

  // Generate and add random items to the cluster manager.
  [self generateClusterItems];

  // Call cluster() after items have been added to perform the clustering and rendering on map.
  [_clusterManager cluster];

  // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
  [_clusterManager setDelegate:self mapDelegate:self];

  UIBarButtonItem *removeButton =
      [[UIBarButtonItem alloc] initWithTitle:@"Remove"
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(removeClusterManager)];
  self.navigationItem.rightBarButtonItems = @[ removeButton ];
}

#pragma mark GMUClusterManagerDelegate

// Zooms in on the cluster being tapped.
- (BOOL)clusterManager:(GMUClusterManager *)clusterManager didTapCluster:(id<GMUCluster>)cluster {
  GMSCameraPosition *newCamera =
      [GMSCameraPosition cameraWithTarget:cluster.position zoom:_mapView.camera.zoom + 1];
  GMSCameraUpdate *update = [GMSCameraUpdate setCamera:newCamera];
  [_mapView moveCamera:update];
  return YES;
}

#pragma mark GMSMapViewDelegate

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
  if ([marker.userData isKindOfClass:[POIItem class]]) {
    POIItem *poiItem = marker.userData;
    NSLog(@"Did tap marker for cluster item %@", poiItem.name);
  } else {
    NSLog(@"Did tap a normal marker");
  }
  return NO;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  NSLog(@"Tapped at location: (%lf, %lf)", coordinate.latitude, coordinate.longitude);
}

#pragma mark Private

- (id<GMUClusterIconGenerator>)defaultIconGenerator {
  return [[GMUDefaultClusterIconGenerator alloc] init];
}

- (id<GMUClusterIconGenerator>)iconGeneratorWithImages {
  return [[GMUDefaultClusterIconGenerator alloc] initWithBuckets:@[ @10, @50, @100, @200, @1000 ]
                                                backgroundImages:@[
                                                  [UIImage imageNamed:@"m1"],
                                                  [UIImage imageNamed:@"m2"],
                                                  [UIImage imageNamed:@"m3"],
                                                  [UIImage imageNamed:@"m4"],
                                                  [UIImage imageNamed:@"m5"]
                                                ]];
}

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

- (id<GMUClusterAlgorithm>)algorithmForMode:(ClusterAlgorithmMode)mode {
  switch (mode) {
    case kClusterAlgorithmGridBased:
      return [[GMUGridBasedClusterAlgorithm alloc] init];

    case kClusterAlgorithmQuadTreeBased:
      return [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];

    default:
      assert(false);
      break;
  }
}

- (void)removeClusterManager {
  NSLog(@"Removing cluster manager. Cluster related markers should be cleared.");
  _clusterManager = nil;
}

- (void)renderer:(id<GMUClusterRenderer>)renderer willRenderMarker:(GMSMarker *)marker {
  if ([marker.userData isKindOfClass:[POIItem class]]) {
    POIItem *item = marker.userData;
    marker.title = item.name;
  }
}

@end
