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

#import "CustomMarkerViewController.h"

#import <GoogleMaps/GoogleMaps.h>

#import "Clustering/Algo/GMUGridBasedClusterAlgorithm.h"
#import "Clustering/Algo/GMUNonHierarchicalDistanceBasedAlgorithm.h"
#import "Clustering/GMUClusterManager.h"
#import "Clustering/View/GMUDefaultClusterIconGenerator.h"
#import "Clustering/View/GMUDefaultClusterRenderer.h"

static const double kCameraLatitude = -33.8;
static const double kCameraLongitude = 151.2;
static const int kImageDimension = 30;

@interface Person : NSObject<GMUClusterItem>

@property(nonatomic) CLLocationCoordinate2D position;
@property(nonatomic) NSString *imageUrl;

// Used to store the image after downloaded.
@property(nonatomic) UIImage *cachedImage;

+ (instancetype)personWithPosition:(CLLocationCoordinate2D)position imageUrl:(NSString *)url;

@end

@implementation Person

+ (instancetype)personWithPosition:(CLLocationCoordinate2D)position imageUrl:(NSString *)url {
  Person *person = [[Person alloc] init];
  person.position = position;
  person.imageUrl = url;
  return person;
}

@end

@interface ClusterRenderer : GMUDefaultClusterRenderer
@end

@implementation ClusterRenderer

// Show as a cluster for clusters whose size is >= 2.
- (BOOL)shouldRenderAsCluster:(id<GMUCluster>)cluster atZoom:(float)zoom {
  return cluster.count >= 2;
}

@end

@interface CustomMarkerViewController ()<GMUClusterRendererDelegate>
@end

@implementation CustomMarkerViewController {
  GMSMapView *_mapView;
  GMUClusterManager *_clusterManager;
}

- (NSArray<Person *> *)randomPeople {
  return @[
    // http://www.flickr.com/photos/sdasmarchives/5036248203/
    [Person personWithPosition:CLLocationCoordinate2DMake(-33.8, 151.2)
                      imageUrl:@"https://c1.staticflickr.com/5/4125/5036248253_e405cc6961_s.jpg"],
    // http://www.flickr.com/photos/usnationalarchives/4726917149/
    [Person personWithPosition:CLLocationCoordinate2DMake(-33.82, 151.1)
                      imageUrl:@"https://c2.staticflickr.com/2/1350/4726917149_2a7e7c579e_s.jpg"],
    // http://www.flickr.com/photos/nypl/3111525394/
    [Person personWithPosition:CLLocationCoordinate2DMake(-33.9, 151.15)
                      imageUrl:@"https://c2.staticflickr.com/4/3101/3111525394_737eaf0dfd_s.jpg"],
    // http://www.flickr.com/photos/smithsonian/2887433330/
    [Person personWithPosition:CLLocationCoordinate2DMake(-33.91, 151.05)
                      imageUrl:@"https://c2.staticflickr.com/4/3288/2887433330_7e7ed360b1_s.jpg"],
    // http://www.flickr.com/photos/library_of_congress/2179915182/
    [Person personWithPosition:CLLocationCoordinate2DMake(-33.7, 151.06)
                      imageUrl:@"https://c1.staticflickr.com/3/2405/2179915182_5a0ac98b49_s.jpg"],
    // http://www.flickr.com/photos/nationalmediamuseum/7893552556/
    [Person personWithPosition:CLLocationCoordinate2DMake(-33.5, 151.18)
                      imageUrl:@"https://c1.staticflickr.com/9/8035/7893552556_3351c8a168_s.jpg"],
    // http://www.flickr.com/photos/sdasmarchives/5036231225/
    [Person personWithPosition:CLLocationCoordinate2DMake(-34.0, 151.18)
                      imageUrl:@"https://c1.staticflickr.com/5/4125/5036231225_549f804980_s.jpg"],
  ];
}

