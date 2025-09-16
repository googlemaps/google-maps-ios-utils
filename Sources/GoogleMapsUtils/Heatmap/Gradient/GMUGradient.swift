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

/// Represents a mapping of intensity to color. Interpolates between a given set of intensities and
/// color values to produce a full mapping for the range [0, 1].
///
///
/// ```swift
/// let gradient = try GMUGradient(
///     colors: [.blue, .green, .yellow, .red],
///     startPoints: [0.0, 0.3, 0.7, 1.0],
///     colorMapSize: 256
/// )
/// heatmapLayer.gradient = gradient
/// ```
///
/// ## Topics
///
/// ### Creating Gradients
/// - ``init(colors:startPoints:colorMapSize:)``
///
/// ### Color Mapping
/// - ``generateColorMap()``
public final class GMUGradient {

    // MARK: - Properties
    /// Number of entries in the generated color map.
    let mapSize: Int
    /// The specific colors for the specific intensities specified by startPoints.
    let colors: [UIColor]
    /// The intensities that will map to specific colors in `colors`.
    let startPoints: [CGFloat]

    // MARK: - Init
    /// Creates a color gradient for heatmap visualization.
    ///
    /// - Parameters:
    ///   - colors: Array of colors to interpolate between
    ///   - startPoints: Intensity values (0.0-1.0) for each color, in ascending order
    ///   - colorMapSize: Resolution of the color map (minimum: 2, recommended: 256)
    /// - Throws: `GMUGradientError` if parameters are invalid
    public init(colors: [UIColor], startPoints: [CGFloat], colorMapSize: Int) throws {
        guard !colors.isEmpty && colors.count == startPoints.count else {
            throw GMUGradientError.invalidArgumentException("colors' size: \(colors.count) is not equal to startPoints' size: \(startPoints.count)")
        }
        
        for i in 1..<startPoints.count {
            if startPoints[i - 1] > startPoints[i] {
                throw GMUGradientError.invalidArgumentException("startPoints' are not in non-descending order.")
            }
        }

        guard startPoints.first! >= 0 && startPoints.last! <= 1 else {
            throw GMUGradientError.invalidArgumentException("startPoints' are not all in the range [0,1].")
        }

        guard colorMapSize >= 2 else {
            throw GMUGradientError.invalidArgumentException("mapSize is less than 2.")
        }
        
        self.colors = colors
        self.startPoints = startPoints
        self.mapSize = colorMapSize
    }
    
    // MARK: - Public method
    /// Generates an array of interpolated colors for the range [0, 1].
    /// If the provided startPoints do not cover the range 0 to 1,
    ///  lower values interpolate towards transparent black and higher values repeat the last provided color.
    ///
    /// - Returns: An array of UIColor objects interpolated based on the intensity values.
    public func generateColorMap() -> [UIColor] {
        var colorMap: [UIColor] = []
        var curStartPoint: Int = 0

        for i in 0..<mapSize {
            let targetValue = i / mapSize - 1

            while curStartPoint < startPoints.count && CGFloat(targetValue) >= startPoints[curStartPoint] {
                curStartPoint += 1
            }
    
            if curStartPoint == startPoints.count {
                colorMap.append(colors[curStartPoint - 1])
                continue
            }
            
            let curValue: CGFloat = startPoints[curStartPoint]
            let prevValue: CGFloat = curStartPoint == 0 ? 0 : startPoints[curStartPoint - 1]
            let curColor: UIColor = colors[curStartPoint]
            let prevColor: UIColor = curStartPoint == 0 ? UIColor.clear : colors[curStartPoint - 1]

            let ratio = (CGFloat(targetValue) - prevValue) / (curValue - prevValue)
            colorMap.append(interpolateColor(from: prevColor, to: curColor, ratio: ratio))
        }

        return colorMap
    }

    // MARK: - Private method
    /// Interpolates between two colors using HSB and alpha values.
    ///
    /// - Parameters:
    ///   - fromColor: The starting color.
    ///   - toColor: The ending color.
    ///   - ratio: The interpolation ratio (0.0 to 1.0).
    /// - Returns: The interpolated UIColor.
    private func interpolateColor(from fromColor: UIColor, to toColor: UIColor, ratio: CGFloat) -> UIColor {
        var fromHue: CGFloat = 0
        var fromSaturation: CGFloat = 0
        var fromBrightness: CGFloat = 0
        var fromAlpha: CGFloat = 0

        /// If color can't be converted, fallback to bands of color.
        /// TODO: raise an error instead?
        guard fromColor.getHue(&fromHue, saturation: &fromSaturation, brightness: &fromBrightness, alpha: &fromAlpha) else {
            return fromColor
        }

        var toHue: CGFloat = 0
        var toSaturation: CGFloat = 0
        var toBrightness: CGFloat = 0
        var toAlpha: CGFloat = 0

        /// If color can't be converted, fallback to bands of color.
        /// TODO: raise an error instead?
        guard toColor.getHue(&toHue, saturation: &toSaturation, brightness: &toBrightness, alpha: &toAlpha) else {
            return fromColor
        }

        // Adjust hue to interpolate across the shortest path around the color wheel.
        var targetHue: CGFloat = fromHue + (toHue - fromHue) * ratio
        if toHue - fromHue > 0.5 {
            targetHue = fmod((1.0 + fromHue) + (toHue - fromHue - 1.0) * ratio, 1.0)
        } else if toHue - fromHue < -0.5 {
            targetHue = fmod((fromHue) + (toHue + 1.0 - fromHue) * ratio, 1.0)
        }

        let targetSaturation: CGFloat = fromSaturation + (toSaturation - fromSaturation) * ratio
        let targetBrightness: CGFloat = fromBrightness + (toBrightness - fromBrightness) * ratio
        let targetAlpha: CGFloat = fromAlpha + (toAlpha - fromAlpha) * ratio

        return UIColor(hue: targetHue, saturation: targetSaturation, brightness: targetBrightness, alpha: targetAlpha)
    }
}
