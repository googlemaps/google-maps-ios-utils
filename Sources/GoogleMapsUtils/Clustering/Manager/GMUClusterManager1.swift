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

/// TO-DO: Rename the class to `GMUClusterManager` once the linking is done and remove the objective c class.
/// This class groups many items on a map based on zoom level.
/// Cluster items should be added to the map via this class.
///
final class GMUClusterManager1: NSObject, GMSMapViewDelegate {

    // MARK: - Properties
    /// Returns the clustering algorithm.
    private(set) var algorithm: GMUClusterAlgorithm1
    /// The delegate to handle GMUClusterManager events.
    /// GMUClusterManager `delegate`
    /// To set it use the setDelegate:mapDelegate: method.
    private(set) weak var delegate: GMUClusterManagerDelegate1?
    /// The GMSMapViewDelegate delegate that map events are being forwarded to.
    /// To set it use the setDelegate:mapDelegate: method.
    private(set) weak var mapDelegate: GMSMapViewDelegate?
    /// The map view associated with this object.
    private weak var mapView: GMSMapView?
    /// The renderer used to display clusters on the map.
    private var renderer: GMUClusterRenderer1
    /// The previous position of the camera.
    private var previousCamera: GMSCameraPosition
    /// The cluster request count to manage clustering performance.
    private var clusterRequestCount: Int = 0
    /// Key path for observing camera changes.
    private let cameraKeyPath = "camera"
    /// Wait interval before performing the clustering operation (to avoid clustering during continuous camera movement).
    private let clusterWaitIntervalSeconds: TimeInterval = 0.2

    // MARK: - Testing
    /// Returns the current cluster request count, primarily for testing purposes.
    var currentClusterRequestCount: Int {
        return clusterRequestCount
    }

    // MARK: - Init
    /// Returns a new instance of the GMUClusterManager class defined by its `algorithm` and `renderer`.
    ///
    init(mapView: GMSMapView, algorithm: GMUClusterAlgorithm1, renderer: GMUClusterRenderer1) {
        self.algorithm = algorithm
        self.renderer = renderer
        self.mapView = mapView
        self.previousCamera = mapView.camera
        super.init()
        /// Add an observer to monitor camera movements.
        mapView.addObserver(self, forKeyPath: cameraKeyPath, options: .new, context: nil)
    }

    // MARK: - deinit
    /// Cleanup when the object is deallocated.
    ///
    deinit {
        mapView?.removeObserver(self, forKeyPath: cameraKeyPath)
    }

    // MARK: - Methods
    /// Sets a `mapDelegate` to listen to forwarded map events.
    ///
    /// - Parameter mapDelegate: The delegate for map-related events.
    func setMapDelegate(_ mapDelegate: GMSMapViewDelegate?) {
        /// Set the map view's delegate to the GMUClusterManager to intercept events.
        self.mapView?.delegate = self
        /// Store the provided map delegate to forward events later.
        self.mapDelegate = mapDelegate
    }

    /// Sets the `GMUClusterManagerDelegate` delegate and optionally provides a `mapDelegate`
    /// to listen to forwarded map events.
    ///
    /// - Note: This method changes the `delegate` property of the managed `mapView`
    /// to this object, intercepting events that the `GMUClusterManager` wants to
    /// handle or rebroadcast to the `GMUClusterManagerDelegate`. Any remaining
    /// events are then forwarded to the new `mapDelegate` provided here.
    ///
    /// - Example:
    /// ```
    /// clusterManager.setDelegate(self, mapDelegate: mapView?.delegate)
    /// ```
    /// In this example, `self` will receive type-safe `GMUClusterManagerDelegate`
    /// events and other map events will be forwarded to the current map delegate.
    ///
    /// - Parameters:
    ///   - delegate: The delegate to handle GMUClusterManager events.
    ///   - mapDelegate: The delegate to handle map events.
    func setDelegate(_ delegate: GMUClusterManagerDelegate1?, mapDelegate: GMSMapViewDelegate?) {
        /// Set the GMUClusterManager delegate.
        self.delegate = delegate
        /// Set the map view's delegate to the GMUClusterManager to intercept events.
        self.mapView?.delegate = self
        /// Store the provided map delegate to forward events later.
        self.mapDelegate = mapDelegate
    }

    /// Adds a single cluster item to the algorithm.
    ///
    func addItem(_ item: GMUClusterItem1) {
        /// Adds the item to the clustering algorithm by wrapping it in an array.
        algorithm.addItems([item])
    }

    /// Adds multiple cluster items to the algorithm.
    ///
    func addItems(_ items: [GMUClusterItem1]) {
        /// Adds multiple items directly to the clustering algorithm.
        algorithm.addItems(items)
    }

    /// Removes a single cluster item from the algorithm.
    ///
    func removeItem(_ item: GMUClusterItem1) {
        /// Removes the specified item from the clustering algorithm.
        algorithm.removeItem(item)
    }

    /// Clears all cluster items from the algorithm and requests clustering.
    ///
    func clearItems() {
        /// Clears all items from the clustering algorithm.
        algorithm.clearItems()
        /// Requests the clustering process to run after clearing items.
        requestCluster()
    }

    /// Called to arrange items into groups.
    /// - This method will be automatically invoked when the map's zoom level changes.
    /// - Manually invoke this method when new items have been added to rearrange items.
    ///
    func cluster() {
        guard let mapView else { return }
        /// Calculate the current zoom level, rounding it to the nearest integer.
        let integralZoom: Float = floor(mapView.camera.zoom + 0.5)
        /// Retrieve clusters for the current zoom level from the algorithm.
        let clusters: [GMUCluster1] = algorithm.clusters(atZoom: integralZoom)
        /// Pass the clusters to the renderer to display them on the map.
        renderer.renderClusters(clusters)
        /// Update the previous camera position to the current one.
        previousCamera = mapView.camera
    }

