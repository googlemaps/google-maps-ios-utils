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

/// TO-DO: Rename the class to `GMUClusterManagerDelegate` once the linking is done and remove the objective c class.
/// Delegate for events on the GMUClusterManager.
/// 
protocol GMUClusterManagerDelegate1: AnyObject {

    /// Called when the user taps on a cluster marker.
    /// - Parameters:
    ///   - clusterManager: The cluster manager handling the clusters.
    ///   - cluster: The cluster that was tapped.
    /// - Returns: `true` if the delegate handled the tap event, `false` to pass this event to other handlers.
    func clusterManager(_ clusterManager: GMUClusterManager1, didTapCluster cluster: GMUCluster1) -> Bool

    /// Called when the user taps on a cluster item marker.
    /// - Parameters:
    ///   - clusterManager: The cluster manager handling the clusters.
    ///   - clusterItem: The cluster item that was tapped.
    /// - Returns: `true` if the delegate handled the tap event, `false` to pass this event to other handlers.
    func clusterManager(_ clusterManager: GMUClusterManager1, didTapClusterItem clusterItem: GMUClusterItem1) -> Bool
}
