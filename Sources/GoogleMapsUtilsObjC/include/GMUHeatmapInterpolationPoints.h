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

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

#import "GMUWeightedLatLng.h"

/// A simple fraction class; the main use case is for finding intensity values, which are represented as fractions
typedef struct {
  double numerator;
  double denominator;
} Fraction;

NS_ASSUME_NONNULL_BEGIN

/// This class will create artificial points in surrounding locations with appropriate intensities interpolated by neighboring intensity values.
/// The algorithm used for this class is heavily inspired by inverse distance weights to figure out intensities and k-means clustering to
/// both improve the heat map search bounds as well as the runtime.
/// IDW: https://mgimond.github.io/Spatial/spatial-interpolation.html
/// Clustering: https://towardsdatascience.com/the-5-clustering-algorithms-data-scientists-need-to-know-a36d136ef68
@interface GMUHeatmapInterpolationPoints : NSObject

/// The input data set
@property (nonatomic, strong) NSMutableArray<GMUWeightedLatLng *> *data;

/// The list of interpolated heat map points with weight
@property (nonatomic, strong) NSMutableArray<GMUWeightedLatLng *> *heatmapPoints;

/// Since IDW takes into account the distance an interpolated point is from the given points, it naturally begs the question: how
/// much should distance affect the interpolated value? If we don't want distance to affect interpolated values at all (which is not a
/// good idea since one point will span the entire globe) then this value can be set to 1 and if you want distances to be highly
/// influential, set this value to something like 4 or 5. This is because the average of given intensities is normalized by a given point's
/// distance to the interpolated point, raised to this power. When you have a large HeatmapInterpolationInfluence value, each
/// each increase in distance has a much bigger impact (e.g. 3^2 = 9 and 4^2 = 16, but 3^10 = 59,049 and 4^10 = 1,048,576). In
/// the articles I researched, the optimal range is between 2 and 2.5, so this value must always be between 2 and 2.5.
typedef double HeatmapInterpolationInfluence;

/// Indicates the number of times k-means clustering should execute; will be set in the constructor to 25 by default
@property (nonatomic, assign) int clusterIterations;

/// Firm bounds on all search queries, as latitude ranges from -90 to 90 and longitude ranges from -180 to 180
@property (nonatomic, assign) double minLat;
@property (nonatomic, assign) double maxLat;
@property (nonatomic, assign) double minLong;
@property (nonatomic, assign) double maxLong;

/// The constructor to this class
///
/// - Parameter givenClusterIterations: The number of iterations k-means clustering should go to.
- (instancetype)initWithClusterIterations:(int)givenClusterIterations NS_SWIFT_NAME(init(givenClusterIterations:));

// MARK: Functions that parse given data needed to build an interpolated heat map from

/// Adds a list of GMUWeightedLatLng objects to the input data set
///
/// - Parameter latlngs: The list of GMUWeightedLatLng objects to add.
- (void)addWeightedLatLngs:(NSArray<GMUWeightedLatLng *> *)latlngs NS_SWIFT_NAME(addWeightedLatLngs(latlngs:));

/// Adds a single GMUWeightedLatLng object to the input data set
///
/// - Parameter latlngs: The list of GMUWeightedLatLng objects to add.
- (void)addWeightedLatLng:(GMUWeightedLatLng *)latlng NS_SWIFT_NAME(addWeightedLatLng(latlng:));

/// Removes all previously supplied GMUWeightedLatLng objects
- (void)removeAllData;

// MARK: Functions that directly contribute to the creation of interpolated points

/// A helper function that calculates the straight-line distance between two coordinates
///
/// - Parameters:
///   - point1: The point that we want to find the distance from.
///   - point2: The point that we want to find the distance to.
/// - Returns: A double value representing the distance between the given points.
- (double)distanceFromPoint:(CLLocationCoordinate2D)point1 toPoint:(CLLocationCoordinate2D)point2 NS_SWIFT_NAME(distance(point1:point2:));

/// Finds the average latitude and longitude values; see http://mathforum.org/library/drmath/view/63491.html
///
/// - Parameter points: The list of points to take the average from.
/// - Returns: A CLLocationCoordinate2D object resembling the average value.
- (CLLocationCoordinate2D)findAverageOfPoints:(NSArray *)points NS_SWIFT_NAME(findAverage(points:));

/// A helper function that utilizes the k-cluster algorithm to cluster the input data points together into reasonable sets; the number of
/// clusters is set so that the maximum distance between the center and any point is less than a set constant value. For more
/// details, please visit https://stanford.edu/~cpiech/cs221/handouts/kmeans.html
///
/// - Returns: A list of clusters, each of which is a list of CLLocationCoordinate2D objects.
- (NSArray<NSArray *> *)kcluster;

/// A helper function that finds the intensity of a given point, represented by realLat and realLong, based on the input data set; this is
/// calculated via formula here: https://gisgeography.com/inverse-distance-weighting-idw-interpolation/
///
/// - Parameters:
///   - latitude: The latitude value of the point.
///   - longitude: The longitude value of the point.
///   - influence: The n-value, determining the range of influence the intensities found in the given data set has.
/// - Returns: A list containing just the numerator and denominator
- (Fraction)findIntensityAtLatitude:(double)latitude
                  longitude:(double)longitude
                  influence:(HeatmapInterpolationInfluence)influence
                  NS_SWIFT_NAME(findIntensity(latitude:longitude:influence:));

/// A helper function that finds the minimum and maximum longitude and latitude values that still contains a powerful enough
/// intensity that it should be included in the data set
///
/// - Parameters:
///     - input: A list of points that are in a cluster.
///     - granularity: The granularity of the search, influencing many points between 1 degree we should visit.
/// - Returns: A list of four integers representing the minimum and maximum longitude and latitude values
- (NSArray<NSNumber *> *)findBoundsForInput:(NSArray *)input granularity:(double)granularity NS_SWIFT_NAME(findBounds(input:granularity:));

/// Generates several heat maps based on the clusters with points not found in the data set interpolated by the inverse distance
/// means interpolation algorithm and displays the heat maps on the given map; for more details, please visit
/// https://en.wikipedia.org/wiki/Inverse_distance_weighting. I used the basic form.
/// For this feature, It doesn't make too much sense to do interpolation on an n-value of less than 2 or greater than 2.5; when n is
/// higher, the denominator increases quicker, meaning the overall value falls quicker as the distances increase, implying that a low
/// n value will query far too many points.
///
/// - Parameters:
///   - n: The n-value, determining the range of influence the intensities found in the given data set has (see
///   HeatmapInterpolationInfluence comment for more details).
///   - granularity: How coarse the search range is WRT to lat/long and must be larger than 0 but smaller than 1 (as
///   granularity approaches 0, the runtime will increase and as granularity approaches 1, the heat map becomes quite sparse); a
///   value of 0.1 is a good sweet spot.
- (NSArray<GMUWeightedLatLng *> * _Nullable)generatePointsWithInfluence:(HeatmapInterpolationInfluence)influence granularity:(double)granularity error:(NSError **)error NS_SWIFT_NAME(generatePoints(influence:granularity:));

- (NSArray<GMUWeightedLatLng *> * _Nullable)generatePointsWithInfluence:(HeatmapInterpolationInfluence)influence error:(NSError **)error NS_SWIFT_NAME(generatePoints(influence:));

@end

NS_ASSUME_NONNULL_END

/// Error object to be thrown when the given influence value is out of range (i.e. not between 2 and 2.5)
@interface IncorrectInfluence : NSError

- (instancetype _Nonnull)initWithDescription:(NSString * _Nullable)description;

@end
