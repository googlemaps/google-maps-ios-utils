/* Copyright (c) 2017 Google Inc.
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

import UIKit

class MasterViewController: UITableViewController {
  var samples: [[String: Any]] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = "Demos"
    samples = Samples.loadSamples()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return samples.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
      UITableViewCell {
    let cellIdentifier = "Cell"
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ??
        UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
    cell.accessoryType = .disclosureIndicator
    if let title = samples[indexPath.item]["title"] as? String, let description = samples[indexPath.item]["description"] as? String{
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = description
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let controllerClass = samples[indexPath.item]["controller"] as? UIViewController, let navigationController = navigationController{
        navigationController.pushViewController(controllerClass, animated: true)
    }
  }
}