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

final class GMUWrappingDictionaryKeyTest: XCTestCase {
    
    func testEqualityAndHash() {
        let object = "Test object"
        let key1 = GMUWrappingDictionaryKey1(object: object)
        let key2 = GMUWrappingDictionaryKey1(object: object)

        // Testing reference inequality (since they are different instances)
        XCTAssertFalse(key1 === key2)

        // Testing value equality
        XCTAssertEqual(key1, key2)

        // Testing hash equality
        XCTAssertEqual(key1.hash, key2.hash)
    }

    func testUnequalityAndHash() {
        let object1 = "Test object1"
        let key1 = GMUWrappingDictionaryKey1(object: object1)
        let object2 = "Test object2"
        let key2 = GMUWrappingDictionaryKey1(object: object2)

        // Testing reference inequality
        XCTAssertFalse(key1 === key2)

        // Testing value inequality
        XCTAssertNotEqual(key1, key2)

        // Testing hash inequality
        XCTAssertNotEqual(key1.hash, key2.hash)
    }

    func testCopy() {
        let object = "Test object"
        let key1 = GMUWrappingDictionaryKey1(object: object as AnyObject)
        guard let key2 = key1.copy() as? GMUWrappingDictionaryKey1 else {
            XCTFail("Copy failed to return a valid GMUWrappingDictionaryKey")
            return
        }

        // Testing value equality after copying
        XCTAssertEqual(key1, key2)

        // Testing hash equality after copying
        XCTAssertEqual(key1.hash, key2.hash)
    }
}

