//
//  DataTaskLoader.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 16.11.2021.
//

#import "DataTaskLoader.h"

@implementation DataTaskLoader

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
  [_delegate loader:self didUpdateProgress: progress forDownloadTask:downloadTask];
}

- (void)URLSession:(nonnull NSURLSession *)session
      downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(nonnull NSURL *)location {
  NSData *data = [NSData dataWithContentsOfURL: location];
  [_delegate loader:self didFinishLoadingData:data forDownloadTask:downloadTask];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
  [_delegate loader:self didReceiveError:error];
}

@end
