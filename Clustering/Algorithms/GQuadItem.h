//
//  GQuadItem.h
//  Parkingmobility
//
//  Created by Colin Edwards on 1/21/14.
//  Copyright (c) 2014 Colin Edwards. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GQTPointQuadTreeItem.h"
#import "GClusterItem.h"

@interface GQuadItem : NSObject <GQTPointQuadTreeItem, NSCopying> {
    id <GClusterItem> item;
    GQTPoint point;
}

- (id)initWithItem:(id <GClusterItem>)item;

- (CLLocationCoordinate2D)position;

@end
