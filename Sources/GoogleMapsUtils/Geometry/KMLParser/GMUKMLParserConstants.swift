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


// MARK: - KML Parser Constants
/// A collection of constants representing KML element names, attribute names, and regex patterns.
///
struct GMUKMLParserConstants {
    static let placemarkElementName = "Placemark"
    static let groundOverlayElementName = "GroundOverlay"
    static let styleElementName = "Style"
    static let styleMapElementName = "StyleMap"
    static let lineStyleElementName = "LineStyle"
    static let pointElementName = "Point"
    static let lineStringElementName = "LineString"
    static let polygonElementName = "Polygon"
    static let multiGeometryElementName = "MultiGeometry"
    static let innerBoundariesAttributeName = "innerBoundaries"
    static let outerBoundariesAttributeName = "outerBoundaries"
    static let hotspotElementName = "hotSpot"
    static let coordinatesElementName = "coordinates"
    static let randomAttributeValue = "random"
    static let fractionAttributeValue = "fraction"
    static let nameElementName = "name"
    static let descriptionElementName = "description"
    static let rotationElementName = "rotation"
    static let styleUrlElementName = "styleUrl"
    static let drawOrderElementName = "drawOrder"
    static let northElementName = "north"
    static let eastElementName = "east"
    static let southElementName = "south"
    static let westElementName = "west"
    static let zIndexElementName = "ZIndex"
    static let hrefElementName = "href"
    static let textElementName = "text"
    static let scaleElementName = "scale"
    static let xAttributeName = "x"
    static let yAttributeName = "y"
    static let xUnitsElementName = "xunits"
    static let yUnitsElementName = "yunits"
    static let idAttributeName = "id"
    static let outerBoundaryIsElementName = "outerBoundaryIs"
    static let headingElementName = "heading"
    static let fillElementName = "fill"
    static let outlineElementName = "outline"
    static let widthElementName = "width"
    static let colorElementName = "color"
    static let colorModeElementName = "colorMode"
    static let pairElementName = "Pair"
    static let keyAttributeValue = "key"
    static let pairAttributeRegexValue = "^(key|styleUrl)$"
    static let geometryRegexValue = "^(Point|LineString|Polygon|MultiGeometry)$"
    static let geometryAttributeRegexValue = "^(coordinates|name|description|rotation|drawOrder|href|styleUrl)$"
    static let compassRegexValue = "^(north|east|south|west)$"
    static let boundaryRegexValue = "^(outerBoundaryIs|innerBoundaryIs)$"
    static let styleRegexValue = "^(Style|StyleMap|LineStyle|Pair)$"
    static let styleAttributeRegexValue = "^(text|scale|heading|fill|outline|width|color|colorMode)$"
    static let styleUrlRegexValue = "#.+"
}

// MARK: - KML Parser State
/// Stores the current state of the parser with regards
/// to the type of KML node being processed.
///
struct GMUParserState: OptionSet {
    let rawValue: UInt
    static let placemark = GMUParserState(rawValue: 1 << 0)
    static let outerBoundary = GMUParserState(rawValue: 1 << 1)
    static let multiGeometry = GMUParserState(rawValue: 1 << 2)
    static let style = GMUParserState(rawValue: 1 << 3)
    static let styleMap = GMUParserState(rawValue: 1 << 4)
    static let lineStyle = GMUParserState(rawValue: 1 << 5)
    static let pair = GMUParserState(rawValue: 1 << 6)
    static let leafNode = GMUParserState(rawValue: 1 << 7)
}
