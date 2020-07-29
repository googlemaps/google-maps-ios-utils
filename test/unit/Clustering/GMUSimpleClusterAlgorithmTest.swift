/* Copyright (c) 2020 Google Inc.
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

import XCTest
@testable import GoogleMapsUtils

class GMUSimpleClusterAlgorithmTest: GMUClusterAlgorithmTest {
  
  private var clustersCount: Int!
  private var zoom: Float!
  
  override func setUp() {
    clustersCount = 10
    zoom = 3
    super.setUp()
  }
  
  override func tearDown() {
    clustersCount = nil
    zoom = nil
    super.tearDown()
  }
  
  func testClustersAtZoomWithDefaultClusterCount() {
    let simpleClusterAlgorithm = GMUSimpleClusterAlgorithm()
    simpleClusterAlgorithm.add(self.simpleClusterItems())
    simpleClusterAlgorithm.add(self.simpleClusterItems())
    simpleClusterAlgorithm.add(self.simpleClusterItems())
    let clusterItems = simpleClusterAlgorithm.clusters(atZoom: zoom)
    XCTAssertEqual(clustersCount, clusterItems.count)
  }
  
  func testClustersAtZoomWithClearingClusterItems() {
    let simpleClusterAlgorithm = GMUSimpleClusterAlgorithm()
    simpleClusterAlgorithm.add(self.simpleClusterItems())
    simpleClusterAlgorithm.clearItems()
    let clusters = simpleClusterAlgorithm.clusters(atZoom: zoom)
    XCTAssertEqual(0, clusters.count)
    XCTAssertNotEqual(clustersCount, clusters.count)
  }
  
}
