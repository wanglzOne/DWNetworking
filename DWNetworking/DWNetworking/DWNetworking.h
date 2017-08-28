//
//  DWNetworking.h
//  DWNetworking
//
//  Created by dawng on 2017/8/28.
//  Copyright © 2017年 CoderDwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DWNetworking : NSObject

typedef void (^DWResponseSuccess)(id response);

typedef void (^DWResponseFail)(NSError *error);

/**
 设置请求地址的基础url

 @param url 如http://www.baidu.com/
 */
+ (void)setBaseUrlString:(NSString *)url;

/**
 获取当前的基础url

 @return baseUrl
 */
+ (NSString *)baseUrlString;

/**
 是否开启网络请求状态指示器

 @param enabled 默认开启
 */
+ (void)setNetworkActivityEnabled:(BOOL)enabled;

/**
 设置请求头

 @param config 协商好的参数
 */
+ (void)setHttpHeaderConfig:(NSDictionary *)config;

/**
 设置请求超时

 @param time 超时时长/默认60s
 */
+ (void)setTimeoutInterval:(NSTimeInterval)time;

/**
 设置最大请求并发数

 @param count 默认3
 */
+ (void)setMaxConcurrentOperationCount:(NSInteger)count;

/**
 GET

 @param url 请求地址
 @param params 请求参数/可为空
 @param success 成功
 @param fail 失败
 */
+ (void)getUrlString:(NSString *)url params:(NSDictionary *)params success:(DWResponseSuccess)success fail:(DWResponseFail)fail;

/**
 POST

 @param url 请求地址
 @param params 请求参数
 @param success 成功
 @param fail 失败
 */
+ (void)postUrlString:(NSString *)url params:(NSDictionary *)params success:(DWResponseSuccess)success fail:(DWResponseFail)fail;

/**
 多图上传

 @param images 图片数组
 @param url 上传地址
 @param fileNames 文件名数组,带后缀
 @param names 与指定的图片相关联的名称，这是由后端写接口的人指定的，如imagefiles
 @param imgType image/jpeg
 @param parameters 参数
 @param progress 进度
 @param success 成功
 @param fail 失败
 */
+ (void)uploacWithImages:(NSArray<UIImage *>*)images url:(NSString *)url fileNames:(NSArray<NSString *> *)fileNames names:(NSArray<NSString *> *)names imgType:(NSString *)imgType parameters:(NSDictionary *)parameters progress:(void(^)(NSProgress *progress))progress success:(DWResponseSuccess)success fail:(DWResponseFail)fail;

/**
 是否自动使用缓存/即为请求失败或者当前无网络连接，如果缓存中有数据则返回缓存数据，无数据则走失败接口

 @param cache 默认为YES
 */
+ (void)setAutoUseCache:(BOOL)cache;

/**
 取消全部请求
 */
+ (void)cancelAllTask;

/**
 清除全部缓存
 */
+ (void)cleanAllCache;

@end
