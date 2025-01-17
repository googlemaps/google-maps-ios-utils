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


/// TO-DO: Rename the class to `GMUWrappingDictionaryKey` once the linking is done and remove the objective c class.
/// Wraps an object that does not implement Hashable to be used as Dictionary keys.
///
import Foundation

final class GMUWrappingDictionaryKey1: NSObject, NSCopying {

    // MARK: - Properties
    /// The wrapped object that doesn't implement Hashable.
    private let currentObject: Any

    // MARK: - Initializers
    /// Initializer that takes an object to be wrapped.
    init(object: Any) {
        self.currentObject = object
    }

    // MARK: - Override's
    /// Forward the hash value to the underlying object.
    override var hash: Int {
        // Use the `hash` property of the wrapped object to provide the hash value.
        return (currentObject as AnyObject).hash
    }

    /// Forward the equality check to the underlying object.
    override func isEqual(_ object: Any?) -> Bool {
        // If both instances are the same, return true.
        if self === object as AnyObject {
            return true
        }

        // Check if the object is of the same type, and then compare the underlying objects.
        guard let other = object as? GMUWrappingDictionaryKey1 else {
            return false
        }
        return (self.currentObject as AnyObject).isEqual(other.currentObject)
    }

    // MARK: - `copy`
    /// Method to create a copy of the instance.
    func copy(with zone: NSZone? = nil) -> Any {
        // Create a new instance and copy the wrapped object.
        let newKey = GMUWrappingDictionaryKey1(object: currentObject)
        return newKey
    }
}
