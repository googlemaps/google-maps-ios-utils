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

#import <UIKit/UIKit.h>

//! Project version number for GoogleMapsUtilities.
FOUNDATION_EXPORT double GoogleMapsUtilitiesVersionNumber;

//! Project version string for GoogleMapsUtilities.
FOUNDATION_EXPORT const unsigned char GoogleMapsUtilitiesVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <GoogleMapsUtilities/PublicHeader.h>

#import <GoogleMaps/GoogleMaps.h>

// Heatmap
#import <GoogleMapsUtilities/GMUGradient.h>
#import <GoogleMapsUtilities/GMUHeatmapTileLayer.h>
#import <GoogleMapsUtilities/GMUWeightedLatLng.h>

// Clustering
#import <GoogleMapsUtilities/GMUClusterAlgorithm.h>
#import <GoogleMapsUtilities/GMUGridBasedClusterAlgorithm.h>
#import <GoogleMapsUtilities/GMUNonHierarchicalDistanceBasedAlgorithm.h>
#import <GoogleMapsUtilities/GMUSimpleClusterAlgorithm.h>
#import <GoogleMapsUtilities/GMUWrappingDictionaryKey.h>
#import <GoogleMapsUtilities/GMUCluster.h>
#import <GoogleMapsUtilities/GMUClusterItem.h>
#import <GoogleMapsUtilities/GMUClusterManager.h>
#import <GoogleMapsUtilities/GMUClusterManager+Testing.h>
#import <GoogleMapsUtilities/GMUStaticCluster.h>
#import <GoogleMapsUtilities/GMUClusterIconGenerator.h>
#import <GoogleMapsUtilities/GMUClusterRenderer.h>
#import <GoogleMapsUtilities/GMUDefaultClusterIconGenerator.h>
#import <GoogleMapsUtilities/GMUDefaultClusterIconGenerator+Testing.h>
#import <GoogleMapsUtilities/GMUDefaultClusterRenderer.h>
#import <GoogleMapsUtilities/GMUDefaultClusterRenderer+Testing.h>

// Geometry
#import <GoogleMapsUtilities/GMUFeature.h>
#import <GoogleMapsUtilities/GMUGeometry.h>
#import <GoogleMapsUtilities/GMUGeometryCollection.h>
#import <GoogleMapsUtilities/GMUGeometryContainer.h>
#import <GoogleMapsUtilities/GMUGroundOverlay.h>
#import <GoogleMapsUtilities/GMULineString.h>
#import <GoogleMapsUtilities/GMUPlacemark.h>
#import <GoogleMapsUtilities/GMUPoint.h>
#import <GoogleMapsUtilities/GMUPolygon.h>
#import <GoogleMapsUtilities/GMUStyle.h>
#import <GoogleMapsUtilities/GMUGeoJSONParser.h>
#import <GoogleMapsUtilities/GMUGeometryRenderer+Testing.h>
#import <GoogleMapsUtilities/GMUGeometryRenderer.h>
#import <GoogleMapsUtilities/GMUKMLParser.h>

// QuadTree
#import <GoogleMapsUtilities/GQTBounds.h>
#import <GoogleMapsUtilities/GQTPoint.h>
#import <GoogleMapsUtilities/GQTPointQuadTree.h>
#import <GoogleMapsUtilities/GQTPointQuadTreeChild.h>
#import <GoogleMapsUtilities/GQTPointQuadTreeItem.h>

