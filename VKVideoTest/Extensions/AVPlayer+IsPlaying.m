//
//  AVPlayer+IsPlaying.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 13.11.2021.
//

#import "AVPlayer+IsPlaying.h"

@implementation AVPlayer (IsPlaying)

- (BOOL)isPlaying {
  return self.rate != 0 && self.error == nil;
}

@end
