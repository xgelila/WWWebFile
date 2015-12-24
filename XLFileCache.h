//
//  XLFileCache.h
//  XueLeTS
//
//  Created by wubing on 15/11/20.
//  Copyright © 2015年 net.xuele. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  文件缓存管理类
 *
 */
@interface XLFileCache : NSObject

/**
 *  文件缓存单例类
 *
 */
+ (instancetype)cache;

/**
 *  根据key来获取文件缓存路径
 *
 *  @param key 文件名来源 如url
 *
 *  @return 本地缓存文件路径
 */
- (NSString *)defaultCachePathForKey:(NSString *)key;


/**
 *  创建缓存文件
 *
 */
- (void)createCachePathForKey:(NSString *)key;
@end
