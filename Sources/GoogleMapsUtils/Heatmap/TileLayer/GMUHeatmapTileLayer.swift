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

/// A tile layer that renders a heatmap.
/// The heatmap uses convolutional smoothing with a specific radius and weighted data points.
/// It applies a gradient to map intensity to colors for dynamically generated tiles.
/// Tiles are loaded on background threads, but the configuration properties are non-atomic.
/// To ensure consistency, the configuration properties are captured when changing the `map` property.
/// To change the values of a live layer, the `map` property must be reset.
/// The default opacity is set to 0.7, and the tile size is fixed at 512.
///
/// ```swift
/// let heatmapLayer = GMUHeatmapTileLayer()
/// heatmapLayer.weightedData = [GMUWeightedLatLng(coordinate: location, intensity: 1.0)]
/// heatmapLayer.map = mapView
/// ```
///
/// ## Topics
///
/// ### Configuration
/// - ``weightedData``
/// - ``radius``
/// - ``gradient``
/// - ``minimumZoomIntensity``
/// - ``maximumZoomIntensity``
public class GMUHeatmapTileLayer: GMSSyncTileLayer {

    /// Positions and individual intensities of the data which will be smoothed for display on the
    /// tiles.
    public var weightedData: [GMUWeightedLatLng]?
    
    /// Radius of smoothing.
    /// Larger values smooth the data out over a larger area, but also have a greater cost for generating
    /// tiles.
    /// It is not recommended to set this to a value greater than 50.
    public var radius: Int = 20
    
    /// The gradient used to map smoothed intensities to colors in the tiles.
    public var gradient: GMUGradient?
    
    /// The minimum zoom intensity used for normalizing intensities, defaults to 5
    public var minimumZoomIntensity: Int = 5
    
    /// The maximum zoom intensity used for normalizing intensities, defaults to 10
    public var maximumZoomIntensity: Int = 10
    private var dirty: Bool = true
    var tileCreationData: GMUHeatmapTileCreationData?
    /// Static constants for tile size and maximum zoom level.
    private let gmuTileSize: Int = 512
    private let maxZoom: Int = 22

    /// Creates a new heatmap tile layer with default gradient and settings.
    public override init() {
        let gradientColors: [UIColor] = [
            UIColor(red: 102.0 / 255.0, green: 225.0 / 255.0, blue: 0, alpha: 1),
            UIColor(red: 1.0, green: 0, blue: 0, alpha: 1)
        ]
        
        do {
            gradient = try GMUGradient(colors: gradientColors, startPoints: [0.2, 1.0], colorMapSize: 1000)
        } catch {
            debugPrint("Failed to initialize GMUGradient instance with `\(error.localizedDescription)")
        }
        super.init()
        self.opacity = 0.7
        self.tileSize = gmuTileSize
    }

    /// Sets the radius for smoothing.
    ///
    /// - Parameter value: The radius value to be set.
    func setRadius(_ value: Int) {
        self.radius = value
        dirty = true
    }

    /// Sets the gradient used for the heatmap.
    ///
    /// - Parameter gradient: The new gradient to be applied.
    func setGradient(_ gradient: GMUGradient) {
        self.gradient = gradient
        dirty = true
    }

    /// Sets the minimum zoom intensity for normalizing intensities.
    ///
    /// - Parameter minimumZoomIntensity: The minimum zoom intensity value.
    func setMinimumZoomIntensity(_ minimumZoomIntensity: Int) {
        self.minimumZoomIntensity = minimumZoomIntensity
        dirty = true
    }

    /// Sets the maximum zoom intensity for normalizing intensities.
    ///
    /// - Parameter maximumZoomIntensity: The maximum zoom intensity value.
    func setMaximumZoomIntensity(_ maximumZoomIntensity: Int) {
        self.maximumZoomIntensity = maximumZoomIntensity
        dirty = true
    }

    /// Sets the weighted data used for heatmap generation.
    ///
    /// - Parameter weightedData: The array of `GMUWeightedLatLng` data points.
    func setWeightedData(_ weightedData: [GMUWeightedLatLng]) {
        self.weightedData = weightedData
        dirty = true
    }

