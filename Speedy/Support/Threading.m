#import <objc/runtime.h>

#import "Threading.h"

@implementation SThreadingThread
- (instancetype)initWithLock:(NSConditionLock *)lock block:(SThreadingBlock)block
{
  self = [super init];
  if (self)
  {
    self.lock = lock;
    self.block = block;
  }
  return self;
}
@end

@interface SThreading ()
- (void)runInThread:(SThreadingThread *)thread;
@end

@implementation SThreading

- (NSConditionLock *)launchLockingThreadWithBlock:(SThreadingBlock)block
{
  NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:SThreadRunning];

  SThreadingThread *thread = [[SThreadingThread alloc] initWithLock:lock
                                                              block:block];

  NSThread *targetThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector(runInThread:)
                                                     object:thread];

  [targetThread start];

  return lock;
}

- (void)runBlockOnThread:(SThreadingBlock)block
{
  NSConditionLock *lock = [self launchLockingThreadWithBlock:block];

  // Block until the lock is unlocked by the thread
  [lock lockWhenCondition:SThreadDone];
}

- (BOOL)runBlockOnThread:(SThreadingBlock)block withTimeout:(NSDate *)timeoutDate
{
  NSConditionLock *lock = [self launchLockingThreadWithBlock:block];

  BOOL didntTimeout = [lock lockWhenCondition:SThreadDone beforeDate:timeoutDate];

  return didntTimeout;
}

- (void)runInThread:(SThreadingThread *)thread
{
  NSConditionLock *lock = thread.lock;
  SThreadingBlock block = thread.block;

  NSAssert([lock tryLock] == YES, @"Unable to acquire initial lock");

  block();

  [lock unlockWithCondition:SThreadDone];
}

@end
