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

//! Project version number for GoogleMapsUtils.
FOUNDATION_EXPORT double GoogleMapsUtilsVersionNumber;

//! Project version string for GoogleMapsUtils.
FOUNDATION_EXPORT const unsigned char GoogleMapsUtilsVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import "PublicHeader.h"

// Heatmap
#import "GMUGradient.h"
#import "GMUHeatmapTileLayer.h"
#import "GMUHeatmapTileLayer+Testing.h"
#import "GMUWeightedLatLng.h"

// Clustering
#import "GMUMarkerClustering.h"
#import "GMUClusterAlgorithm.h"
#import "GMUGridBasedClusterAlgorithm.h"
#import "GMUNonHierarchicalDistanceBasedAlgorithm.h"
#import "GMUSimpleClusterAlgorithm.h"
#import "GMUWrappingDictionaryKey.h"
#import "GMUCluster.h"
#import "GMUClusterItem.h"
#import "GMUClusterManager.h"
#import "GMUClusterManager+Testing.h"
#import "GMUStaticCluster.h"
#import "GMUClusterIconGenerator.h"
#import "GMUClusterRenderer.h"
#import "GMUDefaultClusterIconGenerator.h"
#import "GMUDefaultClusterIconGenerator+Testing.h"
#import "GMUDefaultClusterRenderer.h"
#import "GMUDefaultClusterRenderer+Testing.h"
#import "GMSMarker+GMUClusteritem.h"

// Geometry
#import "GMUFeature.h"
#import "GMUGeometry.h"
#import "GMUGeometryCollection.h"
#import "GMUGeometryContainer.h"
#import "GMUGroundOverlay.h"
#import "GMULineString.h"
#import "GMUPlacemark.h"
#import "GMUPoint.h"
#import "GMUPolygon.h"
#import "GMUStyle.h"
#import "GMUGeoJSONParser.h"
#import "GMUGeometryRenderer.h"
#import "GMUGeometryRenderer+Testing.h"
#import "GMUKMLParser.h"
#import "GMUStyleMap.h"
#import "GMUPair.h"

// QuadTree
#import "GQTBounds.h"
#import "GQTPoint.h"
#import "GQTPointQuadTree.h"
#import "GQTPointQuadTreeChild.h"
#import "GQTPointQuadTreeItem.h"
