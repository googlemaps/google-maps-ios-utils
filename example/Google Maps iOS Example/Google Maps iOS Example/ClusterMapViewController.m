//
//  ClusterMapViewController.m
//  Google Maps iOS Example
//
//  Created by Colin Edwards on 2/1/14.
//
//

#import "ClusterMapViewController.h"
@import CoreLocation;
#import "Spot.h"
#import "NonHierarchicalDistanceBasedAlgorithm.h"
#import "GDefaultClusterRenderer.h"

@interface ClusterMapViewController ()

@end

@implementation ClusterMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:51.503186
                                                            longitude:-0.126446
                                                                 zoom:9.5];
	
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.settings.compassButton = YES;
    self.view = mapView_;
    
    clusterManager = [[GClusterManager alloc] init];
    [clusterManager setMapView:mapView_];
    [clusterManager setClusterAlgorithm:[[NonHierarchicalDistanceBasedAlgorithm alloc] init]];
    [clusterManager setClusterRenderer:[[GDefaultClusterRenderer alloc] initWithGoogleMap:mapView_]];
    
    [mapView_ setDelegate:clusterManager];
    
    for (int i=0; i<12; i++) {
        Spot* spot = [self generateSpot];
        [clusterManager addItem:spot];
    }
    
    [clusterManager cluster];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (Spot*)generateSpot {
    Spot* spot = [[Spot alloc] init];
    spot.location = CLLocationCoordinate2DMake(
                                               [self getRandomNumberBetween:51.38494009999999 maxNumber:51.6723432],
                                               [self getRandomNumberBetween:-0.3514683 maxNumber:0.148271]);
    return spot;
}

- (double)getRandomNumberBetween:(double)min maxNumber:(double)max
{
    return min + (max - min)*drand48();
}

@end
