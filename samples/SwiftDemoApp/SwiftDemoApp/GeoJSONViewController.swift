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
import GoogleMaps
import GoogleMapsUtils

class GeoJSONViewController: UIViewController {
  private var mapView: GMSMapView!
  private var renderer: GMUGeometryRenderer!
  private var geoJsonParser: GMUGeoJSONParser!

  override func loadView() {
    let camera = GMSCameraPosition.camera(withLatitude: -28, longitude: 137, zoom: 4)
    let options = GMSMapViewOptions()
    options.camera = camera
    mapView = GMSMapView.init(options: options)
    self.view = mapView
    guard let path = Bundle.main.path(forResource: "GeoJSON_sample", ofType: "json") else {
        NSLog("Resource not available")
        return
    }
    let url = URL(fileURLWithPath: path)
    geoJsonParser = GMUGeoJSONParser(url: url)
    geoJsonParser.parse()
    renderer = GMUGeometryRenderer(map: mapView, geometries: geoJsonParser.features)
    renderer.render()
  }
}
