#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GQTPointQuadTreeItem.h"
#import "GClusterItem.h"
#import "GClusterAlgorithm.h"
#import "GCluster.h"

@interface GQuadItem : NSObject <GCluster, GQTPointQuadTreeItem, NSCopying> {
    id <GClusterItem> item;
    GQTPoint point;
}

- (id)initWithItem:(id <GClusterItem>)item;

- (CLLocationCoordinate2D)position;

@end
