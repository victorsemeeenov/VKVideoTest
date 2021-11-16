//
//  Throttler.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 14.11.2021.
//

#import "Throttler.h"

@interface Throttler ()

@property (nonatomic) NSTimeInterval timeInterval;
@property (nonatomic) dispatch_block_t workItem;

@end

@implementation Throttler

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval {
  self = [super init];
  if (self) {
    _timeInterval = timeInterval;
  }
  return self;
}

- (void)perform:(VoidBlock)block {
  if (_workItem) {
    dispatch_block_cancel(_workItem);
  }
  _workItem = dispatch_block_create(0, block);
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_timeInterval * NSEC_PER_SEC)),
                 dispatch_get_main_queue(),
                 _workItem);
}

- (void)cancel {
  if (_workItem) {
    dispatch_block_cancel(_workItem);
  }
}

@end
