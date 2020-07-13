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

import UIKit

enum Sample: CaseIterable {
  case Clustering
  case KML
  case GeoJSON
  case Heatmaps
}

extension Sample {
  var title: String {
    switch self {
    case .Clustering: return "Clustering"
    case .KML: return "KML"
    case .GeoJSON: return "GeoJSON"
    case .Heatmaps: return "Heatmaps"
    }
  }
  
  var description: String {
    switch self {
    case .Clustering: return "Marker Clustering"
    case .KML: return "KML Rendering"
    case .GeoJSON: return "GeoJSON Rendering"
    case .Heatmaps: return "Heatmaps"
    }
  }
  
  var controller: UIViewController.Type {
    switch self {
    case .Clustering: return ClusteringViewController.self
    case .KML: return KMLViewController.self
    case .GeoJSON: return GeoJSONViewController.self
    case .Heatmaps: return HeatmapViewController.self
    }
  }
}