    /// Sets the map and ensures the layer is updated if there are pending changes.
    ///
    /// - Parameter map: The map object to set.
    func setMap(_ map: GMSMapView) {
        if dirty {
            prepare()
            dirty = false
        }
        super.map = map
    }

    /// Prepares the heatmap tile creation data by initializing and setting necessary properties.
    ///
    func prepare() {

        /// Set the bounds in the data.
        let bounds: GQTBounds = calculateBounds()
        /// Calculate bounds and initialize the QuadTree with those bounds.
        let quadTree = GQTPointQuadTree(bounds: bounds)

        /// Add all weighted data points to the QuadTree.
        if let weightedData = self.weightedData {
            for dataPoint in weightedData {
                _ = quadTree.add(item: dataPoint)
            }
        }

        guard let gradient else { 
            debugPrint("Gradient is nil")
            return
        }
        let data = GMUHeatmapTileCreationData(bounds: bounds, radius: radius, colorMap: gradient.generateColorMap(), maxIntensities: calculateIntensities(), kernel: generateKernel())

        // Synchronize access to ensure thread-safety.
        objc_sync_enter(self)
        tileCreationData = data
        objc_sync_exit(self)
    }

    /// Calculates the bounding box for the weighted data points.
    /// - Returns: The bounds that encompass all the data points.
    func calculateBounds() -> GQTBounds {
        var result = GQTBounds(minX: 0, minY: 0, maxX: 0, maxY: 0)

        // If there is no weighted data, return the default bounds.
        guard let weightedData = weightedData, !weightedData.isEmpty else {
            return result
        }

        // Initialize bounds with the first data point.
        var point: GQTPoint = weightedData[0].point()
        result.minX = point.x
        result.maxX = point.x
        result.minY = point.y
        result.maxY = point.y

        // Iterate through the remaining points and adjust the bounds.
        for i in 1..<weightedData.count {
            point = weightedData[i].point()
            result.minX = min(result.minX, point.x)
            result.maxX = max(result.maxX, point.x)
            result.minY = min(result.minY, point.y)
            result.maxY = max(result.maxY, point.y)
        }

        return result
    }

    /// Generates a kernel for smoothing based on the radius.
    ///
    /// - Returns: An array of numbers representing the kernel values.
    func generateKernel() -> [Float] {
        let sd = Float(radius) / 3.0
        var values = [Float](repeating: 0, count: radius * 2 + 1)

        // Generate the kernel values using a Gaussian function.
        for i in -radius...radius {
            let index = i + radius
            values[index] = expf(-Float(i * i) / (2 * sd * sd))
        }

        return values
    }

    /// Calculates the maximum intensities for each zoom level.
    /// - Returns: An array of numbers representing the maximum intensities for each zoom level.
    func calculateIntensities() -> [Float] {
        // Define the maximum zoom level constant.
        let maxZoom = maxZoom

        // Create an array to hold intensities with placeholder values.
        var intensities = [Float](repeating: 0, count: maxZoom)

        // Populate the array with placeholder values up to the minimum zoom intensity.
        for i in 0..<minimumZoomIntensity {
            intensities[i] = 0
        }

        // Calculate and set the max values for zoom levels between the minimum and maximum intensities.
        for i in minimumZoomIntensity...maximumZoomIntensity {
            if let maxValueForZoom = maxValueForZoom(i) {
                intensities[i] = maxValueForZoom
            }
        }

        // Fill in the lower zoom levels with the minimum zoom intensity value.
        for i in 0..<minimumZoomIntensity {
            intensities[i] = intensities[minimumZoomIntensity]
        }

        // Fill in the higher zoom levels with the maximum zoom intensity value.
        for i in (maximumZoomIntensity + 1)..<maxZoom {
            intensities[i] = intensities[maximumZoomIntensity]
        }

        return intensities
    }

