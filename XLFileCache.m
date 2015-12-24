//
//  XLFileCache.m
//  XueLeTS
//
//  Created by wubing on 15/11/20.
//  Copyright © 2015年 net.xuele. All rights reserved.
//

#import "XLFileCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface XLFileCache()
@property (strong, nonatomic) NSString         *diskCachePath;
@property (strong, nonatomic) dispatch_queue_t ioQueue;
@end

@implementation XLFileCache
{
    NSFileManager *_fileManager;
}
+ (instancetype)cache {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[XLFileCache alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _ioQueue = dispatch_queue_create("net.xuele.XLWebFileCache", DISPATCH_QUEUE_SERIAL);
        dispatch_async(_ioQueue, ^{
            _fileManager = [NSFileManager new];
        });
    }
    return self;
}


#pragma mark public
- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self cachePathForKey:key inPath:self.diskCachePath];
}


- (void)createCachePathForKey:(NSString *)key{
    if (![_fileManager fileExistsAtPath:self.diskCachePath]) {
        [_fileManager createDirectoryAtPath:self.diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    [_fileManager createFileAtPath:[self defaultCachePathForKey:key] contents:nil attributes:nil];
}
#pragma mark private

- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    NSString *filename = [self cachedFileNameForKey:key];
    return [path stringByAppendingPathComponent:filename];
}


- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

#pragma mark - getter
- (NSString *)diskCachePath {
    if (_diskCachePath == nil) {
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _diskCachePath = [paths[0] stringByAppendingString:@"/net.xuele.XLWebFileCache.default"];
        if (![_fileManager fileExistsAtPath:_diskCachePath]) {
            [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
        }
    }
    return _diskCachePath;
}
@end
