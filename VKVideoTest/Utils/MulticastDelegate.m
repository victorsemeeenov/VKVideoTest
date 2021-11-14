//
//  MulticastDelegate.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 13.11.2021.
//

#import "MulticastDelegate.h"

@implementation MulticastDelegate

- (instancetype)init {
  _delegates = [NSMutableArray array];
  return self;
}

- (void)addDelegate:(id)delegate {
  [self.delegates addObject:[WeakRef weakRefWithValue:delegate]];
}

- (void)removeDelegate:(id)delegate {
  [self.delegates removeObject:[WeakRef weakRefWithValue:delegate]];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  return [[self.delegates.firstObject value] methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  for (WeakRef *delegate in self.delegates) {
    if (delegate.value != nil && [delegate.value respondsToSelector:invocation.selector]) {
      [invocation invokeWithTarget:delegate.value];
    }
  }
}

@end