- (void)loadView {
  GMSCameraPosition *camera =
      [GMSCameraPosition cameraWithLatitude:kCameraLatitude longitude:kCameraLongitude zoom:10];
  _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
  self.view = _mapView;

  id<GMUClusterAlgorithm> algorithm = [[GMUNonHierarchicalDistanceBasedAlgorithm alloc] init];
  id<GMUClusterIconGenerator> iconGenerator = [[GMUDefaultClusterIconGenerator alloc] init];
  ClusterRenderer *renderer =
      [[ClusterRenderer alloc] initWithMapView:_mapView clusterIconGenerator:iconGenerator];
  renderer.delegate = self;
  _clusterManager =
      [[GMUClusterManager alloc] initWithMap:_mapView algorithm:algorithm renderer:renderer];

  // Add people to the cluster manager.
  for (Person *person in [self randomPeople]) {
    [_clusterManager addItem:person];
  }

  // Call cluster() after items have been added to perform the clustering and rendering on map.
  [_clusterManager cluster];
}

- (void)renderer:(id<GMUClusterRenderer>)renderer willRenderMarker:(GMSMarker *)marker {
  if ([marker.userData isKindOfClass:[Person class]]) {
    Person *person = (Person *)marker.userData;
    marker.title = person.imageUrl;
    marker.icon = [self imageForItem:person];
    // Center the marker at the center of the image.
    marker.groundAnchor = CGPointMake(0.5, 0.5);
  } else if ([marker.userData conformsToProtocol:@protocol(GMUCluster)]) {
    marker.icon = [self imageForCluster:marker.userData];
  }
}

// Returns an image representing the cluster item marker.
- (UIImage *)imageForItem:(id<GMUClusterItem>)item {
  Person *person = (Person *)item;
  if (person.cachedImage == nil) {
    // Note: synchronously download and resize the image. Ideally the image should either be cached
    // already or the download should happens asynchronously.
    person.cachedImage = [self imageWithContentsOfURL:person.imageUrl
                                                 size:CGSizeMake(kImageDimension, kImageDimension)];
  }
  return person.cachedImage;
}

// Returns an image representing the cluster marker. Only takes a maximum of 4
// items in the cluster to create the mashed up image.
- (UIImage *)imageForCluster:(id<GMUCluster>)cluster {
  NSArray *items = cluster.items;
  NSMutableArray<UIImage *> *images = [NSMutableArray array];
  for (int i = 0; i < items.count; i++) {
    [images addObject:[self imageForItem:items[i]]];
    if (i >= 4) {
      break;
    }
  }
  return [self imageFromImages:images size:CGSizeMake(kImageDimension * 2, kImageDimension * 2)];
}

// Returns a new image with half the width of the original.
- (UIImage *)halfOfImage:(UIImage *)image {
  CGFloat scale = image.scale;
  CGFloat width = image.size.width * scale;
  CGFloat height = image.size.height * scale;
  CGRect rect = CGRectMake(width / 4, 0, width / 2, height);
  CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
  UIImage *newImage =
      [UIImage imageWithCGImage:imageRef scale:scale orientation:image.imageOrientation];
  CGImageRelease(imageRef);
  return newImage;
}

// Mashes up the images.
- (UIImage *)imageFromImages:(NSArray<UIImage *> *)images size:(CGSize)size {
  if (images.count <= 1) {
    return images.firstObject;
  }

  UIGraphicsBeginImageContextWithOptions(size, YES, 0);
  if (images.count == 2 || images.count == 3) {
    // Draw left half.
    [images[0] drawInRect:CGRectMake(-size.width / 4, 0, size.width, size.height)];
  }

  if (images.count == 2) {
    // Draw right half.
    UIImage *halfOfImage2 = [self halfOfImage:images[1]];
    [halfOfImage2 drawInRect:CGRectMake(size.width / 2, 0, size.width / 2, size.height)];
  } else {
    // Draw top right quadrant.
    [images[1] drawInRect:CGRectMake(size.width / 2, 0, size.width / 2, size.height / 2)];
    // Draw bottom right quadrant.
    [images[2]
        drawInRect:CGRectMake(size.width / 2, size.height / 2, size.width / 2, size.height / 2)];
  }
  if (images.count >= 4) {
    // Draw top left quadrant.
    [images[0] drawInRect:CGRectMake(0, 0, size.width / 2, size.height / 2)];
    // Draw bottom left quadrant.
    [images[3] drawInRect:CGRectMake(0, size.height / 2, size.width / 2, size.height / 2)];
  }
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

// Downloads and resize an image.
- (UIImage *)imageWithContentsOfURL:(NSString *)url size:(CGSize)size {
  NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
  UIImage *image = [UIImage imageWithData:data];
  UIGraphicsBeginImageContextWithOptions(size, YES, 0);
  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

@end
