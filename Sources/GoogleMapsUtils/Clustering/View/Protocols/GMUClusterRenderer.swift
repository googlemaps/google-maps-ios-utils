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

// MARK: - `GMUClusterRenderer` Protocol
/// Defines a common contract for a cluster renderer.
///
public protocol GMUClusterRenderer: AnyObject {
    /// Renders a list of clusters.
    /// 
    func renderClusters(_ clusters: [GMUCluster])

    /// Notifies renderer that the viewport has changed and renderer needs to update.
    /// For example new clusters may become visible and need to be shown on map.
    ///
    func update()
}
