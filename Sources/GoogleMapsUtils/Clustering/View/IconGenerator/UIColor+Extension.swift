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

extension UIColor {
    /// Converts a hexadecimal color value to a UIColor instance.
    /// - Parameter hex: The hexadecimal value of the color (e.g., 0xFF5733).
    /// - Returns: A UIColor representing the color.
    static func fromHex(_ hex: Int) -> UIColor {
        let red = CGFloat((hex & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00ff00) >> 8) / 255.0
        let blue = CGFloat((hex & 0x0000ff) >> 0) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
