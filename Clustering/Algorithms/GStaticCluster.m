//
//  GStaticCluster.m
//  Parkingmobility
//
//  Created by Colin Edwards on 1/18/14.
//  Copyright (c) 2014 Colin Edwards. All rights reserved.
//

#import "GStaticCluster.h"

@implementation GStaticCluster

- (id)initWithLocation:(GQTPoint)location {
    if (self = [super init]) {
        point = location;
    }
    return self;
}

- (void)add:(id <GQTPointQuadTreeItem>)item {
    
}

- (GQTPoint)point {
    return point;
}

- (NSArray*)getItems {
    return nil;
}

- (int)getSize {
    return 1;
}

- (CLLocationCoordinate2D)position {
    return CLLocationCoordinate2DMake(point.y, point.x);
}

@end
