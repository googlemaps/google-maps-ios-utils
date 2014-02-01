#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol GCluster <NSObject>

- (CLLocationCoordinate2D)position;

- (int)count;

- (NSSet*)getItems;

@end
