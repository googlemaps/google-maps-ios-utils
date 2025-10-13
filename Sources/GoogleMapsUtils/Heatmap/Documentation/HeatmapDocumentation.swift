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

/// # Heatmap Module
///
/// Renders weighted geographic data as heat overlays on maps.
///
/// Use ``GMUHeatmapTileLayer`` for the main functionality.
///
/// ## Usage
///
/// ```swift
/// let heatmapLayer = GMUHeatmapTileLayer()
/// heatmapLayer.weightedData = [GMUWeightedLatLng(coordinate: location, intensity: 1.0)]
/// heatmapLayer.map = mapView
/// ```
///
///
/// ## Topics
///
/// ### Main Rendering
/// - ``GMUHeatmapTileLayer``
///
/// ### Data Points
/// - ``GMUWeightedLatLng``
///
/// ### Color Mapping
/// - ``GMUGradient``
///
/// ### Advanced Features
/// - ``HeatmapInterpolationPoints``
/// - ``GMUHeatmapTileCreationData``
///
public struct HeatmapDocumentation {
    
    /// Private initializer to prevent instantiation.
    ///
    /// This struct exists solely for documentation organization and should never be instantiated.
    /// It serves as a namespace to group Heatmap module documentation in one place.
    private init() {}
}

