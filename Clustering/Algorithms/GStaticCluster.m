#import "GStaticCluster.h"

@implementation GStaticCluster

- (id)initWithLocation:(GQTPoint)location {
    if (self = [super init]) {
        point = location;
        items = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)add:(GQuadItem*)item {
    [items addObject:item];
}

- (void)remove:(GQuadItem*)item {
    [items removeObject:item];
}

- (GQTPoint)point {
    return point;
}

- (NSSet*)getItems {
    return items;
}

- (int)count {
    return [items count];
}

- (CLLocationCoordinate2D)position {
    return CLLocationCoordinate2DMake(point.y, point.x);
}

@end
