/* Copyright (c) 2016 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "Clustering/Algo/GMUWrappingDictionaryKey.h"

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

@interface GMUWrappingDictionaryKeyTest : XCTestCase
@end

@implementation GMUWrappingDictionaryKeyTest

- (void)testEqualityAndHash {
  NSString *object = @"Test object";
  GMUWrappingDictionaryKey *key1 = [[GMUWrappingDictionaryKey alloc] initWithObject:object];
  GMUWrappingDictionaryKey *key2 = [[GMUWrappingDictionaryKey alloc] initWithObject:object];

  XCTAssertNotEqual(key1, key2);
  XCTAssertEqualObjects(key1, key2);
  XCTAssertEqual(key1.hash, key2.hash);
}

- (void)testUnequalityAndHash {
  NSString *object1 = @"Test object1";
  GMUWrappingDictionaryKey *key1 = [[GMUWrappingDictionaryKey alloc] initWithObject:object1];
  NSString *object2 = @"Test object2";
  GMUWrappingDictionaryKey *key2 = [[GMUWrappingDictionaryKey alloc] initWithObject:object2];

  XCTAssertNotEqual(key1, key2);
  XCTAssertNotEqualObjects(key1, key2);
  XCTAssertNotEqual(key1.hash, key2.hash);
}

- (void)testCopy {
  NSString *object = @"Test object";
  GMUWrappingDictionaryKey *key1 = [[GMUWrappingDictionaryKey alloc] initWithObject:object];
  GMUWrappingDictionaryKey *key2 = [key1 copy];

  XCTAssertEqualObjects(key1, key2);
  XCTAssertEqual(key1.hash, key2.hash);
}

@end

