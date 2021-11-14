//
//  MulticastDelegate.h
//  VKVideoTest
//
//  Created by Виктор Семенов on 13.11.2021.
//

@import Foundation;
#import "WeakRef.h"

@interface MulticastDelegate: NSProxy

@property (nonatomic, copy, readonly, nonnull) NSMutableArray<WeakRef *> *delegates;
- (nonnull instancetype)init;
- (void)addDelegate:(nonnull id)delegate;
- (void)removeDelegate:(nonnull id)delegate;

@end
