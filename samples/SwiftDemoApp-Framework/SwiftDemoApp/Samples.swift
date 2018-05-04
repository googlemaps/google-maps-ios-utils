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

import Foundation

class Samples {
  class func loadSamples() -> NSArray! {
    return [ newDemo(controller: ClusteringViewController.self,
                     title: "Clustering",
                     description: "Marker Clustering"),
             newDemo(controller: KMLViewController.self,
                     title: "KML",
                     description: "KML Rendering"),
             newDemo(controller: GeoJSONViewController.self,
                     title: "GeoJSON",
                     description: "GeoJSON Rendering"),
             newDemo(controller: HeatmapViewController.self,
                     title: "Heatmaps",
                     description: "Heatmaps")]
  }

  class func newDemo(controller: AnyClass!, title: String!, description: String!) -> NSDictionary! {
    return [ "controller" : controller, "title" : title, "description" : description ]
  }
}
