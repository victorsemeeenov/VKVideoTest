//
//  FilesLoader.h
//  VKVideoTest
//
//  Created by Виктор Семенов on 16.11.2021.
//

#import <Foundation/Foundation.h>
#import "DataTaskLoader.h"

@class FilesLoader;

@protocol FilesLoaderDelegate

@optional
- (void)loader:(FilesLoader *)loader didUpdateProgress:(float)progress forURL:(NSURL *)url;
- (void)loader:(FilesLoader *)loader didDownloadData:(NSData *)data forURL:(NSURL *)url;
- (void)loader:(FilesLoader *)loader didReceiveError:(NSError *)error;

@end

@interface FilesLoader : NSObject<DataTaskLoaderDelegate>

@property (weak, nonatomic) NSObject<FilesLoaderDelegate> *delegate;

- (void)downloadFileForURL:(NSURL *)url;

@end
