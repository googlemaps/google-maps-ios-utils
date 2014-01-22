#import <Foundation/Foundation.h>

@protocol GCluster <NSObject>

- (CLLocationCoordinate2D)position;

- (int)count;

- (NSSet*)getItems;

@end
