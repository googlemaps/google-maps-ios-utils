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
import GoogleMapsUtils

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

class ClusteringViewController: UIViewController, GMSMapViewDelegate {

  private var mapView: GMSMapView!
  private var clusterManager: GMUClusterManager!

  override func loadView() {
    let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
      longitude: kCameraLongitude, zoom: 10)
    mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    self.view = mapView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up the cluster manager with default icon generator and renderer.
    let iconGenerator = GMUDefaultClusterIconGenerator()
    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
    clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
    
    // Register self to listen to GMSMapViewDelegate events.
    clusterManager.setMapDelegate(self)
    
    // Generate and add random items to the cluster manager.
    generateClusterItems()

    // Call cluster() after items have been added to perform the clustering and rendering on map.
    clusterManager.cluster()
  }

  // MARK: - GMUMapViewDelegate

  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    mapView.animate(toLocation: marker.position)
    if let _ = marker.userData as? GMUCluster {
      mapView.animate(toZoom: mapView.camera.zoom + 1)
      NSLog("Did tap cluster")
      return true
    }
    NSLog("Did tap marker")
    return false
  }

  // MARK: - Private

  /// Randomly generates cluster items within some extent of the camera and adds them to the
  /// cluster manager.
  private func generateClusterItems() {
    let extent = 0.2
    for _ in 1...kClusterItemCount {
      let lat = kCameraLatitude + extent * randomScale()
      let lng = kCameraLongitude + extent * randomScale()
      let position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
      let marker = GMSMarker(position: position)
      clusterManager.add(marker)
    }
  }

  /// Returns a random value between -1.0 and 1.0.
  private func randomScale() -> Double {
    return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
  }
}
