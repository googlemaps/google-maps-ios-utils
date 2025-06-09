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

import UIKit

/// Instances of this class represent a geometry Style. It is used to define the
/// stylings of any number of GMUGeometry objects.
///
public struct GMUStyle: Equatable {
    // MARK: - Properties
    /// The unique identifier of the style
    private(set) var styleID: String
    /// The color for the stroke of a LineString or Polygon.
    private(set) var strokeColor: UIColor?
    /// The color for the fill of a Polygon.
    private(set) var fillColor: UIColor?
    /// The width of a LineString
    private(set) var width: Float
    /// The scale that a Point's icon should be rendered at.
    private(set) var scale: Float
    /// The direction, in degrees, that a Point's icon should be rendered at.
    private(set) var heading: Float
    /// The position within an icon that is anchored to the Point.
    private(set) var anchor: CGPoint
    /// The href for the icon to be used for a Point.
    private(set) var iconUrl: String?
    /// The title to use for a Point.
    private(set) var title: String?
    /// Whether the Polygon has a defined fill color.
    private(set) var hasFill: Bool
    /// Whether the LineString or Polygon has a defined stroke color.
    private(set) var hasStroke: Bool
}