    /// Calculates the maximum value for a given zoom level.
    ///
    /// - Parameter zoom: The zoom level for which to calculate the maximum intensity.
    /// - Returns: The maximum intensity value for the given zoom level.
    func maxValueForZoom(_ zoom: Int) -> Float? {
        /// Magical factor to adjust the bucket size for better accuracy in practice.
        let magicalFactor: Double = 0.5

        /// Calculate the bucket size for the given zoom level.
        let bucketSize = Double(radius) / 128.0 / pow(2.0, Double(zoom)) * magicalFactor

        /// Dictionary to store intensity values bucketed by x and y coordinates.
        var lookupX = [Int: [Int: Float]]()

        /// Variable to track the maximum intensity value.
        var max: Float = 0.0

        guard let weightedData else { return nil }
        /// Iterate over each data point to accumulate intensity values into buckets.
        for dataPoint in weightedData {
            let point: GQTPoint = dataPoint.point()

            /// Calculate the x and y bucket positions for the point.
            let xBucket = Int((point.x + 1.0) / bucketSize)
            let yBucket = Int((point.y + 1.0) / bucketSize)

            /// Get or initialize the y-bucket lookup dictionary.
            var lookupY = lookupX[xBucket]
            if var lookupY {
                lookupY = [:]
                lookupX[xBucket] = lookupY
            }

            /// Accumulate the intensity value for the given bucket.
            let currentValue = lookupY?[yBucket] ?? 0
            let newValue = currentValue + dataPoint.intensity

            /// Update the maximum intensity if the new value is greater.
            if newValue > max {
                max = newValue
            }

            /// Store the new accumulated value in the y-bucket.
            lookupY?[yBucket] = newValue
            lookupX[xBucket] = lookupY
        }

        /// Return the maximum intensity found for the zoom level.
        return max
    }

