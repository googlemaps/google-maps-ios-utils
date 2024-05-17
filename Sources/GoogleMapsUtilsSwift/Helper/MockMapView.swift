//
//  MockMapView.swift
//  
//
//  Created by Wayne Bishop on 5/16/24.
//

import Foundation
import GoogleMaps

// 1. Define the MapViewProtocol
protocol MapViewProtocol {
    func setCamera(_ camera: GMSCameraPosition)
}

// 2. Make GMSMapView conform to MapViewProtocol
// note: this would allow you to create and compare real GMSMapView functionality.
extension GMSMapView: MapViewProtocol {
    func setCamera(_ camera: GMSCameraPosition) {
        self.camera = camera
        self.animate(to: camera) //self, in this case is GMSMapView..
    }
}

// 3. Create the MockMapView class
class MockMapView: MapViewProtocol {
    var setCameraCallCount = 0
    var setCameraReceivedArguments: [GMSCameraPosition] = []
    
    func setCamera(_ camera: GMSCameraPosition) {
        setCameraCallCount += 1
        setCameraReceivedArguments.append(camera)
    }
}

