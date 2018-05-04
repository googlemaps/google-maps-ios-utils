/* Copyright (c) 2016 Google Inc.
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

import GoogleMaps
import UIKit

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
  var position: CLLocationCoordinate2D
  var name: String!

  init(position: CLLocationCoordinate2D, name: String) {
    self.position = position
    self.name = name
  }
}

let kClusterItemCount = 10000
let kCameraLatitude = -33.8
let kCameraLongitude = 151.2

class ViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate {

  private var mapView: GMSMapView!
  private var clusterManager: GMUClusterManager!

  override func loadView() {
    let camera = GMSCameraPosition.cameraWithLatitude(kCameraLatitude,
      longitude: kCameraLongitude, zoom: 10)
    mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
    self.view = mapView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up the cluster manager with default icon generator and renderer.
    let iconGenerator = GMUDefaultClusterIconGenerator()
    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
    clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)

    // Generate and add random items to the cluster manager.
    generateClusterItems()

    // Call cluster() after items have been added to perform the clustering and rendering on map.
    clusterManager.cluster()

    // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
    clusterManager.setDelegate(self, mapDelegate: self)
  }

  // MARK: - GMUClusterManagerDelegate

  func clusterManager(clusterManager: GMUClusterManager, didTapCluster cluster: GMUCluster) {
    let newCamera = GMSCameraPosition.cameraWithTarget(cluster.position,
      zoom: mapView.camera.zoom + 1)
    let update = GMSCameraUpdate.setCamera(newCamera)
    mapView.moveCamera(update)
  }

  // MARK: - GMUMapViewDelegate

  func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
    if let poiItem = marker.userData as? POIItem {
      NSLog("Did tap marker for cluster item \(poiItem.name)")
    } else {
      NSLog("Did tap a normal marker")
    }
    return false
  }

  // MARK: - Private

  /// Randomly generates cluster items within some extent of the camera and adds them to the
  /// cluster manager.
  private func generateClusterItems() {
    let extent = 0.2
    for index in 1...kClusterItemCount {
      let lat = kCameraLatitude + extent * randomScale()
      let lng = kCameraLongitude + extent * randomScale()
      let name = "Item \(index)"
      let item = POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
      clusterManager.addItem(item)
    }
  }

  /// Returns a random value between -1.0 and 1.0.
  private func randomScale() -> Double {
    return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
  }
}
