//
//  GQuadItem.m
//  Parkingmobility
//
//  Created by Colin Edwards on 1/21/14.
//  Copyright (c) 2014 Colin Edwards. All rights reserved.
//

#import "GQuadItem.h"

@implementation GQuadItem 

- (id)initWithItem:(id <GClusterItem>)clusterItem {
    if (self = [super init]) {
        point.y = clusterItem.position.latitude;
        point.x = clusterItem.position.longitude;
        item = clusterItem;
    }
    return self;
}

- (GQTPoint)point {
    return point;
}

- (id)copyWithZone:(NSZone *)zone {
    GQuadItem *newGQuadItem = [[self class] allocWithZone:zone];
    newGQuadItem->point = point;
    newGQuadItem->item = item;
    return newGQuadItem;
}

- (CLLocationCoordinate2D)position {
    return CLLocationCoordinate2DMake(point.y, point.x);
}

@end
