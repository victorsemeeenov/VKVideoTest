//
//  DataTaskLoader.h
//  VKVideoTest
//
//  Created by Виктор Семенов on 16.11.2021.
//

#import <Foundation/Foundation.h>

@class DataTaskLoader;

#pragma mark - DataTaskLoaderDelegate

@protocol DataTaskLoaderDelegate

@required
- (void)loader:(DataTaskLoader *)loader didUpdateProgress:(float)progress
forDownloadTask:(NSURLSessionDownloadTask *)task;
- (void)loader:(DataTaskLoader *)loader didFinishLoadingData:(NSData *)data
forDownloadTask:(NSURLSessionDownloadTask *)task;
- (void)loader:(DataTaskLoader *)loader didReceiveError:(NSError *)error;

@end

#pragma mark - DataTaskLoader

@interface DataTaskLoader : NSObject<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (weak, nonatomic) NSObject<DataTaskLoaderDelegate> *delegate;

@end
