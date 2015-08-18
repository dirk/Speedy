#import <objc/runtime.h>

#import "Threading.h"

@implementation SThreadingThread
- (instancetype)initWithLock:(NSLock *)lock thread:(NSThread *)thread block:(SThreadingBlock)block
{
  self = [super init];
  if (self)
  {
    self.lock = lock;
    self.thread = thread;
    self.block = block;
  }
  return self;
}
@end

@interface SThreading ()
+ (void)runInThread:(SThreadingThread *)thread;
@end

@implementation SThreading

+ (NSLock *)launchLockingThreadWithBlock:(SThreadingBlock)block
{
  NSLock *lock = [NSLock new];
  NSThread *targetThread = [NSThread new];

  SThreadingThread *thread = [[SThreadingThread alloc] initWithLock:lock
                                                             thread:targetThread
                                                              block:block];

  [self performSelector:@selector(runInThread:)
               onThread:targetThread
             withObject:thread
          waitUntilDone:NO];

  return lock;
}

+ (void)runBlockOnThread:(SThreadingBlock)block
{
  NSLock *lock = [self launchLockingThreadWithBlock:block];

  // Block until the lock is unlocked by the thread
  [lock lock];
}

+ (BOOL)runBlockOnThread:(SThreadingBlock)block withTimeout:(NSDate *)timeoutDate
{
  NSLock *lock = [self launchLockingThreadWithBlock:block];

  BOOL didntTimeout = [lock lockBeforeDate:timeoutDate];

  return didntTimeout;
}

+ (void)runInThread:(SThreadingThread *)thread
{
  NSLock *lock = thread.lock;
  SThreadingBlock block = thread.block;

  NSAssert([lock tryLock], @"Unable to acquire initial lock");

  block();

  [lock unlock];
}

@end
