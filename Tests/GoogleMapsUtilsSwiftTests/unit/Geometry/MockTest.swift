//
//  MockTest.swift
//  
//
//  Created by Wayne Bishop on 5/16/24.
//

import XCTest
import GoogleMaps

@testable import GoogleMapsUtilsSwift

final class MockTest: XCTestCase {
    
    var viewController: MyViewController!
    var mockMapView: MockMapView!

    override func setUp() {
        super.setUp()
        
        viewController = MyViewController()
        mockMapView = MockMapView()
        
        //note: the magic occurs here, as the mapView property is defined as a protocol
        //this means different classes can still appear as equal if they both conform to the sample protocol.
        viewController.mapView = mockMapView
    }

    override func tearDown() {
        viewController = nil
        mockMapView = nil
        super.tearDown()
    }

    func testUpdateMapViewCallsSetCameraOnMapView() {
            
        //note: here we are creating a new camera position
        let cameraPosition = GMSCameraPosition(latitude: 100, longitude: 100, zoom: 7.0)
        
        //here we are updating the fake
        viewController.updateMapView(with: cameraPosition)

        XCTAssertEqual(mockMapView.setCameraCallCount, 1)
        XCTAssertEqual(mockMapView.setCameraReceivedArguments.first!, cameraPosition)
    }
    
    //helper function - to demonstrate functionality
    class MyViewController: UIViewController {
        
        //note: this is the problem with our code. 
        //this mapView is currently defined as a native GMSMapView (and I am assuming can't be changed).
        var mapView: MapViewProtocol!
        
        func updateMapView(with cameraPosition: GMSCameraPosition) {
            mapView.setCamera(cameraPosition)
        }
    }
}
