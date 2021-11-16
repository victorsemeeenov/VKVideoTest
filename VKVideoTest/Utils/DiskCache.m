//
//  DiskCache.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 15.11.2021.
//

@import Foundation;
#import "DiskCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface DiskCache ()

@property (nonatomic) NSFileManager *fileManager;
@property (copy) NSString *folder;

@end

@implementation DiskCache

#pragma mark - Init

- (instancetype)initWithFolder:(NSString *)folder {
  self = [self init];
  if (self) {
    _folder = folder;
  }
  return self;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _fileManager = [NSFileManager defaultManager];
  }
  return self;
}

+ (instancetype)videosCache {
  return [[DiskCache alloc] initWithFolder:@"Videos"];
}

#pragma mark - Public

- (BOOL)hasDataForKey:(NSString *)key {
  return [_fileManager fileExistsAtPath:[self fileURLForKey:key].path];
}

- (void)appendData:(NSData *)data forKey:(NSString *)key {
  NSString *path = [self fileURLForKey:key].absoluteString;
  NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
  [fileHandle setWriteabilityHandler:^(NSFileHandle * _Nonnull fileHandle) {
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
  }];
}

- (void)storeData:(NSData *)data forKey:(NSString *)key {
  [self createDirectoryIfNeeded];
  [data writeToURL:[self fileURLForKey:key] atomically:YES];
}

- (NSData *)getDataForKey:(NSString *)key {
  return [NSData dataWithContentsOfURL:[self fileURLForKey:key]];
}

- (void)writeObject:(NSObject<NSCoding> *)object forKey:(NSString *)key {
  NSError *error;
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object
                                       requiringSecureCoding:NO
                                                       error:&error];
  if (error) {
    NSLog(@"Write failed with error: %@", error);
  }
  [self createDirectoryIfNeeded];
  [data writeToURL:[self fileURLForKey:key] atomically:YES];
}

- (NSObject<NSCoding> *)readObjectForKey:(NSString *)key {
  NSError *error;
  NSData *data = [NSData dataWithContentsOfURL:[self fileURLForKey:key]];
  NSObject<NSCoding> *object = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class]
                                                                 fromData:data
                                                                    error:&error];
  if (error) {
    NSLog(@"Write failed with error: %@", error);
  }
  return object;
}

- (NSURL *)fileURLForKey:(NSString *)key {
  NSURL *url = [NSURL URLWithString: key];
  NSString *name = [self md5:key];
  NSString *extension = [url pathExtension];
  NSURL *fileURL = [[self getCacheDirectory] URLByAppendingPathComponent:name];
  if (!extension) {
    return fileURL;
  }
  return [fileURL URLByAppendingPathExtension: extension];
}

#pragma mark - Private

- (NSString *)md5:(NSString *)input
{
  const char *cStr = [input UTF8String];
  unsigned char digest[CC_MD5_DIGEST_LENGTH];
  CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
  
  NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  
  for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
  
  return  output;
}

- (void)createDirectoryIfNeeded {
  NSURL *directoryURL = [self getCacheDirectory];
  if (![_fileManager fileExistsAtPath:directoryURL.path isDirectory:YES]) {
    [_fileManager createDirectoryAtURL:directoryURL withIntermediateDirectories:NO
                            attributes:nil error:nil];
  }
}

- (NSURL *)getCacheDirectory {
  NSURL *url = [[_fileManager URLsForDirectory:NSCachesDirectory
                                     inDomains:NSUserDomainMask]
                firstObject];
  if (!_folder) {
    return url;
  }
  return [url URLByAppendingPathComponent:_folder isDirectory:YES];
}

@end
