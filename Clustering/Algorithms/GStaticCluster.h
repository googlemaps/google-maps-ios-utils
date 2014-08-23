#import <Foundation/Foundation.h>
#import "GCluster.h"
#import "GQuadItem.h"

@interface GStaticCluster : NSObject <GCluster> 

- (id)initWithLocation:(GQTPoint)location;

- (void)add:(GQuadItem*)item;
- (void)remove:(GQuadItem*)item;

@end
