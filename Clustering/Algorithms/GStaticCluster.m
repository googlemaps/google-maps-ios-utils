#import "GStaticCluster.h"

@implementation GStaticCluster {
    GQTPoint _point;
    NSMutableSet *_items;
}

- (id)initWithLocation:(GQTPoint)location {
    if (self = [super init]) {
        _point = location;
        _items = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)add:(GQuadItem*)item {
    [_items addObject:item];
}

- (void)remove:(GQuadItem*)item {
    [_items removeObject:item];
}

- (GQTPoint)point {
    return _point;
}

- (NSSet*)items {
    return _items;
}

- (CLLocationCoordinate2D)position {
    return CLLocationCoordinate2DMake(_point.y, _point.x);
}

@end
