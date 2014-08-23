#import "GQuadItem.h"

@implementation GQuadItem{
    id <GClusterItem> _item;
    GQTPoint _point;
}

- (id)initWithItem:(id <GClusterItem>)clusterItem {
    if (self = [super init]) {
        _point.y = clusterItem.position.latitude;
        _point.x = clusterItem.position.longitude;
        _item = clusterItem;
    }
    return self;
}

- (GQTPoint)point {
    return _point;
}

- (id)copyWithZone:(NSZone *)zone {
    GQuadItem *newGQuadItem = [[self class] allocWithZone:zone];
    newGQuadItem->_point = _point;
    newGQuadItem->_item = _item;
    return newGQuadItem;
}

- (CLLocationCoordinate2D)position {
    return CLLocationCoordinate2DMake(_point.y, _point.x);
}

- (NSSet*)items {
    return [NSSet setWithObject:_item];
}

- (BOOL)isEqualToQuadItem:(GQuadItem *)other {
    return [_item isEqual:other->_item]
            && _point.x == other->_point.x
            && _point.y == other->_point.y;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToQuadItem:other];
}

- (NSUInteger)hash {
    return [_item hash];
}

@end
