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

/// The class responsible for parsing KML documents, using the XMLParserDelegate protocol.
///
import UIKit
import CoreLocation
import GoogleMaps

final class GMUKMLParser: NSObject, XMLParserDelegate {
    // MARK: - Properties
    /// The XML parser used to read the specified document.
    private var parser: XMLParser
    /// The format that a geometry element may take.
    var geometryRegex: NSRegularExpression?
    /// The format that a compass coordinate element may take.
    var compassRegex: NSRegularExpression?
    /// The format that a boundary element may take.
    var boundaryRegex: NSRegularExpression?
    /// The format that a style element may take.
    var styleRegex: NSRegularExpression?
    /// The format that a style attribute element may take.
    var styleAttributeRegex: NSRegularExpression?
    /// The format that a style URL element may take.
    private var styleUrlRegex: NSRegularExpression?
    /// The format that a geometry attribute element may take.
    var geometryAttributeRegex: NSRegularExpression?
    /// The format that a pair in a style map may take.
    var pairAttributeRegex: NSRegularExpression?
    /// The list of placemarks that have been parsed.
    private var placemarks: [GMUPlacemark]
    /// The list of styles that have been parsed.
    private var styles: [GMUStyle]
    /// The list of style maps that have been parsed.
    private var styleMaps: [GMUStyleMap]
    /// The list of pairs that the currently parsed style map contains.
    private var pairs: [GMUPair]
    /// The characters contained within the element being parsed.
    var characters: String?
    /// The properties to be propagated into the KMLPlacemark object being parsed.
    private var geometry: GMUGeometry?
    private var geometries: [GMUGeometry]
    private var title: String?
    private var snippet: String?
    private var inlineStyle: GMUStyle?
    private var styleUrl: String?
    /// The properties to be propagated into the KMLStyle object being parsed.
    private var styleID: String?
    private var strokeColor: UIColor?
    private var fillColor: UIColor?
    private var width: Float = 0.0
    private var scale: Float = 0.0
    private var heading: Float = 0.0
    private var anchor: CGPoint = .zero
    private var strokeColorMode: String?
    private var fillColorMode: String?
    private var iconUrl: String?
    private var styleTitle: String?
    private var hasFill: Bool
    private var hasStroke: Bool
    /// The properties to be propagated into the KMLElement object being parsed.
    private var attributes: [String: Any]
    private var geometryType: String?
    /// The properties to be propagated into the KMLPair object being parsed.
    private var key: String?
    /// The current state of the parser.
    var parserState: GMUParserState = []

    // MARK: - Initializers
    /// Initializes the parser with an XML parser.
    ///
    init(parser: XMLParser) {
        self.parser = parser
        self.placemarks = []
        self.styles = []
        self.styleMaps = []
        self.pairs = []
        self.geometries = []
        self.attributes = [:]
        self.hasFill = true
        self.hasStroke = true

        do {
            self.geometryRegex = try NSRegularExpression(pattern: GMUKMLParserConstants.geometryRegexValue, options: [])
            self.compassRegex = try NSRegularExpression(pattern: GMUKMLParserConstants.compassRegexValue, options: [])
            self.boundaryRegex = try NSRegularExpression(pattern: GMUKMLParserConstants.boundaryRegexValue, options: [])
            self.styleRegex = try NSRegularExpression(pattern: GMUKMLParserConstants.styleRegexValue, options: [])
            self.styleAttributeRegex = try NSRegularExpression(pattern: GMUKMLParserConstants.styleAttributeRegexValue, options: [])
            self.styleUrlRegex = try NSRegularExpression(pattern: GMUKMLParserConstants.styleUrlRegexValue, options: [])
            self.geometryAttributeRegex = try NSRegularExpression(pattern: GMUKMLParserConstants.geometryAttributeRegexValue, options: [])
            self.pairAttributeRegex = try NSRegularExpression(pattern: GMUKMLParserConstants.pairAttributeRegexValue, options: [])
        } catch {
            debugPrint("Failed to initialize regular expressions: \(error)")
        }

        super.init()
        self.parser.delegate = self
    }

    /// Initializes the parser with a URL.
    ///
    convenience init?(url: URL) {
        guard let parser = XMLParser(contentsOf: url) else {
            debugPrint("Invalid URL")
            return nil
        }
        self.init(parser: parser)
    }

