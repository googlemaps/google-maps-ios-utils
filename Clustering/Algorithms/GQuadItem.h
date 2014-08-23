#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GQTPointQuadTreeItem.h"
#import "GClusterItem.h"
#import "GCluster.h"

@interface GQuadItem : NSObject <GCluster, GQTPointQuadTreeItem, NSCopying> 

- (id)initWithItem:(id <GClusterItem>)item;

@property(nonatomic, assign, readonly) CLLocationCoordinate2D position;

@end
