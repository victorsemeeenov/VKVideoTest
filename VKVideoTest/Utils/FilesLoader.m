//
//  FilesLoader.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 16.11.2021.
//

#import "FilesLoader.h"
#import "DataTaskLoader.h"
#import "DiskCache.h"

@interface FilesLoader ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) DataTaskLoader *dataTaskLoader;
@property (nonatomic) NSMutableDictionary<NSNumber*, NSURL*> *pendingTasks;
@property (nonatomic) DiskCache *diskCache;

@end

@implementation FilesLoader

- (instancetype)init {
  self = [super init];
  if (self) {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    config.timeoutIntervalForRequest = 15;
    _dataTaskLoader = [DataTaskLoader new];
    _dataTaskLoader.delegate = self;
    _session = [NSURLSession sessionWithConfiguration:config
                                             delegate:_dataTaskLoader
                                        delegateQueue:NSOperationQueue.mainQueue];
    _pendingTasks = [NSMutableDictionary new];
    _diskCache = [DiskCache videosCache];
  }
  return self;
}

- (void)dealloc {
  [_session invalidateAndCancel];
}

- (void)downloadFileForURL:(NSURL *)url {
  NSURLSessionDownloadTask *downloadTask = [_session downloadTaskWithURL:url];
  [_pendingTasks setObject:url forKey: [NSNumber numberWithInt:(int)downloadTask.taskIdentifier]];
  [downloadTask resume];
}

#pragma mark - DataTaskLoaderDelegate

- (void)loader:(DataTaskLoader *)loader didFinishLoadingData:(NSData *)data
forDownloadTask:(NSURLSessionDownloadTask *)task {
  NSNumber *identifier = [NSNumber numberWithInt:(int)task.taskIdentifier];
  NSURL *url = [_pendingTasks objectForKey:identifier];
  [_diskCache storeData:data forKey:url.absoluteString];
  [_pendingTasks removeObjectForKey:identifier];
}

- (void)loader:(DataTaskLoader *)loader didUpdateProgress:(float)progress forDownloadTask:(NSURLSessionDownloadTask *)task {
  NSNumber *identifier = [NSNumber numberWithInt:(int)task.taskIdentifier];
  NSURL *url = [_pendingTasks objectForKey:identifier];
  [_delegate loader:self didUpdateProgress:progress forURL:url];
}

- (void)loader:(DataTaskLoader *)loader didReceiveError:(NSError *)error {
  if (error != nil) {
    [_delegate loader:self didReceiveError:error];
  }
}

@end
