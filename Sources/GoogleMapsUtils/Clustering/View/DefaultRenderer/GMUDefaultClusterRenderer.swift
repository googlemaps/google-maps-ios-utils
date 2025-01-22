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

/// Default cluster renderer which shows clusters as markers with specialized icons.
/// There is logic to decide whether to expand a cluster or not depending on the number of items or the zoom level.
/// There is also some performance optimization where only clusters within the visisble region are shown.
///
final class GMUDefaultClusterRenderer: GMUClusterRenderer {

    // MARK: - Properties
    // Map view to render clusters on.
    private weak var mapView: GMSMapView?
    /// Collection of markers added to the map.
    private var mutableMarkers: [GMSMarker]
    /// Icon generator used to create cluster icon.
    private var clusterIconGenerator: GMUClusterIconGenerator
    /// Current clusters being rendered.
    private var clusters: [GMUCluster]?
    // Tracks clusters that have been rendered to the map.
    private var renderedClusters: NSMutableSet
    /// Tracks cluster items that have been rendered to the map.
    private var renderedClusterItems: NSMutableSet
    /// Stores previous zoom level to determine zooming direction (in/out).
    private var previousZoom: Float = 0.0
    /// Lookup map from cluster item to an old cluster.
    private var itemToOldClusterMap: [GMUWrappingDictionaryKey: GMUCluster]?
    /// Lookup map from cluster item to a new cluster.
    private var itemToNewClusterMap: [GMUWrappingDictionaryKey: GMUCluster]?
    /// Animates the clusters to achieve splitting (when zooming in) and merging
    /// (when zooming out) effects:
    /// - splitting large clusters into smaller ones when zooming in.
    /// - merging small clusters into bigger ones when zooming out.
    ///
    /// NOTES: the position to animate to/from for each cluster is heuristically
    /// calculated by finding the first overlapping cluster. This means that:
    /// - when zooming in:
    ///    if a cluster on a higher zoom level is made from multiple clusters on
    ///    a lower zoom level the split will only animate the new cluster from
    ///    one of them.
    /// - when zooming out:
    ///    if a cluster on a higher zoom level is split into multiple parts to join
    ///    multiple clusters at a lower zoom level, the merge will only animate
    ///    the old cluster into one of them.
    ///
    /// Because of these limitations, the actual cluster sizes may not add up, for
    /// example people may see 3 clusters of size 3, 4, 5 joining to make up a cluster
    /// of only 8 for non-hierarchical clusters. And vice versa, a cluster of 8 may
    /// split into 3 clusters of size 3, 4, 5. For hierarchical clusters, the numbers
    /// should add up however.
    ///
    /// Defaults to YES.
    var animatesClusters: Bool
    /// Clusters smaller than this threshold will be expanded.
    /// Determines the minimum number of cluster items inside a cluster.
    /// Defaults to 4.
    var minimumClusterSize: Int
    /// At zooms above this level, clusters will be expanded.
    /// This is to prevent cases where items are so close to each other than they are always grouped.
    /// Sets the maximium zoom level of the map on which the clustering
    /// should be applied. At zooms above this level, clusters will be expanded.
    /// This is to prevent cases where items are so close to each other than they
    /// are always grouped.
    /// Defaults to 20.
    var maximumClusterZoom: Int
    /// Sets the animation duration for marker splitting/merging effects.
    /// Measured in seconds.
    /// Animation duration for marker splitting/merging effects.
    /// Defaults to 0.5.
    var animationDuration: Double
    /// Allows setting a zIndex value for the clusters.
    /// This becomes useful when using multiple cluster data sets on the map and require a predictable way of displaying multiple sets with a predictable layering order.
    /// If no specific zIndex is not specified during the initialization, the default zIndex is '1'.
    /// Larger zIndex values are drawn over lower ones similar to the zIndex value of GMSMarkers.
    var zIndex: Int
    /// Sets to further customize the renderer.
    weak var delegate: GMUClusterRendererDelegate?
    /// Returns currently active markers.
    var currentActivemarkers: [GMSMarker] {
        return mutableMarkers
    }

