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

#import "MasterViewController.h"

#import "Samples.h"

@interface MasterViewController ()
@end

@implementation MasterViewController {
  NSArray *_demos;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationItem.title = @"Demos";
  _demos = [Samples loadDemos];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _demos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                  reuseIdentifier:cellIdentifier];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
  }

  NSDictionary *demo = [_demos objectAtIndex:indexPath.item];
  cell.textLabel.text = demo[@"title"];
  cell.detailTextLabel.text = demo[@"description"];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *demo = [_demos objectAtIndex:indexPath.item];
  Class controllerClass = demo[@"controller"];
  UIViewController *controller = [[controllerClass alloc] init];
  [self.navigationController pushViewController:controller animated:YES];
}

@end
