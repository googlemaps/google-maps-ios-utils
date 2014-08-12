#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GClusterAlgorithm.h"
#import "GClusterRenderer.h"
#import "GQTPointQuadTreeItem.h"

@interface GClusterManager : NSObject <GMSMapViewDelegate> {
    GMSMapView *map;
    id <GClusterAlgorithm> algorithm;
    id <GClusterRenderer> renderer;
    GMSCameraPosition *previousCameraPosition;
}

- (void)setMapView:(GMSMapView*)mapView;

- (void)setClusterAlgorithm:(id <GClusterAlgorithm>)clusterAlgorithm;

- (void)setClusterRenderer:(id <GClusterRenderer>)clusterRenderer;

- (void)addItem:(id <GClusterItem>) item;

- (void)removeItems;

- (void)cluster;

@end
