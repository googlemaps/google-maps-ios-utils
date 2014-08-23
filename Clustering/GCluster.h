#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol GCluster <NSObject>

@property(nonatomic, assign, readonly) CLLocationCoordinate2D position;

@property(nonatomic, strong, readonly) NSSet *items;

@end