    // MARK: - GMSMapViewDelegate
    /// Handles the tap event on a map marker.
    ///
    /// - Parameters:
    ///   - mapView: The map view containing the marker.
    ///   - marker: The marker that was tapped.
    /// - Returns: `true` if the tap event was handled, `false` to pass the event to other handlers.
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        /// Check if the delegate can handle cluster taps and if the marker represents a cluster.
        if let delegate = delegate,
           let cluster = marker.userData as? GMUCluster,
           delegate.clusterManager(self, didTapCluster: cluster) {
            return true
        }

        /// Check if the delegate can handle cluster item taps and if the marker represents a cluster item.
        if let delegate = delegate,
           let clusterItem = marker.userData as? GMUClusterItem,
           delegate.clusterManager(self, didTapClusterItem: clusterItem) {
            return true
        }

        /// Forward to mapDelegate as a fallback.
        if let mapDelegate = mapDelegate {
            return mapDelegate.mapView?(mapView, didTap: marker) != nil
        }

        /// If none of the handlers processed the event, return false.
        return false
    }
    
    // MARK: - Delegate Forwards
    /// Forwards the `willMove` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, willMove: gesture)
    }

    /// Forwards the `didChangeCameraPosition` event to the map delegate.
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, didChange: position)
    }

    /// Forwards the `idleAtCameraPosition` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, idleAt: position)
    }

    /// Forwards the `didTapAtCoordinate` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, didTapAt: coordinate)
    }

    /// Forwards the `didLongPressAtCoordinate` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, didLongPressAt: coordinate)
    }

    /// Forwards the `didTapInfoWindowOfMarker` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, didTapInfoWindowOf: marker)
    }

    /// Forwards the `didLongPressInfoWindowOfMarker` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, didLongPressInfoWindowOf: marker)
    }

    /// Forwards the `didTapOverlay` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, didTap: overlay)
    }

    /// Forwards the `markerInfoWindow` event to the map delegate, returning a custom view if provided.
    ///
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let mapDelegate else { return nil }
        return mapDelegate.mapView?(mapView, markerInfoWindow: marker)
    }

    /// Forwards the `didTapPOIWithPlaceID` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, didTapPOIWithPlaceID: placeID, name: name, location: location)
    }

    /// Forwards the `markerInfoContents` event to the map delegate, returning UIView content if provided.
    ///
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let mapDelegate else { return nil }
        return mapDelegate.mapView?(mapView, markerInfoContents: marker)
    }

    /// Forwards the `didCloseInfoWindowOfMarker` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, didCloseInfoWindowOf: marker)
    }

    /// Forwards the `didBeginDraggingMarker` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, didBeginDragging: marker)
    }

    /// Forwards the `didEndDraggingMarker` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, didEndDragging: marker)
    }

    /// Forwards the `didDragMarker` event to the map delegate.
    ///
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        guard let mapDelegate else { return }
        mapDelegate.mapView?(mapView, didDrag: marker)
    }

    /// Forwards the `didTapMyLocationButton` event to the map delegate and returns a Boolean result.
    ///
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        guard let mapDelegate else { return false }
        return mapDelegate.didTapMyLocationButton?(for: mapView) ?? false
    }

    /// Forwards the `mapViewDidStartTileRendering` event to the map delegate.
    ///
    func mapViewDidStartTileRendering(_ mapView: GMSMapView) {
        guard let mapDelegate else { return }
        mapDelegate.mapViewDidStartTileRendering?(mapView)
    }

    /// Forwards the `mapViewDidFinishTileRendering` event to the map delegate.
    ///
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        guard let mapDelegate else { return }
        mapDelegate.mapViewDidFinishTileRendering?(mapView)
    }
    
    // MARK: - Private
    /// Observes changes to the camera position and triggers clustering if necessary.
    ///
    /// - Parameters:
    ///   - keyPath: The key path being observed (e.g., `cameraKeyPath`).
    ///   - object: The object whose property changed.
    ///   - change: The dictionary containing the details of the change.
    ///   - context: The context for the observer (if any).
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let mapView else { return }
        /// Calculate previous and current zoom levels, rounded to the nearest integer.
        let previousIntegralZoom = floor(previousCamera.zoom + 0.5)
        let currentIntegralZoom = floor(mapView.camera.zoom + 0.5)

        /// If the zoom level has changed, request clustering; otherwise, update the renderer.
        if previousIntegralZoom != currentIntegralZoom {
            requestCluster()
        } else {
            renderer.update()
        }
    }

    /// Requests a clustering operation, but only after a delay to avoid continuous clustering when the camera moves.
    ///
    private func requestCluster() {
        /// Weak self to avoid retain cycles.
        weak var weakSelf = self
        /// Increment the cluster request count to track the number of cluster requests.
        clusterRequestCount += 1
        let requestNumber = clusterRequestCount
        
        /// Dispatch clustering after a specified wait interval (to avoid performance impact from constant clustering).
        DispatchQueue.main.asyncAfter(deadline: .now() + (clusterWaitIntervalSeconds * Double(NSEC_PER_SEC))) {
            guard let strongSelf = weakSelf else { return }
            /// Ignore the request if newer requests have been made (to avoid stale clustering).
            if requestNumber != strongSelf.clusterRequestCount {
                return
            }
            /// Perform the clustering operation.
            strongSelf.cluster()
        }
    }

}
