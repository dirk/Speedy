#import <objc/runtime.h>

#import "Threading.h"

@implementation SThreadingThread
- (instancetype)initWithLock:(NSLock *)lock thread:(NSThread *)thread
{
  self = [super init];
  if (self)
  {
    self.lock = lock;
    self.thread = thread;
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
                                                             thread:targetThread];

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

  NSAssert([lock tryLock], @"Unable to acquire initial lock");

  [lock unlock];
}

@end
