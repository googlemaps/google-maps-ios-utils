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

@testable import GoogleMapsUtils

/// A mock subclass of `GMUClusterIconGenerator` used for testing purposes.
///
final class MockClusterIconGenerator: GMUClusterIconGenerator {

    // MARK: - Method
    /// Generates an icon with the given size.
    func iconForSize(_ size: Int) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: size, height: size))
        }
    }
}

