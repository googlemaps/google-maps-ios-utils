#import "GClusterManager.h"

@implementation GClusterManager

- (void)setMapView:(GMSMapView*)mapView {
    map = mapView;
}

- (void)setClusterAlgorithm:(id <GClusterAlgorithm>)clusterAlgorithm {
    algorithm = clusterAlgorithm;
}

- (void)setClusterRenderer:(id <GClusterRenderer>)clusterRenderer {
    renderer = clusterRenderer;
}

- (void)addItem:(id <GClusterItem>) item {
    [algorithm addItem:item];
}

- (void)removeItems
{
  [algorithm removeItems];
}

- (void)cluster {
    NSSet *clusters = [algorithm getClusters:map.camera.zoom];
    [renderer clustersChanged:clusters];
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    // Don't re-compute clusters if the map has just been panned/tilted/rotated.
    GMSCameraPosition *position = [mapView camera];
    if (previousCameraPosition != nil && previousCameraPosition.zoom == position.zoom) {
        return;
    }
    previousCameraPosition = [mapView camera];
    
    [self cluster];
}

@end
