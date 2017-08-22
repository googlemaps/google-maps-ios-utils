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

#import "Samples.h"

#import "BasicViewController.h"
#import "CustomMarkerViewController.h"
#import "GeoJSONViewController.h"
#import "HeatmapViewController.h"
#import "KMLViewController.h"

@implementation Samples

+ (NSArray *)loadDemos {
  NSArray *demos = @[
    [self newDemo:[BasicViewController class] withTitle:@"Basic" andDescription:nil],
    [self newDemo:[CustomMarkerViewController class] withTitle:@"Custom Markers"
                                                andDescription:nil],
    [self newDemo:[KMLViewController class] withTitle:@"KML Import" andDescription:nil],
    [self newDemo:[GeoJSONViewController class] withTitle:@"GeoJSON Import" andDescription:nil],
    [self newDemo:[HeatmapViewController class] withTitle:@"Heatmap" andDescription:nil]
  ];
  return demos;
}

+ (NSDictionary *)newDemo:(Class) class
                withTitle:(NSString *)title
           andDescription:(NSString *)description {
  return @{ @"controller" : class, @"title" : title, @"description" : description ?: @"" };
}

@end
