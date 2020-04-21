/* Copyright (c) 2018 Google Inc.
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

#import "GMUPair.h"
#import "GMUStyleMap.h"

@implementation GMUStyleMap

@synthesize styleMapId = _id;
@synthesize pairs = _pairs;

- (instancetype)initWithId:(NSString *)styleMapId
                     pairs:(NSArray<GMUPair *> *)pairs {
    if (self = [super init]) {
        _id = styleMapId;
        _pairs = pairs;
    }
    return self;
}

@end
