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

import XCTest

@testable import GoogleMapsUtils

final class GMUDefaultClusterIconGeneratorTest: XCTestCase {

    var buckets: [Int]!
    var backgroundImages: [UIImage]!
    var generator: GMUDefaultClusterIconGenerator!
    var sampleImage: UIImage!

    override func setUp() {
        super.setUp()
        buckets = [10, 20, 50, 100, 1000]
        backgroundImages = [
            createTestImage(size: CGSize(width: 5, height: 5), color: .red),
            createTestImage(size: CGSize(width: 10, height: 10), color: .green),
            createTestImage(size: CGSize(width: 50, height: 50), color: .blue),
            createTestImage(size: CGSize(width: 100, height: 100), color: .yellow),
            createTestImage(size: CGSize(width: 150, height: 150), color: .orange)
        ]
        generator = GMUDefaultClusterIconGenerator()
        sampleImage = createTestImage(size: CGSize(width: 100, height: 100), color: .red)
    }

    override func tearDown() {
        super.tearDown()
        buckets = nil
        backgroundImages = nil
        generator = nil
        sampleImage = nil
    }

    func testIconWithImageReturnsNilWhenBaseImageIsNil() {
        let result = generator.iconWithImage(for: "Test", with: nil)
        XCTAssertNil(result, "Expected result to be nil when base image is nil.")
    }

    func testIconWithImageReturnsNewImageWhenBaseImageIsProvided() {
        let result = generator.iconWithImage(for: "Test", with: sampleImage)
        XCTAssertNotNil(result, "Expected a valid image to be returned when base image is provided.")
    }

    func testIconForSizeSmallerThanFirstBucket() {
        let result = generator.iconForSize(5)
        XCTAssertNotNil(result, "Expected a valid image to be returned for size smaller than the first bucket.")
        XCTAssertEqual(generator.iconWithImage(for: "5", with: backgroundImages[0]), result)
    }

    func testIconForSizeMatchingBucketValue() {
        let result = generator.iconForSize(11)
        XCTAssertNotNil(result, "Expected a valid image to be returned for size matching the bucket value.")
        XCTAssertEqual(generator.iconWithImage(for: "10+", with: backgroundImages[1]), result)
    }

    func testIconForSizeExceedingBucketValue() {
        let result = generator.iconForSize(51)
        XCTAssertNotNil(result, "Expected a valid image to be returned for size exceeding a bucket value.")
        XCTAssertEqual(generator.iconWithImage(for: "50+", with: backgroundImages[2]), result)
    }

    func testIconForSizeWithBackgroundImages() {
        generator.backgroundImages = backgroundImages
        let result = generator.iconForSize(100)
        XCTAssertNotNil(result, "Expected a valid image to be returned when no background images are provided.")
        XCTAssertEqual(generator.iconWithIndex(for: "100+", with: 3), result)
    }

    func testIconForSizeWithNoBackgroundImages() {
        generator.backgroundImages = nil
        let result = generator.iconForSize(100)
        XCTAssertNotNil(result, "Expected a valid image to be returned when no background images are provided.")
        XCTAssertEqual(generator.iconWithIndex(for: "100+", with: 3), result)
    }

    func testIconForSizeSmallerThanFirstBucketNoBackgroundImages() {
        generator.backgroundImages = nil
        let result = generator.iconForSize(5)
        XCTAssertNotNil(result, "Expected a valid image to be returned for size smaller than the first bucket without background images.")
        XCTAssertEqual(generator.iconWithIndex(for: "5", with: 0), result)
    }

    func testIconForTextWithNotNilUIImage() {
        XCTAssertNotNil(GMUDefaultClusterIconGenerator().iconWithIndex(for: "1", with: 0))
    }

    func testIconForTextWithBaseImageNilAndNilUIImage() {
        XCTAssertNil(GMUDefaultClusterIconGenerator().iconWithImage(for: "1000+", with: nil))
    }

    func testInitThrowsWhenBucketsAndBackgroundImagesAreOfDifferentSize() {
        let buckets = [10, 20, 50, 100, 1000]
        let backgroundImages = [UIImage(), UIImage(), UIImage()]

        XCTAssertThrowsError(try GMUDefaultClusterIconGenerator(buckets: buckets, backgroundImages: backgroundImages)) { error in
            guard let iconGeneratorError = error as? GMUDefaultClusterIconGeneratorError else {
                XCTFail("Expected InitializationError")
                return
            }
            XCTAssertEqual(iconGeneratorError.localizedDescription, "buckets' size: 5 is not equal to backgroundImages' size: 3")
        }
    }

    func testInitThrowsWhenBucketsAreEmpty() {
        let buckets: [Int] = []
        let backgroundImages: [UIImage] = []

        XCTAssertThrowsError(try  GMUDefaultClusterIconGenerator(buckets: buckets, backgroundImages: backgroundImages)) { error in
            guard let iconGeneratorError = error as? GMUDefaultClusterIconGeneratorError else {
                XCTFail("Expected InitializationError but got \(error)")
                return
            }
            XCTAssertEqual(iconGeneratorError.localizedDescription, "Buckets array is empty")
        }
    }
    
    func testInitThrowsWhenBucketsAndBackgroundColorsAreOfDifferentSize() {
        let buckets: [Int] = [10, 20, 50, 100, 1000]
        let backgroundColors = [UIColor(), UIColor(), UIColor()] // 3 colors
        
        XCTAssertThrowsError(try GMUDefaultClusterIconGenerator(buckets: buckets, backgroundColors: backgroundColors)) { error in
            guard let iconGeneratorError = error as? GMUDefaultClusterIconGeneratorError else {
                XCTFail("Expected InitializationError but got \(error)")
                return
            }
            XCTAssertEqual(iconGeneratorError.localizedDescription, "buckets' size: 5 is not equal to backgroundColors' size: 3")
        }
    }

    func testInitThrowsWhenBucketsAndBackgroundColorsAreEmpty() {
        let buckets: [Int] = []
        let backgroundColors: [UIColor] = []
        
        XCTAssertThrowsError(try GMUDefaultClusterIconGenerator(buckets: buckets, backgroundColors: backgroundColors)) { error in
            guard let iconGeneratorError = error as? GMUDefaultClusterIconGeneratorError else {
                XCTFail("Expected InitializationError but got \(error)")
                return
            }
            XCTAssertEqual(iconGeneratorError.localizedDescription, "Buckets array is empty")
        }
    }

    func testInitThrowsWhenBucketsAreNotStrictlyIncreasing() {
        let buckets:[Int] = [10, 10] // Not strictly increasing

        XCTAssertThrowsError(try GMUDefaultClusterIconGenerator(buckets: buckets)) { error in
            guard let iconGeneratorError = error as? GMUDefaultClusterIconGeneratorError else {
                XCTFail("Expected InitializationError but got \(error)")
                return
            }
            XCTAssertEqual(iconGeneratorError.localizedDescription, "Buckets are not strictly increasing")
        }
    }

    func testInitThrowsWhenBucketsHaveNonNegativeValues() {
        let buckets: [Int] = [-10, 10] // Contains a negative value

        XCTAssertThrowsError(try GMUDefaultClusterIconGenerator(buckets: buckets)) { error in
            guard let iconGeneratorError = error as? GMUDefaultClusterIconGeneratorError else {
                XCTFail("Expected InitializationError but got \(error)")
                return
            }
            XCTAssertEqual(iconGeneratorError.localizedDescription, "Buckets have non-positive values")
        }
    }

    // MARK: - Private Methods
    func createTestImage(size: CGSize, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        color.setFill()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