    /// Initializes the parser with Data.
    ///
    convenience init(data: Data) {
        self.init(parser: XMLParser(data: data))
    }

    /// Initializes the parser with an input stream.
    ///
    convenience init(stream: InputStream) {
        self.init(parser: XMLParser(stream: stream))
    }

    // MARK: - Test Helpers
    /// A read-only property that returns the list of parsed placemarks.
    /// This is called from Unit test class.
    /// 
    var placemarksArray: [GMUPlacemark] {
        return placemarks
    }

    /// A read-only property that returns the list of parsed styles.
    /// This is called from Unit test class.
    ///
    var stylesArray: [GMUStyle] {
        return styles
    }

    /// A read-only property that returns the list of parsed style maps.
    /// This is called from Unit test class.
    ///
    var styleMapsArray: [GMUStyleMap] {
        return styleMaps
    }

    /// This called to start the event-driven parse.
    /// This is called from Unit test class.
    ///
    func parse() {
        parser.parse()
    }

    // MARK: - `isParsing`
    /// Checks if the parser is currently in a specified state.
    ///
    /// - Parameter state: The parser state to check against the current parser state.
    /// - Returns: `true` if the specified state is currently active, otherwise `false`.
    func isParsing(_ state: GMUParserState) -> Bool {
        return state.rawValue & parserState.rawValue != 0
    }

