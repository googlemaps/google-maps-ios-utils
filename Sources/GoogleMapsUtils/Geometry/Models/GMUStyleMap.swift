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

/// Style state mapping.
public struct GMUStyleMap {
    /// Style map ID.
    public private(set) var styleMapId: String

    /// State-style pairs.
    public private(set) var pairs: [GMUPair]

    /// Creates a style map.
    public init(styleMapId: String, pairs: [GMUPair]) {
        self.styleMapId = styleMapId
        self.pairs = pairs
    }
}
