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
import CoreLocation

/// Instances of this class parse GeoJSON data. The parsed features are stored in NSArray objects
/// which can then be passed to a GMUGeometryRenderer to display on a Google Map.
///
public final class GMUGeoJSONParser {

    // MARK: - Properties
    /// The data object containing the GeoJSON to be parsed.
    private var data: Data?
    /// The stream containing the GeoJSON to be parsed.
    private var stream: InputStream?
    /// The parsed GeoJSON file.
    private var parsedJSONDictionary: [String : Any]?
    /// The bounding box for a FeatureCollection. This will only be set when parsing a
    /// FeatureCollection.
    private var boundingBox: GMSCoordinateBounds?
    /// The format that a geometry element may take.
    private var geometryRegex: NSRegularExpression?
    /// The format that a multigeometry element may take.
    private var multiGeometryRegex: NSRegularExpression?
    /// Whether the parser has completed parsing the input file.
    private var isParsed: Bool = false
    /// The list of parsed Features.
    private var gmuFeatures: [GMUFeature] = []
    /// Retrive parsed features
    public var features: [GMUFeature] {
        return gmuFeatures
    }

    // MARK: - Init's
    /// Initializes a GMUGeoJSONParser with GeoJSON data.
    ///
    /// - Parameter data: The GeoJSON data.
    public init(data: Data) {
        self.data = data
        sharedInit()
    }

    /// Initializes a GMUGeoJSONParser with GeoJSON data contained in an input stream.
    ///
    /// - Parameter stream: The stream to use to access GeoJSON data.
    public init(stream: InputStream) {
        self.stream = stream
        sharedInit()
    }

    /// Initializes a GMUGeoJSONParser with GeoJSON data contained in a URL.
    ///
    /// - Parameter url: The url containing GeoJSON data.
    public init(url: URL) {
        do {
            data = try Data(contentsOf: url)
        } catch {
            debugPrint("Invalid url contents")
        }
        sharedInit()
    }

    /// Shared Init across all the other init's
    private func sharedInit() {
        gmuFeatures = []
        do {
            geometryRegex = try NSRegularExpression(pattern: GMUGeoJSONParserConstants.geometryRegex)
        } catch {
            debugPrint("Invalid Geometry Regex")
        }
    }

    // MARK: - Parse
    /// Parses the stored GeoJSON data.
    public func parse() {
        guard !isParsed else {
            debugPrint("Data and Input Stream is already parsed")
            return
        }

        parseJSONData()

        guard let parsedJSONDictionary else {
            debugPrint("parsedJSONDictionary is nil")
            return
        }

        handleGeoJSONType(in: parsedJSONDictionary)

        isParsed = true
    }

    // MARK: - `parse` Helpers
    /// Parse JSON from data & stream
    ///
    private func parseJSONData() {
        if let data = data {
            parsedJSONDictionary = parseJSON(from: data)
        } else if let stream = stream {
            parsedJSONDictionary = parseJSON(from: stream)
        }
    }