    // MARK: - `locationFromString`
    /// Creates a `CLLocation` object from a string containing latitude and longitude.
    ///
    /// - Parameter string: A string representing the location, formatted as "longitude,latitude".
    /// - Returns: A `CLLocation` object initialized with the extracted latitude and longitude.
    func location(from string: String) -> CLLocation? {
        // Trim whitespace and newline characters from the string
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Split the string into components using a comma as the separator
        let coordinateStrings = trimmedString.split(separator: ",")
        
        // Ensure that there are exactly two components (longitude and latitude)
        guard coordinateStrings.count >= 2,
              let longitude = CLLocationDegrees(coordinateStrings[0].trimmingCharacters(in: .whitespacesAndNewlines)),
              let latitude = CLLocationDegrees(coordinateStrings[1].trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }
        
        // Return a CLLocation object with the parsed latitude and longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    // MARK: - `pathFromString`
    /// Creates a `GMSPath` object from a string containing coordinates.
    ///
    /// - Parameter string: A string representing the coordinates, with each coordinate separated by whitespace or newline characters.
    /// - Returns: A `GMSPath` object initialized with the coordinates parsed from the string.
    func path(from string: String) -> GMSPath {
        let trimmedString: String = trimAndReplaceWhitespace(from: string)
        let coordinateArray: [String] = splitCoordinates(from: trimmedString)
        let path: GMSPath = createPath(from: coordinateArray)
        return path
    }

    // MARK: - `pathFromString` Helpers.
    /// Trims and replaces multiple whitespace characters with a single space.
    ///
    /// - Parameter string: The input string to process.
    /// - Returns: A processed string with extra whitespace replaced.
    private func trimAndReplaceWhitespace(from string: String) -> String {
        let characterSet: CharacterSet = CharacterSet.whitespacesAndNewlines
        let coordinateStrings: String = string.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return coordinateStrings.trimmingCharacters(in: characterSet)
    }

    /// Splits the processed string into an array of coordinate substrings.
    ///
    /// - Parameter string: The processed string containing coordinates.
    /// - Returns: An array of coordinate substrings.
    private func splitCoordinates(from string: String) -> [String] {
        return string.components(separatedBy: CharacterSet.whitespacesAndNewlines)
    }

    /// Creates a `GMSPath` object from an array of coordinate strings.
    ///
    /// - Parameter coordinates: An array of coordinate strings.
    /// - Returns: A `GMSPath` object initialized with the coordinates.
    private func createPath(from coordinates: [String]) -> GMSPath {
        let path: GMSMutablePath = GMSMutablePath()

        coordinates
            .compactMap { location(from: $0) }
            .forEach { path.add($0.coordinate) }

        return path
    }

    // MARK: - `colorFromString`
    /// Converts a hex string representing a color into a UIColor.
    ///
    /// - Parameter string: A hex color string, optionally prefixed with '#'.
    /// - Returns: A UIColor created from the hex string. Returns UIColor.clear if parsing fails.
    func color(from string: String) -> UIColor {
        let hexString = preprocessHexString(string)
        guard let color = parseHexColor(hexString) else {
            return .clear
        }
        return colorComponents(from: color)
    }

    // MARK: - `colorFromString` Helpers.
    /// Preprocesses the hex color string by removing the '#' character and trimming whitespace.
    ///
    /// - Parameter string: The original hex color string.
    /// - Returns: A cleaned hex color string without '#' and trimmed of whitespace.
    private func preprocessHexString(_ string: String) -> String {
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
    }

    /// Parses a cleaned hex string into a `UInt64` color value.
    ///
    /// - Parameter hexString: The cleaned hex color string.
    /// - Returns: An optional UInt64 color value if parsing succeeds, otherwise nil.
    private func parseHexColor(_ hexString: String) -> UInt64? {
        var color: UInt64 = 0
        let scanner = Scanner(string: hexString)
        return scanner.scanHexInt64(&color) ? color : nil
    }

    /// Converts a `UInt64` color value to `UIColor` components.
    ///
    /// - Parameter color: The `UInt64` color value.
    /// - Returns: A `UIColor` object with components extracted from the `UInt64` value.
    private func colorComponents(from color: UInt64) -> UIColor {
        let alpha = CGFloat((color >> 24) & 0xff) / 255
        let blue = CGFloat((color >> 16) & 0xff) / 255
        let green = CGFloat((color >> 8) & 0xff) / 255
        let red = CGFloat(color & 0xff) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    // MARK: - `randomColorFromColor`
    /// Generates a random color by applying a random linear scale to each color component,
    /// while keeping the alpha component of the input color unchanged.
    ///
    /// - Parameter color: The color range to generate random values between.
    /// - Returns: The randomly generated color.
    func randomColor(from color: UIColor) -> UIColor {
        // Extract color components from the input color
        let components = extractColorComponents(from: color)

        // Generate random color components
        let randomRed: CGFloat = randomColorComponent(from: components.red)
        let randomGreen: CGFloat = randomColorComponent(from: components.green)
        let randomBlue: CGFloat = randomColorComponent(from: components.blue)

        // Return the newly generated UIColor
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: components.alpha)
    }

    // MARK: - `randomColorFromColor` Helpers.
    /// Extracts the red, green, blue, and alpha components from a UIColor.
    ///
    /// - Parameter color: The UIColor to extract components from.
    /// - Returns: A tuple containing the red, green, blue, and alpha components of the color.
    private func extractColorComponents(from color: UIColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }

    /// Generates a random color component based on the maximum value of the provided component.
    ///
    /// - Parameter component: The maximum value for the color component.
    /// - Returns: A random color component value ranging from 0 to the specified maximum.
    private func randomColorComponent(from component: CGFloat) -> CGFloat {
        let maxComponentValue: UInt32 = UInt32(component * 255)
        let randomValue: CGFloat = CGFloat(arc4random_uniform(maxComponentValue + 1)) / 255.0
        return randomValue
    }

    // MARK: - `parseBeginLeafNode`
    /// Updates the parser state to include the `leafNode` state.
    ///
    func parseBeginLeafNode() {
        parserState.insert(.leafNode)
    }

    // MARK: - `parseBeginHotspotWithAttributes`
    /// Parses the hotspot attributes and updates the `anchor` property.
    ///
    /// - Parameter attributes: A dictionary containing hotspot attribute values.
    func parseBeginHotspot(with attributes: [String: String]) {
        // Extract coordinates and determine if the hotspot is valid
        let (x, y, isValidHotspot) = extractCoordinates(from: attributes)

        // Update the anchor property based on validity of hotspot
        anchor = isValidHotspot ? CGPoint(x: x, y: y) : CGPoint(x: 0.5, y: 1.0)
    }

    // MARK: - `parseBeginHotspotWithAttributes` Helper.
    /// Extracts x and y coordinates from the attributes and checks if they are valid.
    ///
    /// - Parameter attributes: A dictionary containing hotspot attribute values.
    /// - Returns: A tuple containing the x and y coordinates as `Double`, and a `Bool` indicating if the hotspot is valid.
    private func extractCoordinates(from attributes: [String: String]) -> (Double, Double, Bool) {
        // Default coordinates and validity flag
        var x: Double = 0.0
        var y: Double = 0.0
        var isValidHotspot: Bool = true

        // Check and extract x coordinate
        if attributes[GMUKMLParserConstants.xUnitsElementName] == GMUKMLParserConstants.fractionAttributeValue,
           let xString = attributes[GMUKMLParserConstants.xAttributeName],
           let xValue = Double(xString) {
            x = xValue
        } else {
            isValidHotspot = false
        }

        // Check and extract y coordinate
        if attributes[GMUKMLParserConstants.yUnitsElementName] == GMUKMLParserConstants.fractionAttributeValue,
           let yString = attributes[GMUKMLParserConstants.yAttributeName],
           let yValue = Double(yString) {
            y = yValue
        } else {
            isValidHotspot = false
        }
        
        return (x, y, isValidHotspot)
    }

    // MARK: - `parseBeginBoundaryWithElementName`
    /// Parses the boundary element and updates the parser state.
    ///
    /// - Parameter elementName: The name of the boundary element being parsed.
    func parseBeginBoundary(with elementName: String) {
        switch elementName {
        case GMUKMLParserConstants.outerBoundaryIsElementName:
            parserState.insert(.outerBoundary)
        default:
            parserState.remove(.outerBoundary)
        }
    }

    // MARK: - `parseBeginStyleWithElementName`
    /// Begins parsing a style element and updates the parser state accordingly.
    ///
    /// - Parameters:
    ///   - elementName: The name of the element being parsed.
    ///   - styleID: The ID of the style being processed.
    func parseBeginStyle(with elementName: String, styleID: String?) {
        // If styleID is provided, assign it with a prefix "#"
        if let styleID {
            self.styleID = "#\(styleID)"
        }

        // Use switch to handle different element names
        switch elementName {
        case GMUKMLParserConstants.styleElementName:
            parserState.insert(.style)

        case GMUKMLParserConstants.styleMapElementName:
            parserState.insert(.styleMap)

        case GMUKMLParserConstants.lineStyleElementName:
            parserState.insert(.lineStyle)

        case GMUKMLParserConstants.pairElementName:
            parserState.insert(.pair)

        default:
            break
        }
    }

    // MARK: - `parseEndStyle`
    /// Ends the parsing of a style and handles the style-specific logic.
    ///
    func parseEndStyle() {
        // Use a switch-case to determine which parser state is currently active
        switch parserState {
        case _ where isParsing(.lineStyle):
            // Remove the `lineStyle` parser state
            removeParserState(.lineStyle)
        case _ where isParsing(.pair):
            // Remove the `pair` parser state and handle the end of the pair parsing
            removeParserState(.pair)
            parseEndPair()
        case _ where isParsing(.styleMap):
            // Remove the `styleMap` parser state and handle style map creation
            removeParserState(.styleMap)
            handleStyleMap()
        default:
            // Remove the `style` parser state
            removeParserState(.style)
            // Handle the style creation logic
            handleStyle()
        }
    }

    // MARK: - `parseEndStyle` Helpers.
    /// Removes a specific parser state from the current parser state.
    ///
    /// - Parameter state: The parser state to remove (e.g., `.lineStyle`, `.styleMap`).
    private func removeParserState(_ state: GMUParserState) {
        parserState.remove(state)
    }

    /// Handles the end of the `styleMap` parsing, 
    /// creating a `GMUStyleMap` and adding it to the styleMaps list.
    /// 
    private func handleStyleMap() {
        guard let styleID else {
            debugPrint("styleID is nil")
            return
        }
        let styleMap = GMUStyleMap(styleMapId: styleID, pairs: pairs)
        styleMaps.append(styleMap)
        pairs.removeAll()
    }

    /// Handles the end of the `style` parsing, 
    /// finalizing the style properties, and creating a `GMUStyle` object.
    ///
    private func handleStyle() {
        guard let styleID else {
            debugPrint("styleID is nil")
            return
        }

        if var fillColor,
            fillColorMode == GMUKMLParserConstants.randomAttributeValue {
            fillColor = randomColor(from: fillColor)
        }

        if var strokeColor,
            strokeColorMode == GMUKMLParserConstants.randomAttributeValue {
            strokeColor = randomColor(from: strokeColor)
        }

        let style = GMUStyle(
            styleID: styleID,
            strokeColor: strokeColor,
            fillColor: fillColor,
            width: width,
            scale: scale,
            heading: heading,
            anchor: anchor,
            iconUrl: iconUrl,
            title: styleTitle,
            hasFill: hasFill,
            hasStroke: hasStroke
        )
        resetStyleProperties()

        if isParsing(.placemark) {
            inlineStyle = style
        } else {
            styles.append(style)
        }
    }

    /// Resets all style-related properties to their default values,
    /// after the style parsing is complete.
    ///
    private func resetStyleProperties() {
        styleID = nil
        strokeColor = nil
        fillColor = nil
        width = 0
        scale = 0
        heading = 0
        anchor = .zero
        iconUrl = nil
        styleTitle = nil
        hasFill = true
        hasStroke = true
    }

    /// Parse End Pair
    ///
    private func parseEndPair() {
        if let key, let styleUrl {
            let pair = GMUPair(key: key, styleUrl: styleUrl)
            pairs.append(pair)
        }
        key = nil
        styleUrl = nil
    }

    // MARK: - `parseEndStyleAttribute`
    /// Handles the end of a style attribute parsing.
    /// Depending on the attribute name, this method assigns the corresponding parsed value to a style property.
    ///
    /// - Parameter attribute: The attribute name that needs to be processed.
    func parseEndStyleAttribute(_ attribute: String) {
        guard let characters else {
            debugPrint("characters is nil.")
            return
        }
        switch attribute {

        case GMUKMLParserConstants.textElementName:
            styleTitle = characters

        case GMUKMLParserConstants.scaleElementName:
            scale = Float(characters) ?? 0.0

        case GMUKMLParserConstants.headingElementName:
            heading = Float(characters) ?? 0

        case GMUKMLParserConstants.fillElementName:
            hasFill = characters == "1" ? true : false

        case GMUKMLParserConstants.outlineElementName:
            hasStroke = characters == "1" ? true : false

        case GMUKMLParserConstants.widthElementName:
            width = Float(characters) ?? 0.0

        case GMUKMLParserConstants.colorElementName:
            if isParsing(.lineStyle) {
                strokeColor = color(from: characters)
            } else {
                fillColor = color(from: characters)
            }

        case GMUKMLParserConstants.colorModeElementName:
            if isParsing(.lineStyle) {
                strokeColorMode = characters
            } else {
                fillColorMode = characters
            }

        default:
            break
        }
    }

    // MARK: - `parseBeginPlacemark`
    /// Parse Placemark begin.
    ///
    func parseBeginPlacemark() {
        parserState.insert(.placemark)
    }

    // MARK: - `parseEndGroundOverlay`
    /// Parses the end of a ground overlay element and creates a corresponding geometry object.
    ///
    func parseEndGroundOverlay() {
        guard let northEast: CLLocationCoordinate2D = extractCoordinate(latitudeKey: GMUKMLParserConstants.northElementName, longitudeKey: GMUKMLParserConstants.eastElementName),
                let southWest: CLLocationCoordinate2D = extractCoordinate(latitudeKey: GMUKMLParserConstants.southElementName, longitudeKey: GMUKMLParserConstants.westElementName) else {
            debugPrint("northEast, or southWest is nil")
            return
        }

        var zIndex: Int = 0
        if let zIndexValue = attributes[GMUKMLParserConstants.zIndexElementName] as? Int {
            zIndex = zIndexValue
        }

        var rotation: Double = 0.0
        if let rotationValue = attributes[GMUKMLParserConstants.rotationElementName] as? Double {
            rotation = rotationValue
        }

        var href: String = ""
        if let hrefValue = attributes[GMUKMLParserConstants.hrefElementName] as? String {
            href = hrefValue
        }

        geometry = GMUGroundOverlay(northEast: northEast, southWest: southWest, zIndex: zIndex, rotation: rotation, href: href)

        parseEndPlacemark()
    }
    
    // MARK: - `parseEndPlacemark`
    /// Parse Placemark end.
    ///
    func parseEndPlacemark() {
        parserState.remove(.placemark)
        if let geometry {
            let placemark = GMUPlacemark(geometry: geometry, style: inlineStyle, title: title, snippet: snippet, styleUrl: styleUrl)
            placemarks.append(placemark)
        }
        geometryType = nil
        attributes = [:]
        geometry = nil
        geometries = []
        title = nil
        snippet = nil
        inlineStyle = nil
        styleUrl = nil
    }

    /// Extracts a coordinate from the attributes dictionary using latitude and longitude keys.
    ///
    /// - Parameters:
    ///   - latitudeKey: The key for extracting the latitude.
    ///   - longitudeKey: The key for extracting the longitude.
    /// - Returns: The extracted CLLocationCoordinate2D value.
    private func extractCoordinate(latitudeKey: String, longitudeKey: String) -> CLLocationCoordinate2D? {
        guard let latitude: CLLocationDegrees = attributes[latitudeKey] as? CLLocationDegrees, 
                let longitude: CLLocationDegrees = attributes[longitudeKey] as? CLLocationDegrees else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: - `parseBeginGeometryWithElementName`
    /// Begins parsing the geometry based on the element name.
    ///
    /// - Parameter elementName: The name of the geometry element being parsed.
    func parseBeginGeometry(withElementName elementName: String) {
        switch elementName {
        case GMUKMLParserConstants.multiGeometryElementName:
            parserState.insert(.multiGeometry)
        default:
            geometryType = elementName
        }
    }

    // MARK: - `parseEndGeometryWithElementName`
    /// Processes the end of a geometry element based on the element name.
    ///
    /// - Parameter elementName: The name of the geometry element being parsed.
    func parseEndGeometry(withElementName elementName: String) {
        switch elementName {
        case GMUKMLParserConstants.multiGeometryElementName:
            handleMultiGeometryEnd()
        default:
            handleSpecificGeometryEnd(for: elementName)
        }
    }

    // MARK: - `parseEndGeometryWithElementName` Helpers.
    /// Handles the end of a multiGeometry element.
    /// Creates a geometry collection and adds it to the geometries list.
    ///
    private func handleMultiGeometryEnd() {
        parserState.remove(.multiGeometry)
        geometry = GMUGeometryCollection(geometries: geometries)
    }

    /// Handles the end of a specific geometry type based on the element name.
    ///
    /// - Parameter elementName: The name of the geometry element being parsed.
    private func handleSpecificGeometryEnd(for elementName: String) {
        switch elementName {
        case GMUKMLParserConstants.pointElementName:
            handlePointElement()
        case GMUKMLParserConstants.lineStringElementName:
            handleLineStringElement()
        case GMUKMLParserConstants.polygonElementName:
            handlePolygonElement()
        default:
            break
        }
        if isParsing(.multiGeometry) {
            if let geometry {
                geometries.append(geometry)
            }
            geometry = nil
            attributes.removeAll()
        }
    }

    /// Handles the end of a point element.
    /// Sets the geometry value to a Points instance.
    ///
    private func handlePointElement() {
        if let coordinate: CLLocation = attributes[GMUKMLParserConstants.coordinatesElementName] as? CLLocation {
            geometry = GMUPoint(coordinate: coordinate.coordinate)
        } else {
            debugPrint("coordinate is nil.")
        }
    }

    /// Handles the end of a lineString element.
    /// Sets the geometry value to a LineString instance.
    ///
    private func handleLineStringElement() {
        if let path: GMSPath = attributes[GMUKMLParserConstants.coordinatesElementName] as? GMSPath {
            geometry = GMULineString(path: path)
        } else {
            debugPrint("path is nil.")
        }
    }

    /// Handles the end of a polygon element.
    /// Sets the geometry value to a Polygon instance with outer and inner boundaries.
    ///
    private func handlePolygonElement() {
        if let outerBoundaries: GMSPath = attributes[GMUKMLParserConstants.outerBoundariesAttributeName] as? GMSPath {
            var paths: [GMSPath] = [outerBoundaries]
            if let holes: [GMSPath] = attributes[GMUKMLParserConstants.innerBoundariesAttributeName] as? [GMSPath] {
                holes.forEach { path in
                    paths.append(path)
                }
            } else {
                debugPrint("holes is nil.")
            }
            geometry = GMUPolygon(paths: paths)
        } else {
            debugPrint("outerBoundaries is nil.")
        }
    }

    // MARK: - `parseEndGeometryAttribute`
    /// Processes the end of a geometry attribute based on its type and updates corresponding properties.
    ///
    /// - Parameter attribute: The name of the attribute being parsed, which determines the property to be updated.
    func parseEndGeometryAttribute(_ attribute: String) {
        switch attribute {
        case GMUKMLParserConstants.coordinatesElementName:
            parseEndCoordinates()
        case GMUKMLParserConstants.nameElementName:
            title = characters
        case GMUKMLParserConstants.descriptionElementName:
            snippet = characters
        case GMUKMLParserConstants.rotationElementName:
            parseEndRotation()
        case GMUKMLParserConstants.drawOrderElementName:
            guard let characters else {
                debugPrint("characters is nil.")
                return
            }
            attributes[GMUKMLParserConstants.zIndexElementName] = Int(characters)
        case GMUKMLParserConstants.hrefElementName:
            if isParsing(.style) {
                iconUrl = characters
            } else {
                attributes[attribute] = characters
            }
        case GMUKMLParserConstants.styleUrlElementName:
            if let characters,
               let styleUrlRegex,
               let _ = styleUrlRegex.firstMatch(in: characters, options: [], range: NSRange(location: 0, length: characters.count )) {
                styleUrl = characters
            }
        default:
            break
        }
    }

    // MARK: - `parseEndGeometryAttribute` Helpers.
    /// Handles the parsing of the end of coordinates based on the geometry type.
    ///
    /// Depending on whether the geometry is a point, line, or polygon, it processes the coordinates
    /// and updates the corresponding attributes accordingly.
    ///
    private func parseEndCoordinates() {
        guard let characters else {
            debugPrint("characters is nil.")
            return
        }
        switch geometryType {
        case GMUKMLParserConstants.pointElementName:
            if let location = location(from: characters) {
                attributes[GMUKMLParserConstants.coordinatesElementName] = location
            }
        case GMUKMLParserConstants.lineStringElementName:
            attributes[GMUKMLParserConstants.coordinatesElementName] = path(from: characters)
        case GMUKMLParserConstants.polygonElementName:
            let boundary = path(from: characters)
            if isParsing(.outerBoundary) {
                attributes[GMUKMLParserConstants.outerBoundariesAttributeName] = boundary
            } else {
                var innerBoundaries = attributes[GMUKMLParserConstants.innerBoundariesAttributeName] as? [GMSPath] ?? []
                innerBoundaries.append(boundary)
                attributes[GMUKMLParserConstants.innerBoundariesAttributeName] = innerBoundaries
            }
        default:
            break
        }
    }

    /// Parses the rotation attribute and,
    /// adjusts the rotation value to be within the correct range.
    /// The rotation is transformed from the range of [-180, 180],
    /// to [0, 360] and handles invalid inputs.
    ///
    private func parseEndRotation() {
        guard let characters else {
            debugPrint("characters is nil.")
            return
        }
        var rotation = Double(characters) ?? 0.0

        if rotation > 180 || rotation < -180 {
            rotation = 0
        }

        if rotation <= 0 {
            rotation = -rotation
        } else {
            rotation = 360 - rotation
        }

        attributes[GMUKMLParserConstants.rotationElementName] = rotation
    }

    // MARK: - `parseEndCompassAttribute`
    /// Parses the compass attribute by converting,
    /// the characters into a double value and storing it in the attributes dictionary.
    ///
    /// - Parameter attribute: String
    func parseEndCompassAttribute(_ attribute: String) {
        if let characters,
           let value = Double(characters) {
            attributes[attribute] = value
        }
    }

    // MARK: - `parseEndPairAttribute`
    /// Parses and assigns values to specific attributes.
    ///
    /// - Parameter attribute: The name of the attribute being parsed.
    func parseEndPairAttribute(_ attribute: String) {
        switch attribute {
        case GMUKMLParserConstants.keyAttributeValue:
            key = characters
        case GMUKMLParserConstants.styleUrlElementName:
            styleUrl = characters
        default:
            break
        }
    }
}
