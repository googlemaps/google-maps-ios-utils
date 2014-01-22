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
    
    int cacheCount = [markerCache count];
    int cacheItem = 0;
    
    for (id <GCluster> cluster in clusters) {
        GMSMarker *marker;
        if (cacheCount - cacheItem > 0) {
            marker = [markerCache objectAtIndex:cacheItem];
            cacheItem++;
        }
        else {
            marker = [[GMSMarker alloc] init];
            [markerCache addObject:marker];
        }
        
        if ([cluster count] > 1) {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        }
        else {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        }
        marker.position = cluster.position;
        marker.map = map;
    }
    
    for (int i=cacheItem; i<cacheCount; i++) {
        GMSMarker *marker = [markerCache objectAtIndex:i];
        marker.map = nil;
    }
}

@end
