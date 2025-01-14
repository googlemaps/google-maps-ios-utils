// Copyright 2024 Google LLC
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

/// TO-DO: Rename the class to `GMUHeatmapTileCreationData` once the linking is done and remove the objective c class.
/// Holder for data that must be consistent when accessed from tile creation threads.
struct GMUHeatmapTileCreationData1 {
    
    /// Public variables for the heatmap tile creation data.
    /// QuadTree structure for spatial indexing.
    var quadTree: GQTPointQuadTree1?
    /// Bounds of the heatmap.
    var bounds: GQTBounds1
    /// Smoothing radius for the heatmap.
    var radius: Int
    /// Minimum zoom intensity for normalizing data.
    var minimumZoomIntensity: Int?
    /// Maximum zoom intensity for normalizing data.
    var maximumZoomIntensity: Int?
    /// Color map for intensity-to-color mapping.
    var colorMap: [UIColor]
    /// Maximum intensities at different zoom levels.
    var maxIntensities: [Float]
    /// Kernel for applying smoothing to data points.
    var kernel: [Float]
}
