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

import GoogleMaps

/// TO-DO: Rename the class to `GMUClusterRendererDelegate` once the linking is done and remove the objective c class.
/// Delegate for GMUClusterRenderer to provide extra functionality to the default renderer.
///
protocol GMUClusterRendererDelegate1: AnyObject {
        
    /// Returns a marker for an |object|. The |object| can be either an GMUCluster or an GMUClusterItem.
    /// Use this delegate to control of the life cycle of the marker. Any properties set on the returned marker will be honoured except for: .position, .icon, .groundAnchor, .zIndex and .userData.
    /// To customize these properties use `renderer:willRenderMarker`.
    /// Note that changing a marker's position is not recommended because it will interfere with the marker animation.
    /// - Parameters:
    ///   - renderer: The `GMUClusterRenderer` that requests the marker.
    ///   - object: Either a `GMUCluster` or `GMUClusterItem`.
    /// - Returns: A customized `GMSMarker` for the provided object.
    ///
    func renderer(_ renderer: GMUClusterRenderer1, markerForObject object: Any) -> GMSMarker?

    /// Raised when a marker (for a cluster or an item) is about to be added to the map.
    /// Use the `marker.userData` property to check whether it is a cluster marker or an item marker.
    /// - Parameters:
    ///   - renderer: The `GMUClusterRenderer` that is rendering the marker.
    ///   - marker: The marker that will be added to the map.
    ///
    func renderer(_ renderer: GMUClusterRenderer1, willRenderMarker marker: GMSMarker)

    /// Raised when a marker (for a cluster or an item) has just been added to the map and animation has been added.
    /// Use the `marker.userData` property to check whether it is a cluster marker or an item marker.
    /// - Parameters:
    ///   - renderer: The `GMUClusterRenderer` that has just rendered the marker.
    ///   - marker: The marker that was added to the map.
    ///
    func renderer(_ renderer: GMUClusterRenderer1, didRenderMarker marker: GMSMarker)
}
