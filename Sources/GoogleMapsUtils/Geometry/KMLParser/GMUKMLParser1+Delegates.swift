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

/// TO-DO: Rename the class to `GMUKMLParser` once the linking is done and remove the objective c class.
/// This extension provides the delegate(`XMLParserDelegate`) implementations, of the `GMUKMLParser` class.
/// 
extension GMUKMLParser1 {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        characters = nil
        if let styleRegex, let _ = styleRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) {
            parseBeginStyle(with: elementName, styleID: attributeDict[GMUKMLParserConstants.idAttributeName])
        } else if elementName == GMUKMLParserConstants.placemarkElementName || elementName == GMUKMLParserConstants.groundOverlayElementName {
            parseBeginPlacemark()
        } else if elementName == GMUKMLParserConstants.hotspotElementName {
            parseBeginHotspot(with: attributeDict)
        } else if let geometryRegex,
                  geometryRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil ||
                    elementName == GMUKMLParserConstants.groundOverlayElementName {
            parseBeginGeometry(withElementName: elementName)
        } else if let boundaryRegex,
                  boundaryRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil {
            parseBeginBoundary(with: elementName)
        } else if let styleAttributeRegex,
                  let geometryAttributeRegex,
                  let compassRegex,
                  let pairAttributeRegex,
                  styleAttributeRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil ||
                    geometryAttributeRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil ||
                    compassRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil ||
                    pairAttributeRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil {
            parseBeginLeafNode()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let styleRegex,
            styleRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil {
            parseEndStyle()
        } else if let styleAttributeRegex,
                    styleAttributeRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil {
            parseEndStyleAttribute(elementName)
        } else if elementName == GMUKMLParserConstants.placemarkElementName {
            parseEndPlacemark()
        } else if let pairAttributeRegex,
                    pairAttributeRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil {
            parseEndPairAttribute(elementName)
        } else if elementName == GMUKMLParserConstants.groundOverlayElementName {
            parseEndGroundOverlay()
        } else if let geometryRegex,
                    geometryRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil {
            parseEndGeometry(withElementName: elementName)
        } else if let geometryAttributeRegex,
                    geometryAttributeRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil {
            parseEndGeometryAttribute(elementName)
        } else if let compassRegex,
                  compassRegex.firstMatch(in: elementName, options: [], range: NSRange(location: 0, length: elementName.count)) != nil {
            parseEndCompassAttribute(elementName)
        }
        parserState.remove(.leafNode)
        characters = nil
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isParsing(.leafNode) {
            guard var characters, !characters.isEmpty else {
                characters = string
                return
            }
            characters.append(string)
        }
    }
}
