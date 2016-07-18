#import "GMUDefaultClusterIconGenerator.h"

/* Extensions for testing purposes only. */
@interface GMUDefaultClusterIconGenerator (Testing)

/* Draws |text| on top of an |image| and returns the resultant image. */
- (UIImage *)iconForText:(NSString *)text withBaseImage:(UIImage *)image;

/**
 * Draws |text| on top of a circle whose background color is determined by |bucketIndex|
 * and returns the resultant image.
 */
- (UIImage *)iconForText:(NSString *)text withBucketIndex:(NSUInteger)bucketIndex;

@end