    // MARK: - Init
    /// Initializes the cluster renderer with a map view and an icon generator.
    ///
    /// - Parameters:
    ///   - mapView: The `GMSMapView` on which clusters will be rendered.
    ///   - clusterIconGenerator: The icon generator used to create icons for the clusters.
    ///
    /// - Returns: A new instance of `GMUDefaultClusterRenderer`.
    ///
    init(mapView: GMSMapView, clusterIconGenerator: GMUClusterIconGenerator) {
        // Initialize properties
        self.mapView = mapView
        self.mutableMarkers = []
        self.clusterIconGenerator = clusterIconGenerator
        self.renderedClusters = NSMutableSet()
        self.renderedClusterItems = NSMutableSet()
        self.animatesClusters = true
        self.minimumClusterSize = 4
        self.maximumClusterZoom = 20
        self.animationDuration = 0.5 // seconds.
        self.zIndex = 1
    }

    /// Deallocates the resources by clearing all markers and clusters from the map.
    ///
    deinit {
        clear()
    }

    /// Determines whether the given cluster should be rendered as a cluster based on the current zoom level
    /// and the number of items in the cluster.
    ///
    /// - Parameters:
    ///   - cluster: The `GMUCluster` to check.
    ///   - zoom: The current zoom level of the map.
    ///
    /// - Returns: `true` if the cluster should be rendered as a cluster, otherwise `false`.
    ///
    func shouldRenderAsCluster(_ cluster: GMUCluster, atZoom zoom: Float) -> Bool {
        return cluster.count >= minimumClusterSize && Int(zoom) <= maximumClusterZoom
    }

    // MARK: - `GMUClusterRenderer`
    /// Renders the provided clusters on the map. If cluster animations are enabled, it renders
    /// the clusters with animation. Otherwise, it removes existing markers and renders new ones
    /// without animation.
    ///
    /// - Parameter clusters: The clusters to be rendered on the map.
    ///
    func renderClusters(_ clusters: [GMUCluster]) {
        renderedClusters.removeAllObjects()
        renderedClusterItems.removeAllObjects()

        if animatesClusters {
            renderAnimatedClusters(clusters)
        } else {
            // No animation, just remove existing markers and add new ones.
            self.clusters = clusters
            clearMarkers(mutableMarkers)
            mutableMarkers = []
            addOrUpdateClusters(clusters, animated: false)
        }
    }

    /// Renders clusters with animation based on zoom level.
    /// If zooming in, clusters will split; if zooming out, clusters will merge.
    /// - Parameter clusters: The clusters to render.
    ///
    func renderAnimatedClusters(_ clusters: [GMUCluster]) {
        guard let mapView else { return }
        let zoom: Float = mapView.camera.zoom
        let isZoomingIn: Bool = zoom > previousZoom

        /// Prepares the clusters for animation depending on the zoom direction.
        prepareClustersForAnimation(clusters, isZoomingIn: isZoomingIn)

        previousZoom = zoom

        self.clusters = clusters
        
        var existingMarkers: [GMSMarker] = mutableMarkers
        mutableMarkers = []

        /// Adds or updates clusters with animation based on zooming direction.
        addOrUpdateClusters(clusters, animated: isZoomingIn)

        // If the marker was re-added, remove it from existingMarkers which will be cleared
        for visibleMarker in mutableMarkers {
            existingMarkers.removeAll { $0 == visibleMarker }
        }

        /// Clears markers depending on zooming direction.
        if isZoomingIn {
            clearMarkers(existingMarkers)
        } else {
            clearMarkersAnimated(existingMarkers)
        }
    }