    /// Generates a tile image for the specified x, y, and zoom level using heatmap data.
    ///
    /// - Parameters:
    ///   - x: The x coordinate of the tile.
    ///   - y: The y coordinate of the tile.
    ///   - zoom: The zoom level of the tile.
    /// - Returns: A UIImage representing the heatmap tile, or `nil` if no data is available.
    func tileFor(x: Double, y: Double, zoom: Double) -> UIImage? {
        guard let tileCreationData else {
            debugPrint("Tile Creation Data is nil.")
            return nil
        }
        var data: GMUHeatmapTileCreationData
        // Synchronize access to the tile creation data
        objc_sync_enter(self)
        data = tileCreationData
        objc_sync_exit(self)

        // Calculate tile bounds and padding
        let tileWidth: Double = 2.0 / pow(2.0, zoom)
        let padding: Double = tileWidth * Double(data.radius) / Double(gmuTileSize)
        let bucketWidth: Double = tileWidth / Double(gmuTileSize)
        let minX: Double = -1.0 + Double(x) * tileWidth - padding
        let maxX: Double = -1.0 + Double(x + 1) * tileWidth + padding
        let maxY: Double = 1.0 - Double(y) * tileWidth + padding
        let minY: Double = 1.0 - Double(y + 1) * tileWidth - padding
        
        var wrappedPointsOffset: Double = 0.0
        var wrappedPoints: [GMUWeightedLatLng] = []

        // Handle wrapping of points around the map boundaries
        if minX < -1.0 {
            let wrappedBounds = GQTBounds(minX: minX + 2.0, minY: minY, maxX: 1.0, maxY: maxY)
            if let wrappedPointsValue = data.quadTree?.search(withBounds: wrappedBounds) as? [GMUWeightedLatLng] {
                wrappedPoints = wrappedPointsValue
            }
            wrappedPointsOffset = -2.0
        } else if maxX > 1.0 {
            let wrappedBounds = GQTBounds(minX: -1.0, minY: minY, maxX: maxX - 2.0, maxY: maxY)
            if let wrappedPointsValue = data.quadTree?.search(withBounds: wrappedBounds) as? [GMUWeightedLatLng] {
                wrappedPoints = wrappedPointsValue
            }
            wrappedPointsOffset = -2.0
        }

        // Search for data points within the current tile bounds
        let bounds = GQTBounds(minX: minX, minY: minY, maxX: maxX, maxY: maxY)
        guard let points = data.quadTree?.search(withBounds: bounds) as? [GMUWeightedLatLng] else {
            debugPrint("No valid data points for the given bounds.")
            return nil
        }

        // Return empty tile if there is no data
        if points.isEmpty && wrappedPoints.isEmpty {
            return kGMSTileLayerNoTile
        }

        // Quantize points to the tile grid
        let paddedTileSize = gmuTileSize + 2 * Int(data.radius)
        var intensity = [Float](repeating: 0.0, count: paddedTileSize * paddedTileSize)

        for item in points {
            let point: GQTPoint = item.point()
            var x = Int((point.x - minX) / bucketWidth)
            var y = Int((maxY - point.y) / bucketWidth)
            
            x = min(max(x, 0), paddedTileSize - 1)
            y = min(max(y, 0), paddedTileSize - 1)
            intensity[y * paddedTileSize + x] += item.intensity
        }
        
        for item in wrappedPoints {
            let point: GQTPoint = item.point()
            var x = Int((point.x + wrappedPointsOffset - minX) / bucketWidth)
            var y = Int((maxY - point.y) / bucketWidth)

            x = min(max(x, 0), paddedTileSize - 1)
            y = min(max(y, 0), paddedTileSize - 1)
            intensity[y * paddedTileSize + x] += item.intensity
        }
        
        // Perform horizontal convolution
        var intermediate = [Float](repeating: 0.0, count: paddedTileSize * paddedTileSize)
        let lowerLimit = Int(data.radius)
        let upperLimit = paddedTileSize - lowerLimit - 1

        for y in 0..<paddedTileSize {
            for x in 0..<paddedTileSize {
                let value: Float = intensity[y * paddedTileSize + x]
                if value != 0 {
                    let start = max(lowerLimit, x - lowerLimit)
                    let end = min(upperLimit, x + lowerLimit)
                    for x2 in start...end {
                        let scaledKernel = value * Float(data.kernel[x2 - x + lowerLimit])
                        intermediate[y * paddedTileSize + x2] += scaledKernel
                    }
                }
            }
        }
        
        // Perform vertical convolution to get final intensity
        var finalIntensity = [Float](repeating: 0.0, count: gmuTileSize * gmuTileSize)
        for x in lowerLimit...upperLimit {
            for y in 0..<paddedTileSize {
                let value = intermediate[y * paddedTileSize + x]
                if value != 0 {
                    let start = max(lowerLimit, y - lowerLimit)
                    let end = min(upperLimit, y + lowerLimit)
                    for y2 in start...end {
                        let scaledKernel = value * Float(data.kernel[y2 - y + lowerLimit])
                        finalIntensity[(y2 - lowerLimit) * gmuTileSize + x - lowerLimit] += scaledKernel
                    }
                }
            }
        }
        
        // Generate image from final intensity
        let rawpixels = UnsafeMutablePointer<UInt32>.allocate(capacity: gmuTileSize * gmuTileSize)
        let maxIntensity = Float(data.maxIntensities[Int(zoom)])
        let scalingFactor = Float(data.colorMap.count - 1) / maxIntensity
        
        for y in 0..<gmuTileSize {
            for x in 0..<gmuTileSize {
                let colorMapIndex = min(Int(finalIntensity[y * gmuTileSize + x] * scalingFactor), data.colorMap.count - 1)
                let color = data.colorMap[colorMapIndex]

                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                color.getRed(&r, green: &g, blue: &b, alpha: &a)
                let rgba = (UInt32(a * 255) << 24) | (UInt32(b * 255) << 16) | (UInt32(g * 255) << 8) | UInt32(r * 255)
                rawpixels[y * gmuTileSize + x] = rgba
            }
        }

        // Create image from raw pixels
        guard let provider = CGDataProvider(dataInfo: nil, data: rawpixels, size: gmuTileSize * gmuTileSize * 4, releaseData: { _, data, _ in free(UnsafeMutableRawPointer(mutating: data)) }) else {
            debugPrint("provider is nil.")
            return nil
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let cgImage = CGImage(width: gmuTileSize, height: gmuTileSize, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: gmuTileSize * 4, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue), provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else {
            debugPrint("cgImage is nil.")
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

}
