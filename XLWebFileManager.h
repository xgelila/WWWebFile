//
//  XLWebFileDownloader.h
//  XueLeTS
//
//  Created by wubing on 15/11/20.
//  Copyright © 2015年 net.xuele. All rights reserved.
//

static NSString * const XLWebFileDownloadCompleteNotification = @"XLWebFileDownloadCompleteNotification";

#import <Foundation/Foundation.h>

/**
 * 下载管理类 作为项目全局的下载任务管理
 */

@interface XLWebFileManager : NSObject

/**
 *  单例下载管理类 
 *
 */
+ (instancetype)manager;

/**
 *  下载资源
 *
 *  @param url 资源地址
 */
- (void)downloadWithURL:(NSURL *)url;

/**
 *  下载资源
 *
 *  @param url      资源地址
 *  @param complete 完成回调
 */
- (void)downloadWithURL:(NSURL *)url completion:(void (^)(NSURL *filePath, NSError * erro))complete;

/**
 *  下载资源
 *
 *  @param url      资源地址
 *  @param progress 下载过程回调
 *  @param complete 完成回调
 */
- (void)downloadWithURL:(NSURL *)url progress:(NSProgress * )progress completion:(void (^)(NSURL *filePath, NSError * erro))complete;

/**
 *  磁盘上存在地址为url的文件
 *
 */
- (BOOL)diskFileExistsForURL:(NSURL *)url;

/**
 *  该url资源正在下载
 *
 */
- (BOOL)fileIsDownloadingForURL:(NSURL *)url;

/**
 *  根据资源url获得下载后在本地存储路径
 *
 */
- (NSString *)cachePathForURL:(NSURL *)url;
@end
