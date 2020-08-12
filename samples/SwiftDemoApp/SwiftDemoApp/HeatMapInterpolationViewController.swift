/* Copyright (c) 2020 Google Inc.
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
import GooglePlaces
import GoogleMapsUtils

class HeatMapInterpolationViewController: UIViewController {

    /// Basic set up variables
    private var mapView = GMSMapView()
    private var data = [[Double]]()
    private var markers = [GMSMarker]()
    private var rendering = false
    private let interpolationController = HeatMapInterpolationPoints()

    /// Two render buttons for the user to click
    @IBOutlet weak var renderButton: UIButton!
    @IBOutlet weak var defaultRender: UIButton!
    
    /// The alert that pops up when the user wants to manually input a power value
    private let alert = UIAlertController(
        title: "Render",
        message: "Enter an N value",
        preferredStyle: .alert
    )

    /// Sets up the GMS Map and adds two buttons (one default render and one custom render)
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 145.20, zoom: 5.0)
        mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        view.addSubview(mapView)
        view.bringSubviewToFront(renderButton)
        view.bringSubviewToFront(defaultRender)
        alert.addTextField { (textField) in
            textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            
            // Force unwrapping is okay here because there has to be a text field (created above)
            self.executeHeatMap(nVal: Float(alert?.textFields![0].text ?? "0.0") ?? 0.0)
        }))
    }
    
    /// Presents a pop up which takes in a number as the power value
    @IBAction func startRender(_ sender: Any) {
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Starts a render on the default power value of 2.5
    @IBAction func startDefaultRender(_ sender: Any) {
        executeHeatMap(nVal: 2.5)
    }

    /// Executes the heat map based on the given power value
    ///
    /// - Parameter nVal: The power value that determines how far each given point influences.
    private func executeHeatMap(nVal: Float) {
        
        // It is vital to remove all prevously appended data points before creating a new heat map
        interpolationController.removeAllData()
        
        // Adds points via the singular addWeightedLatLng function; intensity is initially set to
        // 100 as a showcase
        let newGMU = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.86 , longitude: 145.20),
            intensity: 100
        )
        interpolationController.addWeightedLatLng(latlng: newGMU)

        // Adds points via a list, using addWeightedLatLngs; intensity is initially set to 100 as a
        // showcase
        var listOfPoints = [GMUWeightedLatLng]()
        let newGMU2 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -20.85, longitude: 145.20),
            intensity: 100
        )
        let newGMU3 = GMUWeightedLatLng(
            coordinate: CLLocationCoordinate2D(latitude: -32, longitude: 145.20),
            intensity: 100
        )
        listOfPoints.append(newGMU2)
        listOfPoints.append(newGMU3)
        interpolationController.addWeightedLatLngs(latlngs: listOfPoints)
        
        // The variable generatedPoints contains the list of interpolated points, a by-product of
        // the generateHeatMaps function (the function's main purpose is to place an interpolated
        // heat map on the given mapView)
        let generatedPoints = interpolationController.generateHeatMaps(
            mapView: mapView,
            n: Double(nVal)
        )
        
        // If you wish, uncomment the line below to seegenerated points from the interpolation
        // print(generatedPoints)
    }
}

/// Helper extension for the alert view text
extension UITextField {
    var floatValue : Float {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let nsNumber = numberFormatter.number(from: text!)
        return nsNumber == nil ? 0.0 : nsNumber!.floatValue
    }
}
