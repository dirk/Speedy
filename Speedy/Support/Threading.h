#import <Foundation/Foundation.h>

typedef void (^SThreadingBlock)(void);

@interface SThreadingThread : NSObject
@property (strong) NSLock *lock;
@property (strong) NSThread *thread;
@property (strong) SThreadingBlock block;
- (instancetype)initWithLock:(NSLock *)lock thread:(NSThread *)thread block:(SThreadingBlock)block;
@end

@interface SThreading : NSObject
+ (void)runBlockOnThread:(SThreadingBlock)block;
+ (BOOL)runBlockOnThread:(SThreadingBlock)block withTimeout:(NSDate *)timeoutDate;
@end
