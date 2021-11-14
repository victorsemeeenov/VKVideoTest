//
//  WeakRef.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 13.11.2021.
//

#import "WeakRef.h"

@implementation WeakRef

- (instancetype)initWithValue:(id)value {
  self = [super init];
  if (self) {
    _value = value;
  }
  return self;
}

+ (instancetype)weakRefWithValue:(id)value {
  return [[self alloc] initWithValue:value];
}

- (BOOL)isEqual:(id)object {
  return [object isKindOfClass:[WeakRef class]] && [[(WeakRef *)object value] isEqual:self.value];
}

- (NSUInteger)hash {
  return [self.value hash];
}

@end
