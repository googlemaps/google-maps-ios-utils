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

/// This class places clusters into range-based buckets of size to avoid having too many distinct cluster icons.
/// For example a small cluster of 1 to 9 items will have a icon with a text label of 1 to 9.
/// Whereas clusters with a size of 100 to 199 items will be placed in the 100+ bucket and have the '100+' icon shown.
/// This caches already generated icons for performance reasons.
///
import UIKit

final class GMUDefaultClusterIconGenerator: GMUClusterIconGenerator {

    // MARK: - Properties
    private let iconCache = NSCache<NSString, UIImage>()
    private var buckets: [Int]
    var backgroundImages: [UIImage]?
    private var backgroundColors: [UIColor]?
    /// Default bucket background colors when no background images are set.
    private var kGMUBucketBackgroundColors: [UIColor] = []
    /// Provides the default bucket background colors when no background images are set.
    private static let bucketBackgroundColors: [UIColor] = {
        return [
            UIColor.fromHex(0x0099cc),
            UIColor.fromHex(0x669900),
            UIColor.fromHex(0xff8800),
            UIColor.fromHex(0xcc0000),
            UIColor.fromHex(0x9933cc),
        ]
    }()

    // MARK: - Init
    /// Initializes the object with default buckets and auto generated background images.
    ///
    init() {
        // Initialize the icon cache and default bucket sizes.
        buckets = [10, 50, 100, 200, 1000]
        backgroundColors = Self.bucketBackgroundColors
    }

    /// Initializes the class with a list of buckets and the corresponding background images.
    /// The backgroundImages array should ideally be big enough to hold the cluster label.
    ///
    /// - Parameters:
    ///   - buckets: An array of bucket sizes,
    ///   - backgroundImages: An array of background images corresponding to the buckets.
    /// - Notes:
    ///    `buckets` should be strictly increasing. For example: [10, 20, 100, 1000].
    ///    `buckets` and `backgroundImages` must have equal non zero lengths.
    convenience init(buckets: [Int], backgroundImages: [UIImage]) throws {
        try self.init(buckets: buckets)

        /// Ensure that the count of buckets matches the count of background images
        guard buckets.count == backgroundImages.count else {
            throw GMUDefaultClusterIconGeneratorError.invalidArgumentException("buckets' size: \(buckets.count) is not equal to backgroundImages' size: \(backgroundImages.count)")
        }

        self.backgroundImages = backgroundImages
    }

    /// Initializes the class with a list of buckets and the corresponding background colors.
    ///
    /// - Parameters:
    ///   - buckets: An array of bucket sizes.
    ///   - backgroundColors: An array of background colors corresponding to the buckets.
    /// - Notes:
    ///    `buckets` should be strictly increasing. For example: [10, 20, 100, 1000].
    ///    `buckets` and `backgroundColors` must have equal non zero lengths.
    convenience init(buckets: [Int], backgroundColors: [UIColor]) throws {
        try self.init(buckets: buckets)

        /// Ensure that the count of buckets matches the count of background colors
        guard buckets.count == backgroundColors.count else {
            throw GMUDefaultClusterIconGeneratorError.invalidArgumentException("buckets' size: \(buckets.count) is not equal to backgroundColors' size: \(backgroundColors.count)")
        }

        self.backgroundColors = backgroundColors
    }

    /// Initializes the default cluster icon generator with specified buckets.
    /// - Parameter buckets: An array of bucket sizes.
    ///
    init(buckets: [Int]) throws {
        // Check that the buckets array is not empty
        guard !buckets.isEmpty else {
            throw GMUDefaultClusterIconGeneratorError.invalidArgumentException("Buckets array is empty")
        }

        // Validate that all bucket sizes are positive
        for i in 0..<buckets.count {
            guard buckets[i] > 0 else {
                throw GMUDefaultClusterIconGeneratorError.invalidArgumentException("Buckets have non-positive values")
            }
        }

        // Ensure the buckets are strictly increasing
        for i in 0..<buckets.count - 1 {
            guard buckets[i] < buckets[i + 1] else {
                throw GMUDefaultClusterIconGeneratorError.invalidArgumentException("Buckets are not strictly increasing")
            }
        }

        self.buckets = buckets
    }

