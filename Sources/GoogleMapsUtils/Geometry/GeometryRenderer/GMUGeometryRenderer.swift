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
/// The class responsible for rendering parsed KML geometries onto a Google Map using the Google Maps SDK.
/// 
public final class GMUGeometryRenderer {
    // MARK: - Properties
    /// The Map overlays
    var mapOverlays: [GMSOverlay]
    /// The Map to render the placemarks onto.
    private weak var map: GMSMapView?
    /// The list of parsed geometries to render onto the map.
    private var geometryContainers: [GMUGeometryContainer]
    /// The list of parsed styles to be applied to the placemarks.
    var styles: [String: GMUStyle]?
    /// The list of parsed style maps to be applied to the placemarks.
    var styleMaps: [String: GMUStyleMap]?
    /// The dispatch queue used to download images for ground overlays and point icons.
    private var queue: DispatchQueue
    /// Whether the map has been marked as cleared.
    private var isMapCleared: Bool = true
    /// StyleMap default state
    let styleMapDefaultState: String = "normal"

    // MARK: - Init
    /// Initializes an instance of the `GeometryRenderer` with the specified map, geometries, styles, and style maps.
    ///
    /// - Parameters:
    ///    - map: The `GMSMapView` where the geometries will be rendered.
    ///    - geometries: An array of geometries (`GMUGeometryContainer`) to be rendered on the map.
    ///    - styles: An array of styles (`GMUStyle`) to apply to the geometries.
    ///    - styleMaps: An array of style maps (`GMUStyleMap`) to map styles to geometries.
    public init(map: GMSMapView, geometries: [GMUGeometryContainer], styles: [GMUStyle]?, styleMaps: [GMUStyleMap]?) {
        self.map = map
        self.geometryContainers = geometries
        self.styles = GMUGeometryRenderer.stylesDictionary(from: styles)
        self.styleMaps = GMUGeometryRenderer.styleMapsDictionary(from: styleMaps)
        self.queue = DispatchQueue(label: "com.google.gmsutils", attributes: .concurrent)
        self.mapOverlays = []
    }

    public convenience init(map: GMSMapView, geometries: [GMUGeometryContainer]) {
        self.init(map: map, geometries: geometries, styles: nil)
    }

    public convenience init(map: GMSMapView, geometries: [GMUGeometryContainer], styles: [GMUStyle]?) {
        self.init(map: map, geometries: geometries, styles: styles, styleMaps: nil)
    }

    // MARK: - Test Helpers
    /// Renders the geometry containers onto the map.
    ///
    public func render() {
        isMapCleared = false
        renderGeometryContainers(geometryContainers)
    }

    /// Clears all the overlays from the map and marks the map as cleared.
    ///
    func clear() {
        isMapCleared = true
        mapOverlays.forEach { $0.map = nil }
        mapOverlays.removeAll()
    }

    /// Returns an array of the current map overlays.
    ///
    /// - Returns: An array of `GMSOverlay` objects currently rendered on the map.
    func getMapOverlays() -> [GMSOverlay] {
        return mapOverlays
    }

    // MARK: - `renderGeometryContainers`
    /// Renders a list of geometry containers on the map.
    ///
    /// - Parameter containers: An array of geometry containers (`GMUGeometryContainer`) to be rendered.
    private func renderGeometryContainers(_ containers: [GMUGeometryContainer]) {
        for container in containers {
            var style: GMUStyle? = container.style
            if style == nil, let placemark = container as? GMUPlacemark {
                let styleUrl = placemark.styleUrl ?? ""
                style = styles?[styleUrl] ?? getStyle(fromStyleMaps: styleUrl)
            }
            renderGeometryContainer(container: container, style: style)
        }
    }

