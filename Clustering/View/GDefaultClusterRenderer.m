#import "GDefaultClusterRenderer.h"
#import "GQuadItem.h"
#import "GCluster.h"

@implementation GDefaultClusterRenderer

- (id)initWithGoogleMap:(GMSMapView*)googleMap {
    if (self = [super init]) {
        map = googleMap;
        markerCache = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)clustersChanged:(NSSet*)clusters {
    for (GMSMarker *marker in markerCache) {
        marker.map = nil;
    }
    
    [markerCache removeAllObjects];
    
    for (id <GCluster> cluster in clusters) {
        GMSMarker *marker;
        marker = [[GMSMarker alloc] init];
        [markerCache addObject:marker];
        
        if ([cluster count] > 1) {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        }
        else {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        }
        marker.position = cluster.position;
        marker.map = map;
    }
}

@end
