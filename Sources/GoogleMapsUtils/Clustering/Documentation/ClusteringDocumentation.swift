// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// # Clustering Module
///
/// Group map markers into clusters based on zoom level and proximity.
///
/// ## Overview
///
/// The Clustering module provides functionality to group many map markers into clusters,
/// improving performance and user experience when displaying large numbers of markers.
///
/// ```swift
/// let clusterManager = GMUClusterManager(
///     map: mapView,
///     algorithm: GMUNonHierarchicalDistanceBasedAlgorithm(),
///     renderer: GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
/// )
///
/// // Add cluster items
/// let items: [GMUClusterItem] = [/* your marker items */]
/// clusterManager.add(items)
/// clusterManager.cluster()
/// ```
///
/// ## Topics
///
/// ### Core Protocols
/// - ``GMUCluster``
/// - ``GMUClusterItem``
/// - ``GMUClusterAlgorithm``
///
/// ### Management
/// - ``GMUClusterManager``
/// - ``GMUClusterManagerDelegate``
///
/// ### Rendering
/// - ``GMUClusterRenderer``
/// - ``GMUDefaultClusterRenderer``
/// - ``GMUClusterRendererDelegate``
///
/// ### Icon Generation
/// - ``GMUClusterIconGenerator``
/// - ``GMUDefaultClusterIconGenerator``
///
/// ### Algorithms
/// - ``GMUNonHierarchicalDistanceBasedAlgorithm``
/// - ``GMUGridBasedClusterAlgorithm``
///
/// ### Static Clusters
/// - ``GMUStaticCluster``
///
/// > Warning: This is a documentation-only namespace. Do not instantiate or use this struct in your code.
public struct ClusteringDocumentation {
    private init() {}
}
