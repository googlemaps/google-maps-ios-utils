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

// In this header, you should import all the public headers of your framework using statements like #import <GoogleMapsUtils/PublicHeader.h>

// Heatmap
#import <GoogleMapsUtils/GMUGradient.h>
#import <GoogleMapsUtils/GMUHeatmapTileLayer.h>
#import <GoogleMapsUtils/GMUWeightedLatLng.h>

// Clustering
#import <GoogleMapsUtils/GMUClusterAlgorithm.h>
#import <GoogleMapsUtils/GMUGridBasedClusterAlgorithm.h>
#import <GoogleMapsUtils/GMUNonHierarchicalDistanceBasedAlgorithm.h>
#import <GoogleMapsUtils/GMUSimpleClusterAlgorithm.h>
#import <GoogleMapsUtils/GMUWrappingDictionaryKey.h>
#import <GoogleMapsUtils/GMUCluster.h>
#import <GoogleMapsUtils/GMUClusterItem.h>
#import <GoogleMapsUtils/GMUClusterManager.h>
#import <GoogleMapsUtils/GMUClusterManager+Testing.h>
#import <GoogleMapsUtils/GMUStaticCluster.h>
#import <GoogleMapsUtils/GMUClusterIconGenerator.h>
#import <GoogleMapsUtils/GMUClusterRenderer.h>
#import <GoogleMapsUtils/GMUDefaultClusterIconGenerator.h>
#import <GoogleMapsUtils/GMUDefaultClusterRenderer.h>
#import <GoogleMapsUtils/GMSMarker+GMUClusteritem.h>

// Geometry
#import <GoogleMapsUtils/GMUFeature.h>
#import <GoogleMapsUtils/GMUGeometry.h>
#import <GoogleMapsUtils/GMUGeometryCollection.h>
#import <GoogleMapsUtils/GMUGeometryContainer.h>
#import <GoogleMapsUtils/GMUGroundOverlay.h>
#import <GoogleMapsUtils/GMULineString.h>
#import <GoogleMapsUtils/GMUPlacemark.h>
#import <GoogleMapsUtils/GMUPoint.h>
#import <GoogleMapsUtils/GMUPolygon.h>
#import <GoogleMapsUtils/GMUStyle.h>
#import <GoogleMapsUtils/GMUGeoJSONParser.h>
#import <GoogleMapsUtils/GMUGeometryRenderer.h>
#import <GoogleMapsUtils/GMUKMLParser.h>
#import <GoogleMapsUtils/GMUStyleMap.h>
#import <GoogleMapsUtils/GMUPair.h>

// QuadTree
#import <GoogleMapsUtils/GQTBounds.h>
#import <GoogleMapsUtils/GQTPoint.h>
#import <GoogleMapsUtils/GQTPointQuadTree.h>
#import <GoogleMapsUtils/GQTPointQuadTreeChild.h>
#import <GoogleMapsUtils/GQTPointQuadTreeItem.h>
