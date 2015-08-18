#import <Foundation/Foundation.h>

typedef void (^SThreadingBlock)(void);

typedef NS_ENUM(NSInteger, SThreadState) {
  SThreadRunning,
  SThreadDone
};

@interface SThreadingThread : NSObject
@property (strong) NSConditionLock *lock;
@property (strong) SThreadingBlock block;
- (instancetype)initWithLock:(NSConditionLock *)lock block:(SThreadingBlock)block;
@end

@interface SThreading : NSObject
- (void)runBlockOnThread:(SThreadingBlock)block;
- (BOOL)runBlockOnThread:(SThreadingBlock)block withTimeout:(NSDate *)timeoutDate;
@end
