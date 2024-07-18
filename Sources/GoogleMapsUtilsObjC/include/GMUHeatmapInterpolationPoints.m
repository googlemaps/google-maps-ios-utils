/* Copyright (c) 2024 Google Inc.
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

#import "GMUHeatmapInterpolationPoints.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MKGeometry.h>

@implementation IncorrectInfluence

- (instancetype)initWithDescription:(NSString *)description {
  self = [super initWithDomain:@"com.google.maps.utils" code:1 userInfo:@{NSLocalizedDescriptionKey: description}];
  return self;
}

@end

@implementation GMUHeatmapInterpolationPoints

- (instancetype)initWithClusterIterations:(int)givenClusterIterations {
  self = [super init];
  if (self) {
    _data = [NSMutableArray array];
    _heatmapPoints = [NSMutableArray array];
    _clusterIterations = givenClusterIterations;
    _minLat = -90;
    _maxLat = 90;
    _minLong = -180;
    _maxLong = 180;
  }
  return self;
}

- (void)addWeightedLatLngs:(NSArray<GMUWeightedLatLng *> *)latlngs {
  [_data addObjectsFromArray:latlngs];
}

- (void)addWeightedLatLng:(GMUWeightedLatLng *)latlng {
  [_data addObject:latlng];
}

- (void)removeAllData {
  [_data removeAllObjects];
}

- (double)distanceFromPoint:(CLLocationCoordinate2D)point1 toPoint:(CLLocationCoordinate2D)point2 {
  // The GMSGeometryDistance function returns the distance between two coordinates in meters;
  // according to this source, https://en.wikipedia.org/wiki/Decimal_degrees, conversion from
  // meters to lat/long is around 111.32 kilometers per degree. Starting from this conversion,
  // I manually checked the distance returned by GMSGeometryDistance and the lat/long distance
  // and the normalizingFactor was found accordingly, which is pretty similar to the number
  // found in the source.
  const double normalizingFactor = 111195.0837241998;
  return GMSGeometryDistance(point1, point2) / normalizingFactor;
}

- (CLLocationCoordinate2D)findAverageOfPoints:(NSArray *)points {
  double totalX = 0;
  double totalY = 0;
  double totalZ = 0;
  for (NSValue *pointValue in points) {
    CLLocationCoordinate2D point = [pointValue MKCoordinateValue];
    totalX += cos(point.latitude * M_PI / 180) * cos(point.longitude * M_PI / 180);
    totalY += cos(point.latitude * M_PI / 180) * sin(point.longitude * M_PI / 180);
    totalZ += sin(point.latitude * M_PI / 180);
  }
  totalX /= points.count;
  totalY /= points.count;
  totalZ /= points.count;
  double longitude = atan2(totalY, totalX);
  double central = sqrt(totalY * totalY + totalX * totalX);
  double latitude = atan2(totalZ, central);
  return CLLocationCoordinate2DMake(latitude * 180 / M_PI, longitude * 180 / M_PI);
}

- (NSArray<NSArray *> *)kcluster {
  NSMutableArray *centers = [NSMutableArray array];
  NSMutableArray<NSMutableArray *> *clusters = [NSMutableArray array];

  // Try to make as few clusters as possible; start with 1 and increment as needed
  int numClusters = 1;

  if (_data.count > 0) {
    // We need to keep on finding clusters until the maximum distance between the center
    // and any point in its cluster is under a specific preset value
    while (true) {
      // Set the first numClusters values in data set to be the initial cluster centers
      for (int i = 0; i < numClusters; i++) {
        GMUWeightedLatLng *point = _data[i];
        GMSMapPoint mappoint = {point.point.x, point.point.y};
        CLLocationCoordinate2D normalizedPoint = GMSUnproject(mappoint);
        [centers addObject:[NSValue valueWithMKCoordinate: normalizedPoint]];
        NSMutableArray *tempArray = [NSMutableArray array];
        [clusters addObject:tempArray];
      }

      // 25 iterations of updating the center and recalculating the points in that cluster
      // should be adequate, as k-means clustering has diminishing returns as the number
      // of iterations increases
      for (int _ = 0; _ < _clusterIterations; _++) {
        // Reset the clusters so that it can be updated
        for (int i = 0; i < numClusters; i++) {
          [clusters[i] removeAllObjects];
        }

        // Finds the appropriate cluster for each data point
        for (GMUWeightedLatLng *point in _data) {
          GMSMapPoint mappoint = {point.point.x, point.point.y};
          CLLocationCoordinate2D normalizedPoint = GMSUnproject(mappoint);
          CLLocationCoordinate2D end = [centers[0] MKCoordinateValue];
          double minDistance = [self distanceFromPoint:normalizedPoint toPoint:end];
          int index = 0;
          for (int i = 0; i < centers.count; i++) {
            end = [centers[i] MKCoordinateValue];
            double tempDistance = [self distanceFromPoint:normalizedPoint toPoint:end];
            if (minDistance >= tempDistance) {
              minDistance = tempDistance;
              index = i;
            }
          }
          [clusters[index] addObject:[NSValue valueWithMKCoordinate: normalizedPoint]];
        }

        // Update the center values to reflect new cluster points
        [centers removeAllObjects];
        for (NSMutableArray *cluster in clusters) {
          [centers addObject:[NSValue valueWithMKCoordinate:[self findAverageOfPoints:cluster]]];
        }
      }

      // Test if we can stop increasing the number of clusters
      BOOL breaker = NO;
      for (int i = 0; i < numClusters; i++) {
        for (NSValue *coordValue in clusters[i]) {
          CLLocationCoordinate2D coord = [coordValue MKCoordinateValue];
          CLLocationCoordinate2D start = [centers[i] MKCoordinateValue];
          CLLocationCoordinate2D end = coord;
          double radius = [self distanceFromPoint:start toPoint:end];

          // This is a set bound for the radius of each cluster; radius is defined
          // here as the distance from a point in the cluster to the cluster center.
          // If the radius is over 50 degrees, then the code will refine by creating
          // more clusters; this number can be changed if larger or smaller clusters
          // are desired.
          if (radius > 50) {
            breaker = YES;
            break;
          }
        }
        if (breaker) {
          break;
        }
      }
      if (!breaker) {
        break;
      }
      [clusters removeAllObjects];
      [centers removeAllObjects];
      numClusters += 1;
    }
  }
  return clusters;
}

- (Fraction)findIntensityAtLatitude:(double)latitude longitude:(double)longitude influence:(HeatmapInterpolationInfluence)influence {
  double numerator = 0;
  double denominator = 0;
  for (GMUWeightedLatLng *point in _data) {
    CLLocationCoordinate2D start = CLLocationCoordinate2DMake(latitude, longitude);
    GMSMapPoint mappoint = {point.point.x, point.point.y};
    CLLocationCoordinate2D normalizedPoint = GMSUnproject(mappoint);
    double dist = [self distanceFromPoint:start toPoint:normalizedPoint];
    double distanceWeight = pow(dist, influence);

    if (distanceWeight == 0) {
      continue;
    }
    numerator += (point.intensity / distanceWeight);
    denominator += (1 / distanceWeight);
  }
  Fraction fraction;
  fraction.numerator = numerator;
  fraction.denominator = denominator;
  return fraction;
}

- (NSArray<NSNumber *> *)findBoundsForInput:(NSArray *)input granularity:(double)granularity {
  // Initialize the boundary values to something that must be updated immediately
  // 0: min lat, 1: min long, 2: max lat, 3: max long
  NSMutableArray *ans = [NSMutableArray arrayWithObjects:
                         [NSNumber numberWithInt:INT_MAX],
                         [NSNumber numberWithInt:INT_MAX],
                         [NSNumber numberWithInt:INT_MIN],
                         [NSNumber numberWithInt:INT_MIN], nil];
  for (NSValue *coordValue in input) {
    CLLocationCoordinate2D coord = [coordValue MKCoordinateValue];
    ans[0] = [NSNumber numberWithInt:MIN([[ans objectAtIndex:0] intValue], (int)(coord.latitude * (1 / granularity)))];
    ans[1] = [NSNumber numberWithInt:MIN([[ans objectAtIndex:1] intValue], (int)(coord.longitude * (1 / granularity)))];
    ans[2] = [NSNumber numberWithInt:MAX([[ans objectAtIndex:2] intValue], (int)(coord.latitude * (1 / granularity)))];
    ans[3] = [NSNumber numberWithInt:MAX([[ans objectAtIndex:3] intValue], (int)(coord.longitude * (1 / granularity)))];
  }
  return ans;
}

- (NSArray<GMUWeightedLatLng *> *)generatePointsWithInfluence:(HeatmapInterpolationInfluence)influence granularity:(double)granularity error:(NSError **)error {
  // As documented above, we will throw an exception here if the n value is not in the
  // appropriate range
  if (influence < 2.0 || influence > 2.5) {
    NSErrorDomain domain = @"com.google.maps.utils";
    NSDictionary *userInfo = @{
      NSLocalizedDescriptionKey: @"Incorrect Influence",
      NSLocalizedFailureReasonErrorKey: @"Your influence value is not between 2 and 2.5",
    };
    *error = [[IncorrectInfluence alloc] initWithDescription:@"Your influence value is not between 2 and 2.5"];
    return nil;
  }

  [_heatmapPoints removeAllObjects];

  // Clusters is the list of clusters that we intend to return
  NSArray<NSArray *> *clusters = [self kcluster];

  for (NSArray *cluster in clusters) {
    NSArray<NSNumber *> *bounds = [self findBoundsForInput:cluster granularity:granularity];

    // A small n-value implies a large range of points that could be potentially be
    // affected, so it makes sense to increase the stride to improve runtime and the range
    // to improve the quality of the heat map
    const int step = 3;

    // These two values bound the search range of the heat map; any larger range provides
    // marginal improvements, if any, in the resulting heat map, as found via trial and
    // error and testing with various data sets
    const int latRange = (int)(15 / granularity);
    const int longRange = (int)(20 / granularity);

    // Search all the points between the bounds of the cluster; the offset indicates how
    // far beyond the bounds we want to query
    for (int i = [[bounds objectAtIndex:0] intValue] - latRange; i <= [[bounds objectAtIndex:2] intValue] + latRange; i += step) {
      // Since latitude ranges from -90 to 90 and the granularity is 0.1, we can move from
      // -900 to 900
      if (i * granularity > _maxLat || i * granularity < _minLat) {
        break;
      }
      for (int j = [[bounds objectAtIndex:1] intValue] - longRange; j <= [[bounds objectAtIndex:3] intValue] + longRange; j += step) {
        // Since longitude ranges from -180 to 180 and the granularity is 0.1, we can
        // move from -1800 to 1800
        if (j * granularity > _maxLong || j * granularity < _minLong) {
          break;
        }

        // The variable, intensity, contains the numerator and denominator
        Fraction intensity = [self findIntensityAtLatitude:i * granularity longitude:j * granularity influence:influence];
        // If the numerator value is too small, that point is worthless as it is too
        // far away or too weak; if the denominator is 0, we get a divide by 0 error
        if (intensity.denominator == 0 || intensity.numerator < 3) {
          continue;
        }

        // Set the intensity based on IDW
        GMUWeightedLatLng *coords =
        [[GMUWeightedLatLng alloc] initWithCoordinate:CLLocationCoordinate2DMake(i * granularity, j * granularity)
                                            intensity:intensity.numerator / intensity.denominator];
        [_heatmapPoints addObject:coords];
      }
    }
  }
  return _heatmapPoints;
}

- (NSArray<GMUWeightedLatLng *> *)generatePointsWithInfluence:(HeatmapInterpolationInfluence)influence 
                                                                  error:(NSError **)error {
  [self generatePointsWithInfluence:influence granularity:0.1 error:error];
}

@end
