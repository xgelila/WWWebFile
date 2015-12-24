//
//  XLWebFileDownloader.m
//  XueLeTS
//
//  Created by wubing on 15/11/18.
//  Copyright © 2015年 net.xuele. All rights reserved.
//

#import "XLWebFileDownloader.h"
#import "AFHTTPSessionManager.h"

@interface XLWebFileDownloader()
@property (strong, nonatomic) AFHTTPSessionManager *downloadManager;
@end

@implementation XLWebFileDownloader

+ (instancetype)shareDownloader{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[XLWebFileDownloader alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init])
    {
        _downloadManager = [AFHTTPSessionManager manager];
        _downloadManager.operationQueue.maxConcurrentOperationCount = 5;
    }
    return self;
}

- (void)downloadWithURL:(NSURL *)url localPath:(NSString *)filePath progress:(NSProgress *)progress completion:(void (^)(NSURL *filePath, NSError * erro))complete{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task = [_downloadManager downloadTaskWithRequest:request progress:NULL destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *url = [NSURL fileURLWithPath:filePath];
        return url;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (complete) {
            complete(filePath,error);
        }
    }];
    [task resume];
}
@end
