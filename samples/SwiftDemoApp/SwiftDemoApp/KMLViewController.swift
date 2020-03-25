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

import GoogleMaps
import UIKit
import GoogleMapsUtils

class KMLViewController: UIViewController {
  private var mapView: GMSMapView!
  private var renderer: GMUGeometryRenderer!
  private var kmlParser: GMUKMLParser!
  private var geoJsonParser: GMUGeoJSONParser!

  override func loadView() {
    let camera = GMSCameraPosition.camera(withLatitude: 37.4220, longitude: -122.0841, zoom: 17)
    mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    self.view = mapView

    let path = Bundle.main.path(forResource: "KML_Sample", ofType: "kml")
    let url = URL(fileURLWithPath: path!)
    kmlParser = GMUKMLParser(url: url)
    kmlParser.parse()

    renderer = GMUGeometryRenderer(map: mapView,
                                   geometries: kmlParser.placemarks,
                                   styles: kmlParser.styles,
                                   styleMaps: kmlParser.styleMaps)

    renderer.render()
  }
}
