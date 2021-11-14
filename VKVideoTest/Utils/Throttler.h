//
//  Throttler.h
//  VKVideoTest
//
//  Created by Виктор Семенов on 14.11.2021.
//

#import <Foundation/Foundation.h>

typedef void (^VoidBlock)(void);

@interface Throttler : NSObject

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval;
- (void)perform:(VoidBlock)block;
- (void)cancel;

@end
