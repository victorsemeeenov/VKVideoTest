//
//  WeakRef.h
//  VKVideoTest
//
//  Created by Виктор Семенов on 13.11.2021.
//

@import Foundation;

@interface WeakRef: NSObject

@property (nonatomic, weak, nullable, readonly) id value;
+ (nonnull instancetype)weakRefWithValue:(nullable id)value;

@end