    // MARK: - `getStyleFromStyleMaps`
    /// Retrieves a style based on the provided style URL from the style maps.
    ///
    /// - Parameter styleUrl: The style URL (`String`) to look up in the style maps.
    /// - Returns: The corresponding `GMUStyle` if found, otherwise `nil`.
    func getStyle(fromStyleMaps styleUrl: String?) -> GMUStyle? {
        guard let styleUrl,
              let styleMaps else {
            return nil
        }
        if let styleMap = styleMaps[styleUrl] {
            for pair in styleMap.pairs {
                if pair.key == styleMapDefaultState {
                    return styles?[pair.styleUrl]
                }
            }
        }
        return nil
    }

    // MARK: - `renderGeometryContainer`
    /// Renders a geometry container with the specified style.
    ///
    /// - Parameters:
    ///   - container: The geometry container (`GMUGeometryContainer`) that holds the geometry to be rendered.
    ///   - style: The style (`GMUStyle`) to be applied to the geometry.
    private func renderGeometryContainer(container: GMUGeometryContainer, style: GMUStyle?) {
        let geometry = container.geometry
        if let geometryCollection = geometry as? GMUGeometryCollection {
            renderMultiGeometry(geometryCollection, container: container, style: style)
        } else {
            renderGeometry(geometry: geometry, container: container, style: style)
        }
    }

    // MARK: - `renderMultiGeometry`
    /// Renders each geometry in a geometry collection.
    ///
    /// - Parameters:
    ///   - geometry: The geometry (`GMUGeometry`) to be rendered, which should be a `GMUGeometryCollection`.
    ///   - container: The geometry container (`GMUGeometryContainer`) holding the geometries.
    ///   - style: The style (`GMUStyle`) to apply to each geometry.
    private func renderMultiGeometry(_ geometry: GMUGeometry, container: GMUGeometryContainer, style: GMUStyle?) {
        guard let multiGeometry = geometry as? GMUGeometryCollection else {
            return
        }
        multiGeometry.geometries.forEach { singleGeometry in
            renderGeometry(geometry: singleGeometry, container: container, style: style)
        }
    }

    // MARK: - `renderGeometry`
    /// Renders a specific geometry based on its type and applies the given style.
    ///
    /// - Parameters:
    ///   - geometry: The geometry (`GMUGeometry`) to be rendered, which can be a point, line string, polygon, or ground overlay.
    ///   - container: The geometry container (`GMUGeometryContainer`) that holds the geometry and associated metadata.
    ///   - style: The style (`GMUStyle`) to apply to the geometry. This can be `nil` if no style is provided.
    private func renderGeometry(geometry: GMUGeometry, container: GMUGeometryContainer, style: GMUStyle?) {
        if let point = geometry as? GMUPoint {
            renderPoint(point: point, container: container, style: style)
        } else if let lineString = geometry as? GMULineString {
            renderLineString(lineString: lineString, container: container, style: style)
        } else if let polygon = geometry as? GMUPolygon {
            renderPolygon(polygon: polygon, container: container, style: style)
        } else if let groundOverlay = geometry as? GMUGroundOverlay {
            renderGroundOverlay(overlay: groundOverlay, placemark: container as? GMUPlacemark, style: style)
        }
    }

    // MARK: - `renderPoint`
    /// Renders a point on the map with the specified style and container information.
    ///
    /// - Parameters:
    ///   - point: The (`GMUPoint`) representing the location and properties of the point to be rendered.
    ///   - container: The (`GMUGeometryContainer`) that contains the point and any additional metadata.
    ///   - style: The (`GMUStyle`) to apply to the point, which includes properties like title, icon, and rotation.
    private func renderPoint(point: GMUPoint, container: GMUGeometryContainer, style: GMUStyle?) {
        let coordinate = point.coordinate
        let marker = GMSMarker(position: coordinate)

        configureMarker(marker, with: container, and: style)

        if let style, let iconUrl = style.iconUrl {
            loadImage(from: iconUrl, for: marker, with: CGFloat(style.scale))
        } else {
            marker.map = map
        }

        mapOverlays.append(marker)
    }

