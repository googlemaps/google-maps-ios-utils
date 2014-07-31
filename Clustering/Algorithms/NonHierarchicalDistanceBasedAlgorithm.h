#import <Foundation/Foundation.h>
#import "GClusterAlgorithm.h"
#import "GQTPointQuadTree.h"

@interface NonHierarchicalDistanceBasedAlgorithm : NSObject<GClusterAlgorithm> {
    NSMutableArray *items;
    GQTPointQuadTree *quadTree;
    int maxDistanceAtZoom;
}

- (id)initWithMaxDistanceAtZoom:(NSInteger)maxDistanceAtZoom;

@end
