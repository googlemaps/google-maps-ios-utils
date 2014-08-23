#import <Foundation/Foundation.h>
#import "GClusterAlgorithm.h"
#import "GQTPointQuadTree.h"

@interface NonHierarchicalDistanceBasedAlgorithm : NSObject<GClusterAlgorithm> 

- (id)initWithMaxDistanceAtZoom:(NSInteger)maxDistanceAtZoom;

@end