    /// Parse JSON from data
    ///
    /// - Parameter stream: Data
    /// - Returns: [String: Any]?
    private func parseJSON(from data: Data) -> [String: Any]? {
        do {
            if let dataDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return dataDictionary
            } else {
                debugPrint("Invalid Data")
                return nil
            }
        } catch {
            return nil
        }
    }

    /// Parse JSON from stream
    ///
    /// - Parameter stream: InputStream
    /// - Returns: [String: Any]?
    private func parseJSON(from stream: InputStream) -> [String: Any]? {
        stream.open()
        defer { stream.close() }

        do {
            if let streamDictionary = try JSONSerialization.jsonObject(with: stream, options: []) as? [String: Any] {
                return streamDictionary
            } else {
                debugPrint("Invalid Inputstream")
                return nil
            }
        } catch {
            return nil
        }
    }

    /// Handle GeoJSON type
    ///
    /// - Parameter dictionary: [String: Any]
    private func handleGeoJSONType(in dictionary: [String: Any]) {
        guard let type = dictionary[GMUGeoJSONParserConstants.typeMember] as? String else {
            return
        }
        
        switch type {
        case GMUGeoJSONParserConstants.featureValue:
            handleFeatureType(in: dictionary)
        case GMUGeoJSONParserConstants.featureCollectionValue:
            handleFeatureCollectionType(in: dictionary)
        default:
            handleGeometryType(type, in: dictionary)
        }
    }

    /// Append an `[GMUFeature]` to gmuFeatures
    /// featureFromDictionary` should be non-nil
    ///
    /// - Parameter dictionary: [String: Any]
    private func handleFeatureType(in dictionary: [String: Any]) {
        if let feature = featureFromDictionary(dictionary) {
            gmuFeatures.append(feature)
        } else {
            debugPrint("feature from dictionary is nil")
        }
    }

    /// Append an `[GMUFeature]` to gmuFeatures
    /// `featureCollectionFromDictionary` should be non-nil
    ///
    /// - Parameter dictionary: [String: Any]
    private func handleFeatureCollectionType(in dictionary: [String: Any]) {
        if let featuresArray = featureCollectionFromDictionary(dictionary) {
            gmuFeatures.append(contentsOf: featuresArray)
        } else {
            debugPrint("feature collection from dictionary is nil")
        }
    }

    /// Append an `[GMUFeature]` to gmuFeatures
    /// The type string should match the geometryRegex pattern
    /// `featurefromGeometryDictionary` should be non-nil
    ///
    /// - Parameters:
    ///   - type: String
    ///   - dictionary: [String: Any]
    private func handleGeometryType(_ type: String, in dictionary: [String: Any]) {
        guard let geometryRegex else { return }
        if geometryRegex.firstMatch(in: type, options: [], range: NSRange(location: 0, length: type.count)) != nil,
           let feature = featurefromGeometryDictionary(dictionary) {
            gmuFeatures.append(feature)
        } else {
            debugPrint("feature from geometry dictionary is nil")
        }
    }

    // MARK: - Get Feature From Dictionary
    /// Creates `GMUFeature` from a Dictionary
    ///
    /// - Parameter feature: [String: Any]
    /// - Returns: GMUFeature?
    func featureFromDictionary(_ feature: [String: Any]) -> GMUFeature? {
        guard let gmuGeometry = extractGeometry(from: feature) else { return nil }
        let identifier: String? = feature[GMUGeoJSONParserConstants.idMember] as? String
        let properties: [String : NSObject]? = feature[GMUGeoJSONParserConstants.propertiesMember] as? [String: NSObject]
        let coordinateBounds: GMSCoordinateBounds? = extractBoundingBox(from: feature)

        return GMUFeature(
            geometry: gmuGeometry,
            identifier: identifier,
            properties: properties,
            boundingBox: coordinateBounds
        )
    }

    // MARK: - `featureFromDictionary` Helpers
    /// Creates `GMUGeometry` from a Dictionary
    ///
    /// - Parameter feature: [String: Any]
    /// - Returns: GMUGeometry?
    private func extractGeometry(from feature: [String: Any]) -> GMUGeometry? {
        guard let geometryDictionary = feature[GMUGeoJSONParserConstants.geometryMember] as? [String: Any] else {
            return nil
        }
        return geometryfromDictionary(geometryDictionary)
    }
    
    /// Creates `GMSCoordinateBounds` from a Dictionary
    ///
    /// - Parameter feature: [String: Any]
    /// - Returns: GMSCoordinateBounds?
    private func extractBoundingBox(from feature: [String: Any]) -> GMSCoordinateBounds? {
        if let boundingBox {
            return boundingBox
        } else if let boundingBoxCoordinates = feature[GMUGeoJSONParserConstants.boundingBoxMember] as? [Double] {
            return boundingBoxFromCoordinates(boundingBoxCoordinates)
        }

        return nil
    }

    // MARK: - feature Collection From Dictionary
    /// Creates an array of `GMUFeature` from the given dictionary
    ///
    /// - Parameter features: [String: Any]
    /// - Returns: [GMUFeature]?
    func featureCollectionFromDictionary(_ features: [String: Any]) -> [GMUFeature]? {
        updateBoundingBox(from: features)
        return parseFeatures(from: features)
    }

    // MARK: - `featureCollectionFromDictionary` Helper
    /// Update BoundingBox from Features dictionary
    ///
    /// - Parameter features: [String: Any]
    private func updateBoundingBox(from features: [String: Any]) {
        if let boundingBoxCoordinates = features[GMUGeoJSONParserConstants.boundingBoxMember] as? [Double] {
            boundingBox = boundingBoxFromCoordinates(boundingBoxCoordinates)
        } else {
            debugPrint("Invalid dictionary type")
        }
    }
    
    /// Creates an array of `GMUFeature` from the features dictionary
    /// Returns an array containing the non-nil `[GMUFeature]`.
    ///
    /// - Parameter features: [String: Any]
    /// - Returns: [GMUFeature]?
    private func parseFeatures(from features: [String: Any]) -> [GMUFeature]? {
        guard let geoJSONFeatures = features[GMUGeoJSONParserConstants.featuresMember] as? [[String: Any]] else {
            return nil
        }
        
        return geoJSONFeatures.compactMap { feature in
            guard let typeMember = feature[GMUGeoJSONParserConstants.typeMember] as? String,
                  typeMember == GMUGeoJSONParserConstants.featureValue else {
                return nil
            }
            return featureFromDictionary(feature)
        }
    }

    /// Creates a GMSCoordinateBounds object from a set of coordinates.
    ///
    /// - Parameter coordinates: The coordinates for the bounding box in the order west, south, east, north.
    /// - Returns: A bounding box with the specified coordinates.
    func boundingBoxFromCoordinates(_ coordinates: [Double]) -> GMSCoordinateBounds? {
        guard coordinates.count >= 4 else {
            return nil
        }

        let southWest = CLLocationCoordinate2D(latitude: coordinates[1] , longitude: coordinates[0])
        let northEast = CLLocationCoordinate2D(latitude: coordinates[3] , longitude: coordinates[2])

        return GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
    }

    // MARK: - Get geometry from dictionary
    /// Creates the `GMUGeometry` object from the dictionary
    ///
    /// - Parameter dictionary: [String: Any]
    /// - Returns: GMUGeometry?
    func geometryfromDictionary(_ dictionary: [String: Any]) -> GMUGeometry? {
        /// Get the type of the Geometry
        guard let geometryType = extractGeometryType(from: dictionary) else { return nil }
        /// Get the array of Geometry
        let geometryArray = extractGeometryArray(from: dictionary, for: geometryType)
        /// creates the `GMUGeometry` object from the dictionary
        return geometryArray.isEmpty ? nil : geometrywithGeometryType(geometryType, geometryArray: geometryArray)
    }

    // MARK: - `geometryfromDictionary` Helpers
    /// Extracts the type of the Geometry
    ///
    /// - Parameter dictionary: [String: Any]
    /// - Returns: String?
    private func extractGeometryType(from dictionary: [String: Any]) -> String? {
        return dictionary[GMUGeoJSONParserConstants.typeMember] as? String
    }

    /// Generates the Array of Geometry of type [[String: Any]]
    /// & multidimensional array of Doubles
    ///
    /// - Parameters:
    ///   - dictionary: [String: Any]
    ///   - geometryType: String
    /// - Returns: [Any]
    private func extractGeometryArray(from dictionary: [String: Any], for geometryType: String) -> [Any] {
        switch geometryType {
        case GMUGeoJSONParserConstants.geometryCollectionValue:
            return dictionary[GMUGeoJSONParserConstants.geometriesMember] as? [[String: Any]] ?? []
        case GMUGeoJSONParserConstants.geometriesMember:
            return dictionary[GMUGeoJSONParserConstants.geometryCollectionValue] as? [[String: Any]] ?? []
        default:
            return isGeometryType(geometryType) ? (dictionary[GMUGeoJSONParserConstants.coordinatesMember] as? [Any] ?? []) : []
        }
    }
    
    /// Type should match `geometryRegex` pattern
    ///
    /// - Parameter type: String
    /// - Returns: Bool
    private func isGeometryType(_ type: String) -> Bool {
        guard let geometryRegex else { return false }
        return geometryRegex.firstMatch(in: type, options: [], range: NSRange(location: 0, length: type.count)) != nil
    }
    
    /// Creates `GMUFeature` from the geometry JSON
    ///
    /// - Parameter geometryJSON: [String : Any]
    /// - Returns: GMUFeature?
    func featurefromGeometryDictionary(_ geometryJSON: [String : Any]) -> GMUFeature? {
        let geometry = geometryfromDictionary(geometryJSON)
        guard let geometry else {
            return nil
        }
        return GMUFeature(
            geometry: geometry,
            identifier: nil,
            properties: nil,
            boundingBox: nil)
    }

    // MARK: - geometry with GeometryType
    /// Generates `GMUGeometry` object
    /// from the given `geometryType` & `geometryArray`
    ///
    /// - Parameters:
    ///   - geometryType: String
    ///   - geometryArray: [Any]
    /// - Returns: GMUGeometry
    func geometrywithGeometryType(_ geometryType: String, geometryArray: [Any]) -> GMUGeometry? {
        switch geometryType {
        case GMUGeoJSONParserConstants.pointValue:
            guard let values = geometryArray as? [Double] else { return nil }
            return pointwithCoordinate(values)
        case GMUGeoJSONParserConstants.multiPointValue:
            guard let values = geometryArray as? [[Double]] else { return nil }
            return multiPointwithCoordinates(values)
        case GMUGeoJSONParserConstants.lineStringValue:
            guard let values = geometryArray as? [[Double]] else { return nil }
            return lineStringWithCoordinates(values)
        case GMUGeoJSONParserConstants.multiLineStringValue:
            guard let values = geometryArray as? [[[Double]]] else { return nil }
            return multiLineStringWithCoordinates(values)
        case GMUGeoJSONParserConstants.polygonValue:
            guard let values = geometryArray as? [[[Double]]] else { return nil }
            return polygonWithCoordinates(values)
        case GMUGeoJSONParserConstants.multiPolygonValue:
            guard let values = geometryArray as? [[[[Double]]]] else { return nil }
            return multiPolygonwithCoordinates(values)
        case GMUGeoJSONParserConstants.geometryCollectionValue:
            guard let values = geometryArray as? [[String: Any]] else { return nil }
            return geometryCollectionwithGeometries(values)
        default:
            return nil
        }
    }
    
    // MARK: - `geometrywithGeometryType` Helpers
    /// Generates `GMUPoint` from the array of coordinates
    ///
    /// - Parameter coordinate: [Double]
    /// - Returns: GMUPoint?
    func pointwithCoordinate(_ coordinates: [Double]) -> GMUPoint? {
        guard let locationFromCoordinateCoordinate = locationFromCoordinate(coordinates) else { return nil }
        return GMUPoint(coordinate: locationFromCoordinateCoordinate.coordinate)
    }
    
    /// Generates `GMUGeometryCollection1` from the array of multipoint coordinates
    ///
    /// - Parameter coordinates: [[Double]]
    /// - Returns: GMUGeometryCollection?
    func multiPointwithCoordinates(_ coordinates: [[Double]]) -> GMUGeometryCollection? {
        let points: [GMUPoint] = coordinates.compactMap { pointwithCoordinate($0) }
        return points.isEmpty ? nil : GMUGeometryCollection(geometries: points)
    }

    /// Generates `GMULineString` from the array of linestring coordinates
    ///
    /// - Parameter coordinates: [[Double]]
    /// - Returns: GMULineString?
    func lineStringWithCoordinates(_ coordinates: [[Double]]) -> GMULineString? {
        // Convert the array of coordinates to a GMSPath
        if let path: GMSPath = pathFromCoordinateArray(coordinates) {
            // Initialize and return a GMULineString with the path
            return GMULineString(path: path)
        }
        return nil
    }

    /// Generates `GMUGeometryCollection` from the array of multi linestring coordinates
    ///
    /// - Parameter coordinates: [[[Double]]]
    /// - Returns: GMUGeometryCollection?
    func multiLineStringWithCoordinates(_ coordinates: [[[Double]]]) -> GMUGeometryCollection {
        let lineStrings: [GMULineString] = coordinates.compactMap { lineStringWithCoordinates($0) }
        return GMUGeometryCollection(geometries: lineStrings)
    }

    /// Generates `GMUPolygon` from the array of polygon coordinates
    ///
    /// - Parameter coordinates: [[[Double]]]
    /// - Returns: GMUPolygon?
    func polygonWithCoordinates(_ coordinates: [[[Double]]]) -> GMUPolygon {
        var pathArray: [GMSPath] = []
        pathArray = pathArrayFromCoordinateArrays(coordinates)
        return GMUPolygon(paths: pathArray)
    }

    /// Generates `GMUGeometryCollection` from the array of polygon coordinates
    ///
    /// - Parameter coordinates: [[[[Double]]]]
    /// - Returns: GMUGeometryCollection?
    func multiPolygonwithCoordinates(_ coordinates: [[[[Double]]]]) -> GMUGeometryCollection {
        let polygons: [GMUPolygon] = coordinates.map { polygonWithCoordinates($0) }
        return GMUGeometryCollection(geometries: polygons)
    }
    
    /// Generates `GMUGeometryCollection` from the array of geometry dictionary
    ///
    /// - Parameter geometries: [[String : Any]]
    /// - Returns: GMUGeometryCollection?
    func geometryCollectionwithGeometries(_ geometries: [[String : Any]]) -> GMUGeometryCollection {
        let elements: [GMUGeometry] = geometries.compactMap { geometryfromDictionary($0) }
        return GMUGeometryCollection(geometries: elements)
    }
    
    /// Generates `CLLocation` from the array of coordinates
    ///
    /// - Parameter coordinate: [Double]
    /// - Returns: CLLocation?
    func locationFromCoordinate(_ coordinate: [Double]) -> CLLocation? {
        // Ensure the array has at least two elements for latitude and longitude
        guard coordinate.count >= 2 else {
            return nil
        }

        // Return a CLLocation initialized with the latitude and longitude
        return CLLocation(latitude: coordinate[1], longitude: coordinate[0])
    }

    /// Generates `GMSPath` from the array of coordinates
    ///
    /// - Parameter coordinate: [[Double]]
    /// - Returns: GMSPath?
    func pathFromCoordinateArray(_ coordinates: [[Double]]) -> GMSPath? {
        let path = GMSMutablePath()
        coordinates.compactMap { locationFromCoordinate($0)?.coordinate }
            .forEach { path.add($0) }
        return path
    }

    /// Generates `[GMSPath]` from the array of coordinates
    ///
    /// - Parameter coordinate: [[[Double]]]
    /// - Returns: [GMSPath]
    func pathArrayFromCoordinateArrays(_ coordinates: [[[Double]]]) -> [GMSPath] {
        return coordinates.compactMap { pathFromCoordinateArray($0) }
    }
}
