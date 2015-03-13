#import "GClusterManager.h"
#import "GCluster.h"

@implementation GClusterManager {
    GMSCameraPosition *previousCameraPosition;
}

- (void)setMapView:(GMSMapView*)mapView {
    previousCameraPosition = nil;
    _mapView = mapView;
}

- (void)setClusterAlgorithm:(id <GClusterAlgorithm>)clusterAlgorithm {
    previousCameraPosition = nil;
    _clusterAlgorithm = clusterAlgorithm;
}

- (void)setClusterRenderer:(id <GClusterRenderer>)clusterRenderer {
    previousCameraPosition = nil;
    _clusterRenderer = clusterRenderer;
}

- (void)addItem:(id <GClusterItem>) item {
    [_clusterAlgorithm addItem:item];
}

- (void)removeItems {
  [_clusterAlgorithm removeItems];
}

- (void)removeItemsNotInRectangle:(CGRect)rect {
    [_clusterAlgorithm removeItemsNotInRectangle:rect];
}

- (void)cluster {
    NSSet *clusters = [_clusterAlgorithm getClusters:_mapView.camera.zoom];
    [_clusterRenderer clustersChanged:clusters];
}

#pragma mark mapview delegate

-(void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:willMove:)]) {
        [self.delegate mapView:mapView willMove:gesture];
    }
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:didChangeCameraPosition:)]) {
        [self.delegate mapView:mapView didChangeCameraPosition:position];
    }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    assert(mapView == _mapView);
    
    // Don't re-compute clusters if the map has just been panned/tilted/rotated.
    GMSCameraPosition *position = [mapView camera];
    if (previousCameraPosition != nil && previousCameraPosition.zoom == position.zoom) {
        return;
    }
    previousCameraPosition = [mapView camera];
    
    [self cluster];
    
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:idleAtCameraPosition:)]) {
        [self.delegate mapView:mapView idleAtCameraPosition:cameraPosition];
    }
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:didTapAtCoordinate:)]) {
        [self.delegate mapView:mapView didTapAtCoordinate:coordinate];
    }
}

-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:didLongPressAtCoordinate:)]) {
        [self.delegate mapView:mapView didLongPressAtCoordinate:coordinate];
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:didTapMarker:)]) {
        return [self.delegate mapView:mapView didTapMarker:marker];
    }
    
    return true;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:didTapInfoWindowOfMarker:)]) {
        [self.delegate mapView:mapView didTapInfoWindowOfMarker:marker];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapOverlay:(GMSOverlay *)overlay {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:didTapOverlay:)]) {
        [self.delegate mapView:mapView didTapOverlay:overlay];
    }
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:markerInfoWindow:)]) {
        return [self.delegate mapView:mapView markerInfoWindow:marker];
    }
    
    return nil;
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoContents:(GMSMarker *)marker {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:markerInfoContents:)]) {
        return [self.delegate mapView:mapView markerInfoContents:marker];
    }
    
    return nil;
}

- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:didBeginDraggingMarker:)]) {
        [self.delegate mapView:mapView didBeginDraggingMarker:marker];
    }
}

-(void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:didEndDraggingMarker:)]) {
        [self.delegate mapView:mapView didEndDraggingMarker:marker];
    }
}

- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
    if ([self delegate] != nil
        && [self.delegate respondsToSelector:@selector(mapView:didDragMarker:)]) {
        [self.delegate mapView:mapView didDragMarker:marker];
    }
}

#pragma mark convenience

+ (instancetype)managerWithMapView:(GMSMapView*)googleMap
                         algorithm:(id<GClusterAlgorithm>)algorithm
                          renderer:(id<GClusterRenderer>)renderer {
    GClusterManager *mgr = [[[self class] alloc] init];
    if(mgr) {
        mgr.mapView = googleMap;
        mgr.clusterAlgorithm = algorithm;
        mgr.clusterRenderer = renderer;
    }
    return mgr;
}

@end