    /// Clears the specified markers with an animation, moving them to the nearest new cluster if applicable.
    ///
    /// - Parameter markers: An array of `GMSMarker` objects to be removed with animation.
    ///
    func clearMarkersAnimated(_ markers: [GMSMarker]) {
        guard let mapView else { return }
        /// Remove existing markers: animate to nearest new cluster.
        let visibleBounds: GMSCoordinateBounds = GMSCoordinateBounds(region: mapView.projection.visibleRegion())

        for marker in markers {
            guard let userData = marker.userData else { return }
            /// If the marker for the attached userData has just been added, do not perform animation.
            guard !renderedClusterItems.contains(userData) else {
                marker.map = nil
                continue
            }

            /// If the marker is outside the visible view port, do not perform animation.
            guard !visibleBounds.contains(marker.position) else {
                marker.map = nil
                continue
            }

            guard let itemToNewClusterMap else { return }
            /// Find a candidate cluster to animate to.
            var toCluster: GMUCluster?
            if let cluster = marker.userData as? GMUCluster {
                toCluster = overlappingCluster(for: cluster, itemMap: itemToNewClusterMap)
            } else {
                let key = GMUWrappingDictionaryKey(object: userData)
                toCluster = itemToNewClusterMap[key]
            }
            
            /// If there is not near by cluster to animate to, do not perform animation.
            guard let toCluster else {
                marker.map = nil
                continue
            }

            /// All is good, perform the animation.
            CATransaction.begin()
            CATransaction.setAnimationDuration(animationDuration)
            marker.layer.latitude = toCluster.position.latitude
            marker.layer.longitude = toCluster.position.longitude
            CATransaction.commit()
        }
        
        // Clear existing markers after the animation has ended.
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration * Double(NSEC_PER_SEC)) {
            self.clearMarkers(markers)
        }
    }

    /// Called when the camera is changed to reevaluate if new clusters need to be displayed
    /// because they have become visible.
    ///
    func update() {
        if let clusters {
            // Adds or updates clusters without animation.
            addOrUpdateClusters(clusters, animated: false)
        }
    }

    // MARK: - Private Methods
    /// Builds a lookup map that associates cluster items with their old or new clusters
    /// depending on whether the map is zooming in or zooming out.
    ///
    /// - Parameters:
    ///   - newClusters: An array of new `GMUCluster` objects.
    ///   - isZoomingIn: A boolean that indicates whether the map is zooming in (`true`) or out (`false`).
    ///
    func prepareClustersForAnimation(_ newClusters: [GMUCluster], isZoomingIn: Bool) {
        guard let mapView else { return }
        let zoom: Float = mapView.camera.zoom

        if isZoomingIn {
            itemToOldClusterMap = [:]
            guard let clusters else { return }
            for cluster in clusters {
                if !shouldRenderAsCluster(cluster, atZoom: zoom) && !shouldRenderAsCluster(cluster, atZoom: previousZoom) {
                    continue
                }
                for clusterItem in cluster.items {
                    let key = GMUWrappingDictionaryKey(object: clusterItem)
                    itemToOldClusterMap?[key] = cluster
                }
            }
            itemToNewClusterMap = nil
        } else {
            itemToOldClusterMap = nil
            itemToNewClusterMap = [:]
            for cluster in newClusters {
                if !shouldRenderAsCluster(cluster, atZoom: zoom) {
                    continue
                }
                for clusterItem in cluster.items {
                    let key: GMUWrappingDictionaryKey = GMUWrappingDictionaryKey(object: clusterItem)
                    itemToNewClusterMap?[key] = cluster
                }
            }
        }
    }

    /// Iterates through the given clusters and adds a marker for each cluster if:
    /// - The cluster is inside the visible region of the camera.
    /// - The cluster has not yet been added.
    ///
    /// - Parameters:
    ///   - clusters: An array of `GMUCluster` objects to be added or updated.
    ///   - animated: A boolean indicating whether the addition should be animated.
    ///
    func addOrUpdateClusters(_ clusters: [GMUCluster], animated: Bool) {
        guard let mapView else { return }
        let visibleBounds = GMSCoordinateBounds(region: mapView.projection.visibleRegion())

        for cluster in clusters {
            if renderedClusters.contains(cluster) {
                continue
            }

            var shouldShowCluster: Bool = visibleBounds.contains(cluster.position)
            let shouldRenderAsCluster: Bool = shouldRenderAsCluster(cluster, atZoom: mapView.camera.zoom)

            if !shouldShowCluster {
                for item in cluster.items {
                    if !shouldRenderAsCluster && visibleBounds.contains(item.position) {
                        shouldShowCluster = true
                        break
                    }
                    if animated {
                        let key: GMUWrappingDictionaryKey = GMUWrappingDictionaryKey(object: item)
                        if let oldCluster = itemToOldClusterMap?[key], visibleBounds.contains(oldCluster.position) {
                            shouldShowCluster = true
                            break
                        }
                    }
                }
            }

            if shouldShowCluster {
                renderCluster(cluster, animated: animated)
            }
        }
    }

    /// Renders the given cluster on the map. If the cluster should be rendered as a cluster, a cluster marker is added.
    /// Otherwise, individual items from the cluster are rendered.
    ///
    /// - Parameters:
    ///   - cluster: The `GMUCluster` to render.
    ///   - animated: A boolean indicating whether the rendering should be animated.
    ///
    func renderCluster(_ cluster: GMUCluster, animated: Bool) {
        guard let mapView else { return }
        let zoom = mapView.camera.zoom
        if shouldRenderAsCluster(cluster, atZoom: zoom) {
            var fromPosition: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
            var animated: Bool = animated
            if animated {
                if let fromCluster = overlappingCluster(for: cluster, itemMap: itemToOldClusterMap) {
                    animated = true
                    fromPosition = fromCluster.position
                } else {
                    animated = false
                }
            }

            guard let icon: UIImage = clusterIconGenerator.iconForSize(cluster.count) else {
                return
            }
            let marker: GMSMarker = markerWithPosition(cluster.position, from: fromPosition, userData: cluster, clusterIcon: icon, animated: animated)
            mutableMarkers.append(marker)
        } else {
            for item in cluster.items {
                var marker: GMSMarker
                if let itemMarker = item as? GMSMarker {
                    marker = itemMarker
                    marker.map = mapView
                } else {
                    var fromPosition: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
                    var shouldAnimate = animated
                    if shouldAnimate {
                        let key = GMUWrappingDictionaryKey(object: item)
                        if let fromCluster = itemToOldClusterMap?[key] {
                            fromPosition = fromCluster.position
                        }
                        shouldAnimate = true
                    } else {
                        shouldAnimate = false
                    }

                    marker = markerWithPosition(item.position, from: fromPosition, userData: item, clusterIcon: nil, animated: shouldAnimate)
                    if let title = item.title {
                        marker.title = title
                    }
                    if let snippet = item.snippet {
                        marker.snippet = snippet
                    }
                }
                mutableMarkers.append(marker)
                renderedClusterItems.add(item)
            }
        }
        renderedClusters.add(cluster)
    }

    /// Returns a `GMSMarker` for the given object.
    /// If the delegate implements `renderer(_:markerForObject:)`, it will use that method to obtain the marker.
    /// If no marker is provided by the delegate, a new `GMSMarker` is created and returned.
    ///
    /// - Parameter object: The object for which a marker is needed.
    /// - Returns: A `GMSMarker` for the object, either provided by the delegate or newly created.
    ///
    func marker(for object: Any) -> GMSMarker {
        if let marker = delegate?.renderer(self, markerForObject: object) {
            return marker
        }
        return GMSMarker()
    }

    /// Returns a marker at the final position of `position` with the attached `userData`.
    /// If `animated` is true, animates the marker from the specified `from` position.
    ///
    /// - Parameters:
    ///   - position: The final position of the marker.
    ///   - from: The initial position from which the marker should animate. If not animated, this is ignored.
    ///   - userData: The data to associate with the marker.
    ///   - clusterIcon: The icon for the cluster, if available. If nil, a default marker icon is used.
    ///   - animated: A boolean indicating whether the marker should animate to its position.
    /// - Returns: The created and rendered `GMSMarker`.
    ///
    func markerWithPosition(_ position: CLLocationCoordinate2D, from: CLLocationCoordinate2D, userData: Any, clusterIcon: UIImage?, animated: Bool) -> GMSMarker {
        let marker = marker(for: userData)
        let initialPosition: CLLocationCoordinate2D = animated ? from : position
        marker.position = initialPosition
        marker.userData = userData

        if let icon = clusterIcon {
            marker.icon = icon
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        }
        marker.zIndex = Int32(zIndex)

        delegate?.renderer(self, willRenderMarker: marker)

        marker.map = mapView

        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(animationDuration)
            marker.layer.latitude = position.latitude
            marker.layer.longitude = position.longitude
            CATransaction.commit()
        }

        delegate?.renderer(self, didRenderMarker: marker)

        return marker
    }

    /// Returns clusters which should be rendered and are inside the camera's visible region.
    /// Filters the clusters based on their visibility and whether they should be rendered as clusters
    /// at the current zoom level.
    ///
    /// - Parameter clusters: The array of clusters to check for visibility.
    /// - Returns: An array of clusters that are inside the visible region and should be rendered.
    ///
    func visibleClusters(from clusters: [GMUCluster]) -> [GMUCluster]? {
        guard let mapView else { return nil }
        var visibleClusters = [GMUCluster]()
        let zoom = mapView.camera.zoom
        let visibleBounds = GMSCoordinateBounds(region: mapView.projection.visibleRegion())

        for cluster in clusters {
            if !visibleBounds.contains(cluster.position) { continue }
            if !shouldRenderAsCluster(cluster, atZoom: zoom) { continue }
            visibleClusters.append(cluster)
        }
        return visibleClusters
    }

    /// Returns the first cluster in the `itemMap` that shares a common item with the input `cluster`.
    /// This is used to heuristically find a candidate cluster to animate to or from.
    ///
    /// - Parameters:
    ///   - cluster: The input `GMUCluster` for which to find an overlapping cluster.
    ///   - itemMap: A dictionary mapping `GMUWrappingDictionaryKey` to `GMUCluster`.
    ///
    /// - Returns: The first overlapping `GMUCluster`, or `nil` if no overlap is found.
    ///
    func overlappingCluster(for cluster: GMUCluster, itemMap: [GMUWrappingDictionaryKey: GMUCluster]?) -> GMUCluster? {
        var found: GMUCluster?
        for item in cluster.items {
            let key: GMUWrappingDictionaryKey = GMUWrappingDictionaryKey(object: item)
            if let itemMap, let candidate: GMUCluster = itemMap[key] {
                found = candidate
                break
            }
        }
        return found
    }

    /// Clears the specified markers by removing them from the map and resetting their `userData`.
    ///
    /// - Parameter markers: An array of `GMSMarker` objects to be removed.
    ///
    func clearMarkers(_ markers: [GMSMarker]) {
        for marker in markers {
            // If the marker's userData conforms to the GMUCluster protocol, reset its userData.
            if marker.userData is GMUCluster {
                marker.userData = nil
            }
            marker.userData = nil
            // Remove the marker from the map.
            marker.map = nil
        }
    }

    /// Removes all existing markers from the attached map.
    /// Clears the `mutableMarkers` array, and also removes all rendered clusters, cluster items,
    /// and clears the cluster item maps (`itemToNewClusterMap`, `itemToOldClusterMap`).
    /// Resets the clusters to nil.
    ///
    func clear() {
        clearMarkers(mutableMarkers)
        mutableMarkers.removeAll()
        renderedClusters.removeAllObjects()
        renderedClusterItems.removeAllObjects()
        itemToNewClusterMap?.removeAll()
        itemToOldClusterMap?.removeAll()
        clusters = nil
    }

}
