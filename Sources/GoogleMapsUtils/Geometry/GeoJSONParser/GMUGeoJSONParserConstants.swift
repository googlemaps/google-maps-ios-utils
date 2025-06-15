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
struct GMUGeoJSONParserConstants {
    static let typeMember: String = "type"
    static let idMember: String = "id"
    static let geometryMember: String = "geometry"
    static let geometriesMember: String = "geometries"
    static let propertiesMember: String = "properties"
    static let boundingBoxMember: String = "bbox"
    static let coordinatesMember: String = "coordinates"
    static let featuresMember: String = "features"
    static let featureValue: String = "Feature"
    static let featureCollectionValue: String = "FeatureCollection"
    static let pointValue: String = "Point"
    static let multiPointValue: String = "MultiPoint"
    static let lineStringValue: String = "LineString"
    static let multiLineStringValue: String = "MultiLineString"
    static let polygonValue: String = "Polygon"
    static let multiPolygonValue: String = "MultiPolygon"
    static let geometryCollectionValue: String = "GeometryCollection"
    static let geometryRegex: String = "^(Point|MultiPoint|LineString|MultiLineString|Polygon|MultiPolygon|GeometryCollection)$"
}