    // MARK: - `renderPoint` Helpers.
    /// Configures the marker with title, snippet, anchor, and rotation from the style and container.
    ///
    /// - Parameters:
    ///   - marker: The (`GMSMarker`) to be configured.
    ///   - container: The (`GMUGeometryContainer`) containing metadata to apply to the marker.
    ///   - style: The (`GMUStyle`) containing styling properties to apply to the marker.
    private func configureMarker(_ marker: GMSMarker, with container: GMUGeometryContainer, and style: GMUStyle?) {
        marker.isTappable = true
        
        if let placemark = container as? GMUPlacemark {
            marker.title = style?.title ?? placemark.title
            marker.snippet = placemark.snippet
        } else if let style {
            marker.title = style.title
        }

        guard let style else {
            debugPrint("style is nil.")
            return
        }
        marker.groundAnchor = style.anchor
        marker.rotation = CLLocationDegrees(style.heading)
    }

    /// Loads an image from the specified URL and applies it to the marker, adjusting its scale.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to load.
    ///   - marker: The `GMSMarker` to which the image will be applied.
    ///   - scale: The scale factor to adjust the image size.
    private func loadImage(from url: String, for marker: GMSMarker, with scale: CGFloat) {
        queue.async { [weak self] in
            guard let self,
                  let image = Self.image(fromPath: url),
                  let imageValue = image.cgImage else { return }
            let scaledImage = UIImage(cgImage: imageValue,
                                      scale: image.scale * scale,
                                      orientation: image.imageOrientation)

            DispatchQueue.main.async { [weak self] in
                guard let self,
                      !self.isMapCleared else { return }
                marker.icon = scaledImage
                marker.map = self.map
            }
        }
    }

    // MARK: - `renderLineString`
    /// Renders a line string on the map with the specified style and container information.
    ///
    /// - Parameters:
    ///   - lineString: The `GMULineString` representing the path of the line to be rendered.
    ///   - container: The `GMUGeometryContainer` that contains additional metadata for the line string.
    ///   - style: The `GMUStyle` to apply to the line string, including stroke width and color.
    private func renderLineString(lineString: GMULineString, container: GMUGeometryContainer, style: GMUStyle?) {
        let path = lineString.path
        let line = GMSPolyline(path: path)

        configureLine(line, with: style, and: container)

        line.map = map
        mapOverlays.append(line)
    }

    // MARK: - `renderLineString` Helpers.
    /// Configures the polyline with stroke width, color, and title based on the style and container.
    ///
    /// - Parameters:
    ///   - line: The `GMSPolyline` to be configured.
    ///   - style: The `GMUStyle` containing styling properties for the polyline.
    ///   - container: The `GMUGeometryContainer` containing metadata to apply to the polyline.
    private func configureLine(_ line: GMSPolyline, with style: GMUStyle?, and container: GMUGeometryContainer) {
        if let style {
            line.strokeWidth = CGFloat(style.width)
        }

        if let style,
           let strokeColor = style.strokeColor {
            line.strokeColor = strokeColor
        }

        if let placemark = container as? GMUPlacemark {
            line.title = placemark.title
        }

        line.isTappable = true
    }

    // MARK: - `renderPolygon`
    /// Renders a polygon on the map using the provided style and container.
    ///
    /// - Parameters:
    ///   - polygon: The `GMUPolygon` representing the geometry of the polygon to be rendered.
    ///   - container: The `GMUGeometryContainer` holding additional information about the polygon, such as titles.
    ///   - style: The `GMUStyle?` containing optional style properties, like fill and stroke, for the polygon.
    func renderPolygon(polygon: GMUPolygon, container: GMUGeometryContainer, style: GMUStyle?) {
        guard let outerBoundaries = polygon.paths.first else { return }

        var innerBoundaries: [GMSPath] = []
        if polygon.paths.count > 1 {
            innerBoundaries = Array(polygon.paths[1..<polygon.paths.count])
        }

        let holes: [GMSPath] = innerBoundaries.map { $0 }

        let poly: GMSPolygon = GMSPolygon(path: outerBoundaries)

        if let style,
            style.hasFill,
           let fillColor = style.fillColor {
            poly.fillColor = fillColor
        }

        if let style,
            style.hasStroke {
            if let strokeColor = style.strokeColor {
                poly.strokeColor = strokeColor
            }
            poly.strokeWidth = CGFloat(style.width)
        }

        if !holes.isEmpty {
            poly.holes = holes
        }

        if let placemark = container as? GMUPlacemark {
            poly.title = placemark.title
        }

        poly.isTappable = true
        poly.map = map
        mapOverlays.append(poly)
    }

