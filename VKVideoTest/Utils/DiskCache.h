//
//  DiskCache.h
//  VKVideoTest
//
//  Created by Виктор Семенов on 15.11.2021.
//

#import <Foundation/Foundation.h>

@interface DiskCache : NSObject

- (instancetype)initWithFolder:(NSString *)folder;
+ (instancetype)videosCache;

- (NSURL *)fileURLForKey:(NSString *)key;
- (BOOL)hasDataForKey:(NSString *)key;
- (void)appendData:(NSData *)data forKey:(NSString *)key;
- (void)storeData:(NSData *)data forKey:(NSString *)key;
- (NSData *)getDataForKey:(NSString *)key;
- (void)writeObject:(NSObject<NSCoding> *)object forKey:(NSString *)key;
- (NSObject<NSCoding> *)readObjectForKey:(NSString *)key;

@end
