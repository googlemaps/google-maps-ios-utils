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

@testable import GoogleMapsUtils

/// A mock implementation of `GMSMapViewDelegate` for testing purposes.
///
final class MockMapDelegate: GMSMapViewDelegate, Equatable {

    // MARK: - Properties
    var didTapMarkerCalled = false
    var didTapOverlayCalled = false
    var hash: Int = 0
    var description: String = ""
    var superclass: AnyClass?

    // MARK: - GMSMapViewDelegate Methods
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        didTapMarkerCalled = true
        return true
    }

    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        didTapOverlayCalled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {}
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {}
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {}
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {}
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {}
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {}
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {}
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {}
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {}
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {}
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {}
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {}
    func mapViewDidStartTileRendering(_ mapView: GMSMapView) {}
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {}

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }

    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return UIView()
    }

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        return true
    }

    // MARK: - Equatable Conformance
    static func == (lhs: MockMapDelegate, rhs: MockMapDelegate) -> Bool {
        return true
    }

    // MARK: - NSObject Methods
    func isEqual(_ object: Any?) -> Bool {
        return true
    }

    func `self`() -> Self {
        return self
    }

    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        return nil
    }

    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }

    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        return nil
    }

    func isProxy() -> Bool {
        return true
    }

    func isKind(of aClass: AnyClass) -> Bool {
        return true
    }

    func isMember(of aClass: AnyClass) -> Bool {
        return true
    }

    func conforms(to aProtocol: Protocol) -> Bool {
        return true
    }

    func responds(to aSelector: Selector!) -> Bool {
        return true
    }
}
