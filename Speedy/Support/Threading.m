#import <objc/runtime.h>

#import "Threading.h"

@interface SThreading ()
+ (void)runInThread:(SThreadingThread *)thread;
@end

@implementation SThreading

+ (NSLock *)launchLockingThreadWithBlock:(SThreadingBlock)block
{
  NSLock *lock = [NSLock new];
  NSThread *thread = [NSThread new];

  SThreadingThread *param = [SThreadingThread new];
  param.lock = lock;

  [self performSelector:@selector(runInThread:)
               onThread:thread
             withObject:param
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
