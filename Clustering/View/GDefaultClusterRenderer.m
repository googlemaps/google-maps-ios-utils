#import "GDefaultClusterRenderer.h"
#import "GQuadItem.h"

@implementation GDefaultClusterRenderer

- (id)initWithGoogleMap:(GMSMapView*)googleMap {
    if (self = [super init]) {
        map = googleMap;
    }
    return self;
}

- (void)clustersChanged:(NSSet*)clusters {
    for (GQuadItem *item in clusters) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        marker.position = item.position;
        marker.map = map;
    }
}

@end