    // MARK: - `GMUClusterIconGenerator`
    /// Generates an icon for the specified cluster size.
    ///
    /// - Parameter size: The size for which the icon is generated.
    /// - Returns: A UIImage representing the icon for the specified size.
    func iconForSize(_ size: Int) -> UIImage? {
        /// Calls a method to get the appropriate bucket index
        let bucketIndex = bucketIndex(for: size)
        let text: String

        /// If size is smaller to first bucket size, use the size as is otherwise round it down to the
        /// nearest bucket to limit the number of cluster icons we need to generate.
        if size < buckets[0] {
            text = "\(size)"
        } else {
            text = "\(buckets[bucketIndex])+"
        }

        /// Check if background images are available
        if let backgroundImages {
            let image = backgroundImages[bucketIndex]
            /// Calls a method to create the icon with text and base image
            if let image = iconWithImage(for: text, with: image) {
                return image
            } else {
                return nil
            }
        }
        /// Calls a method to create the icon with text and bucket index
        return iconWithIndex(for: text, with: bucketIndex)
    }

    // MARK: - Private Methods
    /// Finds the smallest bucket which is greater than the specified size.
    /// If none exists, returns the last bucket index (i.e., `buckets.count - 1`).
    ///
    /// - Parameter size: The size for which the bucket index is to be found.
    /// - Returns: The index of the appropriate bucket.
    func bucketIndex(for size: Int) -> Int {
        var index: Int = 0
        while index + 1 < buckets.count && buckets[index + 1] <= size {
            index += 1
        }
        return index
    }

    /// Creates an icon with the specified text overlaying the provided base image.
    /// If the icon has already been generated, it retrieves it from the cache.
    ///
    /// - Parameters:
    ///   - text: The text to overlay on the image.
    ///   - image: The base image to use for the icon.
    /// - Returns: A UIImage containing the icon with the overlayed text.
    func iconWithImage(for text: String, with baseImage: UIImage?) -> UIImage? {
        guard let baseImage else {
            return nil
        }
        /// Check if the icon is already cached
        if let cachedIcon = iconCache.object(forKey: text as NSString) {
            return cachedIcon
        }

        let font: UIFont = UIFont.boldSystemFont(ofSize: 12)
        let size: CGSize = baseImage.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)

        /// Draw the base image
        baseImage.draw(in: CGRectMake(0, 0, size.width, size.height))
        let rect: CGRect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height)

        /// Configure text attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: AnyObject] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white
        ]

        /// Calculate text size and position
        let textSize: CGSize = text.size(withAttributes: attributes)
        let textRect: CGRect = CGRectInset(rect, (rect.size.width - textSize.width) / 2, (rect.size.height - textSize.height) / 2)

        text.draw(in: CGRectIntegral(textRect), withAttributes: attributes)

        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        UIGraphicsEndImageContext()

        /// Cache the newly created icon
        iconCache.setObject(newImage, forKey: text as NSString)

        return newImage
    }

    /// Creates an icon with the specified text overlaying a circular background colored
    /// according to the given bucket index. 
    /// If the icon has already been generated, it retrieves it from the cache.
    ///
    /// - Parameters:
    ///   - text: The text to overlay on the icon.
    ///   - bucketIndex: The index of the bucket used to determine the background color.
    /// - Returns: A UIImage containing the icon with the overlayed text.
    func iconWithIndex(for text: String, with bucketIndex: Int) -> UIImage {
        // Check if the icon is already cached
        if let cachedIcon = iconCache.object(forKey: text as NSString) {
            return cachedIcon
        }

        let font = UIFont.boldSystemFont(ofSize: 14)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: AnyObject] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white
        ]
        
        // Calculate the size of the text
        let textSize: CGSize = text.size(withAttributes: attributes)

        /// Create an image context with a square shape to contain the text (with more padding for larger buckets).
        let rectDimension: CGFloat = max(20, max(textSize.width, textSize.height)) + CGFloat(3 * bucketIndex + 6)

        let rect: CGRect = CGRectMake(0, 0, rectDimension, rectDimension)
        UIGraphicsBeginImageContext(rect.size)

        /// Draw the background circle
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext(), let backgroundColors else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        context.saveGState()

        let adjustedBucketIndex: Int = min(bucketIndex, backgroundColors.count - 1)
        let backColor: UIColor = backgroundColors[adjustedBucketIndex]
        context.setFillColor(backColor.cgColor)
        context.fillEllipse(in: rect)
        context.restoreGState()

        /// Draw the text
        UIColor.white.set()
        let textRect: CGRect = CGRectInset(rect, (rect.size.width - textSize.width) / 2,
                                   (rect.size.height - textSize.height) / 2)
        text.draw(in: CGRectIntegral(textRect), withAttributes: attributes)

        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        UIGraphicsEndImageContext()

        /// Cache the newly created icon
        iconCache.setObject(newImage, forKey: text as NSString)

        return newImage
    }

}
