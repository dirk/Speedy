#import <Foundation/Foundation.h>

typedef void (^SThreadingBlock)(void);

@interface SThreading : NSObject

+ (void)runBlockOnThread:(SThreadingBlock)block;
+ (BOOL)runBlockOnThread:(SThreadingBlock)block withTimeout:(NSDate *)timeoutDate;

@end