    // MARK: - `renderGroundOverlay`
    /// Renders a ground overlay on the map for the given geometry container (placemark) and style.
    ///
    /// - Parameters:
    ///   - overlay: The `GMUGroundOverlay` containing the coordinates and image details for the ground overlay.
    ///   - placemark: The placemark associated with this ground overlay.
    ///   - style: The style that should be applied to this ground overlay.
    private func renderGroundOverlay(overlay: GMUGroundOverlay, placemark: GMUPlacemark?, style: GMUStyle?) {
        
        // Calculate the center coordinates between the northeast and southwest bounds
        var center: CLLocationCoordinate2D = calculateCenter(northEast: overlay.northEast, southWest: overlay.southWest)
        
        // Adjust the longitude for cases where the bounds cross the international date line
        adjustCenterLongitudeIfCrossingDateLine(northEast: overlay.northEast, southWest: overlay.southWest, center: &center)
        
        // Create bounds from the northeast and southwest coordinates, adjusted for the center
        let bounds = createBounds(northEast: overlay.northEast, southWest: overlay.southWest, center: center)
        
        // Create the GMSGroundOverlay object and apply basic properties
        let groundOverlay = GMSGroundOverlay(bounds: bounds, icon: nil)
        configureGroundOverlay(groundOverlay, with: overlay)
        
        // Load the icon image asynchronously
        loadGroundOverlayImageAsync(for: groundOverlay, overlay: overlay)
        
        // Add the ground overlay to the map and store it in the map overlays
        mapOverlays.append(groundOverlay)
    }

    // MARK: - `renderGroundOverlay` Helpers.
    /// Helper function to calculate the center coordinates between the given northeast and southwest bounds.
    /// This function computes the midpoint between the two coordinates to determine the center of a geographic region.
    ///
    /// - Parameters:
    ///   - northEast: The `CLLocationCoordinate2D` representing the northeastern corner of the bounds.
    ///   - southWest: The `CLLocationCoordinate2D` representing the southwestern corner of the bounds.
    /// - Returns: A `CLLocationCoordinate2D` representing the calculated center point between the northeast and southwest coordinates.
    private func calculateCenter(northEast: CLLocationCoordinate2D, southWest: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let centerLatitude = (northEast.latitude + southWest.latitude) / 2.0
        let centerLongitude = (northEast.longitude + southWest.longitude) / 2.0
        return CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    }

    /// Adjusts the center longitude if the coordinates cross the international date line.
    ///
    /// - Parameters:
    ///   - northEast: The coordinate representing the northeast corner of the bounds.
    ///   - southWest: The coordinate representing the southwest corner of the bounds.
    ///   - center: The center coordinate of the bounds. The longitude may be adjusted if the bounds cross the date line.
    private func adjustCenterLongitudeIfCrossingDateLine(northEast: CLLocationCoordinate2D, southWest: CLLocationCoordinate2D, center: inout CLLocationCoordinate2D) {
        if northEast.longitude < southWest.longitude {
            center.longitude = center.longitude >= 0 ? center.longitude - 180 : center.longitude + 180
        }
    }

