#import <Foundation/Foundation.h>
#import "GCluster.h"
#import "GQuadItem.h"

@interface GStaticCluster : NSObject <GCluster> {
    GQTPoint point;
    NSMutableSet *items;
}

- (id)initWithLocation:(GQTPoint)location;

- (void)add:(GQuadItem*)item;

- (void)remove:(GQuadItem*)item;

@end
