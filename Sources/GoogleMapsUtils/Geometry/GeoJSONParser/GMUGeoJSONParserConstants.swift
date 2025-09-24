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

// MARK: - Geo JSONParser Constants

/// Constants for GeoJSON parsing operations.
struct GMUGeoJSONParserConstants {
    /// JSON key for type field.
    static let typeMember: String = "type"

    /// JSON key for feature ID.
    static let idMember: String = "id"

    /// JSON key for geometry object.
    static let geometryMember: String = "geometry"

    /// JSON key for geometry collection.
    static let geometriesMember: String = "geometries"

    /// JSON key for feature properties.
    static let propertiesMember: String = "properties"

    /// JSON key for bounding box.
    static let boundingBoxMember: String = "bbox"

    /// JSON key for coordinate array.
    static let coordinatesMember: String = "coordinates"

    /// JSON key for feature collection.
    static let featuresMember: String = "features"

    /// Type value for Feature.
    static let featureValue: String = "Feature"

    /// Type value for FeatureCollection.
    static let featureCollectionValue: String = "FeatureCollection"

    /// Type value for Point geometry.
    static let pointValue: String = "Point"

    /// Type value for MultiPoint geometry.
    static let multiPointValue: String = "MultiPoint"

    /// Type value for LineString geometry.
    static let lineStringValue: String = "LineString"

    /// Type value for MultiLineString geometry.
    static let multiLineStringValue: String = "MultiLineString"

    /// Type value for Polygon geometry.
    static let polygonValue: String = "Polygon"

    /// Type value for MultiPolygon geometry.
    static let multiPolygonValue: String = "MultiPolygon"

    /// Type value for GeometryCollection.
    static let geometryCollectionValue: String = "GeometryCollection"

    /// Regex pattern for valid geometry types.
    static let geometryRegex: String = "^(Point|MultiPoint|LineString|MultiLineString|Polygon|MultiPolygon|GeometryCollection)$"
}
