//
//  XLWebFileDownloader.h
//  XueLeTS
//
//  Created by wubing on 15/11/18.
//  Copyright © 2015年 net.xuele. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  网络文件下载类  对AFHTTPSessionManager下载接口的封装 
 *  用于项目中网络资源文件下载
 *
 */

@interface XLWebFileDownloader : NSObject
/**
 *  下载单例类
 *  全局维护下载队列 将管理所有下载任务
 */
+ (instancetype)shareDownloader;

/**
 *  下载方法
 *  @param url      待下载资源路径
 *  @param filePath 本地存储路径
 *  @param complete 下载结束回调
 */
- (void)downloadWithURL:(NSURL *)url localPath:(NSString *)filePath progress:(NSProgress * )progress completion:(void (^)(NSURL *filePath, NSError * erro))complete;
@end
