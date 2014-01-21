//
//  GStaticCluster.h
//  Parkingmobility
//
//  Created by Colin Edwards on 1/18/14.
//  Copyright (c) 2014 Colin Edwards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GQTPointQuadTreeItem.h"

@interface GStaticCluster : NSObject <GQTPointQuadTreeItem> {
    GQTPoint point;
}

- (id)initWithLocation:(GQTPoint)location;

- (NSArray*)getItems;

- (int)getSize;

- (void)add:(id <GQTPointQuadTreeItem>)item;

- (CLLocationCoordinate2D)position;

@end
