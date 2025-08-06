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

/// A mock subclass of `GMSMapView` used for testing purposes.
final class MockGMSMapView: GMSMapView {

    // MARK: - Properties
    /// A mock camera position to override the default camera.
    var mockCamera: GMSCameraPosition?
    /// A mock camera projection to override the default camera.
    var mockProjection: GMSProjection?

    // MARK: - Overridden Properties
    /// Overrides the `camera` property to return the mock camera if set, otherwise calls the superclass implementation.
    override var camera: GMSCameraPosition {
        get { return mockCamera ?? super.camera }
        set { mockCamera = newValue }
    }

    /// Overrides the `projection` property to return the mock projection.
    override var projection: GMSProjection {
        return mockProjection ?? super.projection
    }

}
