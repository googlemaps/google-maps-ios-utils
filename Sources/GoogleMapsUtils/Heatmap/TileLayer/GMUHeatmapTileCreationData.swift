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

import UIKit

/// Holder for data that must be consistent when accessed from tile creation threads.
///
/// This struct holds configuration data that must remain consistent
/// during background tile creation operations.
public struct GMUHeatmapTileCreationData {
    
    /// Spatial indexing structure for efficient data queries.
    var quadTree: GQTPointQuadTree?
    
    /// Geographic bounds of the heatmap data.
    var bounds: GQTBounds
    
    /// Smoothing radius in pixels.
    var radius: Int
    
    /// Minimum zoom intensity for data normalization.
    var minimumZoomIntensity: Int?
    
    /// Maximum zoom intensity for data normalization.
    var maximumZoomIntensity: Int?
    
    /// Precomputed color map for intensity-to-color conversion.
    var colorMap: [UIColor]
    
    /// Maximum intensity values at different zoom levels.
    var maxIntensities: [Float]
    
    /// Smoothing kernel for data point processing.
    var kernel: [Float]
}
