// Copyright 2025 Google LLC
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

/// # Geometry Module
///
/// Parse and render GeoJSON and KML data on Google Maps.
///
/// ## Overview
///
/// The Geometry module provides parsers for GeoJSON and KML formats, along with a renderer
/// to display the parsed geometries on a Google Maps view.
///
/// ```swift
/// let parser = GMUGeoJSONParser(url: geoJSONURL)
/// parser.parse()
/// let renderer = GMUGeometryRenderer(mapView: mapView, geometries: parser.features)
/// renderer.render()
/// ```
///
/// ## Topics
///
/// ### Parsers
/// - ``GMUGeoJSONParser``
/// - ``GMUKMLParser``
///
/// ### Rendering
/// - ``GMUGeometryRenderer``
///
/// ### Geometry Types
/// - ``GMUPoint``
/// - ``GMULineString``
/// - ``GMUPolygon``
/// - ``GMUGeometryCollection``
/// - ``GMUGroundOverlay``
///
/// ### Containers
/// - ``GMUFeature``
/// - ``GMUPlacemark``
///
/// ### Styling
/// - ``GMUStyle``
/// - ``GMUStyleMap``
/// - ``GMUPair``
///
/// ### Protocols
/// - ``GMUGeometry``
/// - ``GMUGeometryContainer``
public struct GeometryDocumentation {

    /// Private initializer to prevent instantiation.
    ///
    /// This struct exists solely for documentation organization and should never be instantiated.
    /// It serves as a namespace to group Geometry module documentation in one place.
    private init() {}
}