    /// Creates a `GMSCoordinateBounds` object using the provided northEast, southWest, and center coordinates.
    ///
    /// - Parameters:
    ///   - northEast: The `CLLocationCoordinate2D` representing the northeastern corner of the bounds.
    ///   - southWest: The `CLLocationCoordinate2D` representing the southwestern corner of the bounds.
    ///   - center: The `CLLocationCoordinate2D` representing the center of the area bounded by the northEast and southWest coordinates.
    /// - Returns: A `GMSCoordinateBounds` object that represents the rectangular bounds based on the input coordinates.
    private func createBounds(northEast: CLLocationCoordinate2D, southWest: CLLocationCoordinate2D, center: CLLocationCoordinate2D) -> GMSCoordinateBounds {
        let northEastBounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: northEast, coordinate: center)
        let southWestBounds: GMSCoordinateBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: center)
        let bounds: GMSCoordinateBounds = northEastBounds.includingBounds(southWestBounds)
        return bounds
    }

    /// Configures the `GMSGroundOverlay` with the properties from the given `GMUGroundOverlay`.
    ///
    /// - Parameters:
    ///   - groundOverlay: The `GMSGroundOverlay` object to be configured, representing the overlay on the map.
    ///   - overlay: The `GMUGroundOverlay` object containing the configuration properties (e.g., zIndex, rotation).
    private func configureGroundOverlay(_ groundOverlay: GMSGroundOverlay, with overlay: GMUGroundOverlay) {
        groundOverlay.isTappable = true
        groundOverlay.zIndex = Int32(overlay.zIndex)
        groundOverlay.bearing = overlay.rotation
    }

    /// Asynchronously loads the image for the ground overlay and assigns it to the map.
    ///
    /// - Parameters:
    ///   - groundOverlay: The `GMSGroundOverlay` object that will display the image on the map.
    ///   - overlay: The `GMUGroundOverlay` object containing details about the overlay, including the image URL (href) and other configuration parameters like scaling.
    private func loadGroundOverlayImageAsync(for groundOverlay: GMSGroundOverlay, overlay: GMUGroundOverlay) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self,
                  let image = Self.image(fromPath: overlay.href) else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                groundOverlay.icon = image
                if !self.isMapCleared {
                    groundOverlay.map = self.map
                }
            }
        }
    }
}

// MARK: - Extension
extension GMUGeometryRenderer {

    // MARK: - `stylesDictionary`
    /// Converts an optional array of `GMUStyle` objects into a dictionary where the keys are the `styleID` and the values are the corresponding `GMUStyle` objects.
    /// 
    ///  - Parameter styles: An optional array of `GMUStyle` objects.
    ///  - Returns: A dictionary where the keys are `styleID` strings and the values are `GMUStyle1` objects, or `nil` if the input array is `nil`.
    private static func stylesDictionary(from styles: [GMUStyle]?) -> [String: GMUStyle]? {
        guard let styles = styles else { return nil }
        return Dictionary(uniqueKeysWithValues: styles.map { ($0.styleID, $0) })
    }

    // MARK: - `styleMapsDictionary`
    /// Converts an optional array of `GMUStyleMap` objects into a dictionary where the keys are the `styleMapId` and the values are the corresponding `GMUStyleMap` objects.
    ///
    /// - Parameter styleMaps: An optional array of `GMUStyleMap` objects.
    /// - Returns: A dictionary where the keys are `styleMapId` strings and the values are `GMUStyleMap1` objects, or `nil` if the input array is `nil`.
    private static func styleMapsDictionary(from styleMaps: [GMUStyleMap]?) -> [String: GMUStyleMap]? {
        guard let styleMaps = styleMaps else { return nil }
        return Dictionary(uniqueKeysWithValues: styleMaps.map { ($0.styleMapId, $0) })
    }

    // MARK: - `imageFromPath`
    /// Loads an image from the given file path or URL.
    ///
    /// - Parameter path: A string representing either a URL or a file path where the image is located.
    /// - Returns: A `UIImage` object if the image is successfully loaded, or `nil` if an error occurs.
    static func image(fromPath path: String?) -> UIImage? {
        guard let path else {
            return nil
        }
        if let url = URL(string: path) {
            do {
                let data = try Data(contentsOf: url)
                return UIImage(data: data)
            } catch {
                debugPrint("Error loading data: \(error.localizedDescription)")
                return nil
            }
        } else {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                return UIImage(data: data)
            } catch {
                debugPrint("Error loading data: \(error.localizedDescription)")
                return nil
            }
        }
    }
}

