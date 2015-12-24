//
//  XLWebFileDownloader.m
//  XueLeTS
//
//  Created by wubing on 15/11/20.
//  Copyright © 2015年 net.xuele. All rights reserved.
//

#import "XLWebFileManager.h"
#import "XLWebFileDownloader.h"
#import "XLFileCache.h"

@interface XLWebFileManager()
@property (strong, nonatomic) XLWebFileDownloader *downloader;
@property (strong, nonatomic) XLFileCache         *fileCache;
@property (strong, nonatomic) NSMutableSet        *failedURLs;
@property (strong, nonatomic) NSMutableArray      *runningTasks;
@end

@implementation XLWebFileManager
+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[XLWebFileManager alloc] init];
    });
    return instance;
}
#pragma mark - public
- (void)downloadWithURL:(NSURL *)url {
    [self downloadWithURL:url progress:nil completion:nil];
}

- (void)downloadWithURL:(NSURL *)url completion:(void (^)(NSURL *filePath, NSError * error))complete {
    [self downloadWithURL:url progress:nil completion:complete];
}

- (void)downloadWithURL:(NSURL *)url progress:(NSProgress * )progress completion:(void (^)(NSURL *filePath, NSError * error))complete {
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }
    BOOL isFailedUrl = NO;
    @synchronized (self.failedURLs) {
        isFailedUrl = [self.failedURLs containsObject:url];
    }
    if (!url || isFailedUrl) {
        dispatch_main_sync_safe(^{
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            if (complete) {
              complete(nil,error);
            }
        });
        return;
    }
    if ([self diskFileExistsForURL:url]) {
        if (complete) {
            complete([NSURL fileURLWithPath:[self cachePathForURL:url]],nil);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:XLWebFileDownloadCompleteNotification object:url];
        return;
    }
    if ([self.runningTasks containsObject:url]) {
        return;
    }
    @synchronized(self.runningTasks) {
        [self.runningTasks addObject:url];
    }
    NSString * path = [self cachePathForURL:url];
    [self.downloader downloadWithURL:url localPath:path progress:progress completion:^(NSURL *filePath, NSError *error) {
        if (error && error.code != NSURLErrorNotConnectedToInternet && error.code != NSURLErrorCancelled && error.code != NSURLErrorTimedOut) {
            @synchronized (self.failedURLs) {
                [self.failedURLs addObject:url];
            }
        }
        [self.runningTasks removeObject:url];
        if (complete) {
            complete(filePath,error);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:XLWebFileDownloadCompleteNotification object:url];
    }];
}

- (BOOL)diskFileExistsForURL:(NSURL *)url {
    NSString *path = [self cachePathForURL:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (BOOL)fileIsDownloadingForURL:(NSURL *)url{
    return [self.runningTasks containsObject:url];
}
#pragma mark - private
- (NSString *)cachePathForURL:(NSURL *)url {
   return [[self.fileCache defaultCachePathForKey:[self cacheKeyForURL:url]] stringByAppendingFormat:@".%@",[[url absoluteString] pathExtension]];
}


- (NSString *)cacheKeyForURL:(NSURL *)url {
    return [url absoluteString];
}

#pragma mark - getter
- (NSMutableArray *)runningTasks{
    if (_runningTasks == nil){
        _runningTasks = [NSMutableArray new];
    }
    return _runningTasks;
}

- (NSMutableSet *)failedURLs{
    if (_failedURLs == nil){
        _failedURLs = [NSMutableSet new];
    }
    return _failedURLs;
}

- (XLFileCache *)fileCache {
    if (_fileCache == nil){
        _fileCache = [XLFileCache cache];
    }
    return _fileCache;
}

- (XLWebFileDownloader *)downloader {
    if (_downloader == nil) {
        _downloader =  [XLWebFileDownloader shareDownloader];
    }
    return _downloader;
}
@end
