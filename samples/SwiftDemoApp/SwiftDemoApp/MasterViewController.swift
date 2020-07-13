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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Demos"
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Sample.allCases.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
    UITableViewCell {
      let cellIdentifier = "Cell"
      let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ??
        UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
      
      cell.accessoryType = .disclosureIndicator
      cell.textLabel?.text = Sample.allCases[indexPath.item].title
      cell.detailTextLabel?.text = Sample.allCases[indexPath.item].description
      return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let navigationController = navigationController {
      let viewController = Sample.allCases[indexPath.item].controller.init()
      navigationController.pushViewController(viewController, animated: true)
    }
  }
}
