#import "NonHierarchicalDistanceBasedAlgorithm.h"
#import "GQTBounds.h"
#import "GQTPoint.h"
#import "GStaticCluster.h"
#import "GQuadItem.h"

@implementation NonHierarchicalDistanceBasedAlgorithm

- (id)initWithMaxDistanceAtZoom:(NSInteger)aMaxDistanceAtZoom {
    if (self = [super init]) {
        items = [[NSMutableArray alloc] init];
        quadTree = [[GQTPointQuadTree alloc] initWithBounds:(GQTBounds){-180,-90,180,90}];
        maxDistanceAtZoom = aMaxDistanceAtZoom;
    }
    return self;
}

- (id)init {
    return [self initWithMaxDistanceAtZoom:10000];
}

- (void)addItem:(id <GClusterItem>) item {
    GQuadItem *quadItem = [[GQuadItem alloc] initWithItem:item];
    [items addObject:quadItem];
    [quadTree add:quadItem];
}

- (void)removeItems
{
  [items removeAllObjects];
  [quadTree clear];
}

- (NSSet*)getClusters:(float)zoom {
    int discreteZoom = (int) zoom;
    
    double zoomSpecificSpan = maxDistanceAtZoom / pow(2, discreteZoom) / 256;
    
    NSMutableSet *visitedCandidates = [[NSMutableSet alloc] init];
    NSMutableSet *results = [[NSMutableSet alloc] init];
    NSMutableDictionary *distanceToCluster = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *itemToCluster = [[NSMutableDictionary alloc] init];
    
    for (GQuadItem* candidate in items) {
        if ([visitedCandidates containsObject:candidate]) {
            // Candidate is already part of another cluster.
            continue;
        }
        
        GQTBounds bounds = [self createBoundsFromSpan:candidate.point span:zoomSpecificSpan];
        NSArray *clusterItems  = [quadTree searchWithBounds:bounds];
        if ([clusterItems count] == 1) {
            // Only the current marker is in range. Just add the single item to the results.
            [results addObject:candidate];
            [visitedCandidates addObject:candidate];
            [distanceToCluster setObject:[NSNumber numberWithDouble:0] forKey:candidate];
            continue;
        }
        
        GStaticCluster *cluster = [[GStaticCluster alloc] initWithLocation:candidate.point];
        [results addObject:cluster];
        
        for (GQuadItem* clusterItem in clusterItems) {
            NSNumber *existingDistance = [distanceToCluster objectForKey:clusterItem];
            double distance = [self distanceSquared:clusterItem.point :candidate.point];
            if (existingDistance != nil) {
                // Item already belongs to another cluster. Check if it's closer to this cluster.
                if ([existingDistance doubleValue] < distance) {
                    continue;
                }
                
                // Move item to the closer cluster.
                GStaticCluster *oldCluster = [itemToCluster objectForKey:clusterItem];
                [oldCluster remove:clusterItem];
            }
            [distanceToCluster setObject:[NSNumber numberWithDouble:distance] forKey:clusterItem];
            [cluster add:clusterItem];
            [itemToCluster setObject:cluster forKey:clusterItem];
        }
        [visitedCandidates addObjectsFromArray:clusterItems];
    }
    
    return results;
}

- (double)distanceSquared:(GQTPoint) a :(GQTPoint) b {
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}

- (GQTBounds) createBoundsFromSpan:(GQTPoint) point span:(double) span {
    double halfSpan = span / 2;
    GQTBounds bounds;
    bounds.minX = point.x - halfSpan;
    bounds.maxX = point.x + halfSpan;
    bounds.minY = point.y - halfSpan;
    bounds.maxY = point.y + halfSpan;

    return bounds;
}

@end
