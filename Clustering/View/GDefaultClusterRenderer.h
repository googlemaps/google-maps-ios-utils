//
//  GDefaultClusterRenderer.h
//  Parkingmobility
//
//  Created by Colin Edwards on 1/18/14.
//  Copyright (c) 2014 Colin Edwards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GClusterRenderer.h"

@interface GDefaultClusterRenderer : NSObject <GClusterRenderer> {
    GMSMapView *map;
    NSMutableArray *markerCache;
}

- (id)initWithGoogleMap:(GMSMapView*)googleMap;

@end
