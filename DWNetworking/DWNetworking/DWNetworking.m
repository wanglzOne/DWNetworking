//
//  DWNetworking.m
//  DWNetworking
//
//  Created by dawng on 2017/8/28.
//  Copyright © 2017年 CoderDwang. All rights reserved.
//

#ifdef DEBUG
#define NSLog( s, ... ) NSLog( @"\n[所在文件:%@]\n[所在方法:%s]\n[所在行数:%d]\n[打印内容:%@]", NSStringFromClass([self class]), __func__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define NSLog(...);
#endif


#import "DWNetworking.h"
#import <AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>
#import <YYCache.h>

/** 基础url */
static NSString *_networking_baseUrl = nil;
/** 是否显示网络请求状态指示器 */
static BOOL _networkActivityEnabled = YES;
/** afn */
static AFHTTPSessionManager *_networkingSession = nil;
/** 请求头 */
static NSDictionary *_networkingHttpHeaderConfig = nil;
/** 超时时长 */
static NSTimeInterval _networkingTimeout = 60.0f;
/** 最大请求并发数 */
static NSInteger _networkingMaxConcurrentCount = 3;
/** 是否自动使用缓存 */
static BOOL _networkingAutoUseCache = YES;

static NSString *kNetworkingCache = @"kNetworkingCache";

@implementation DWNetworking

+ (void)setBaseUrlString:(NSString *)url {
    _networking_baseUrl = url;
}

+ (NSString *)baseUrlString {
    return _networking_baseUrl;
}

+ (void)setHttpHeaderConfig:(NSDictionary *)config {
    _networkingHttpHeaderConfig = config;
}

+ (void)setTimeoutInterval:(NSTimeInterval)time {
    _networkingTimeout = time;
}

+ (void)setNetworkActivityEnabled:(BOOL)enabled {
    _networkActivityEnabled = enabled;
}

+ (void)setMaxConcurrentOperationCount:(NSInteger)count {
    _networkingMaxConcurrentCount = count;
}

+ (void)setAutoUseCache:(BOOL)cache {
    _networkingAutoUseCache = cache;
}

+ (AFHTTPSessionManager *)afnetworingManager {
    @synchronized (self) {
        if (_networkActivityEnabled) {
            [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        }
        AFHTTPSessionManager *manager = nil;
        if ([self baseUrlString]) {
            manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self baseUrlString]]];
        }else {
            manager = [AFHTTPSessionManager manager];
        }
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
        if (_networkingHttpHeaderConfig) {
            for (NSString *key in [_networkingHttpHeaderConfig allKeys]) {
                [manager.requestSerializer setValue:_networkingHttpHeaderConfig[key] forHTTPHeaderField:key];
            }
        }
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                                  @"text/html",
                                                                                  @"text/json",
                                                                                  @"text/plain",
                                                                                  @"text/javascript",
                                                                                  @"text/xml",
                                                                                  @"image/*"]];
        manager.requestSerializer.timeoutInterval = _networkingTimeout;
        manager.operationQueue.maxConcurrentOperationCount = _networkingMaxConcurrentCount;
        _networkingSession = manager;
    }
    return _networkingSession;
}

+ (void)getUrlString:(NSString *)url params:(NSDictionary *)params success:(DWResponseSuccess)success fail:(DWResponseFail)fail {
    AFHTTPSessionManager *manager = [self afnetworingManager];
    YYCache *cache = [self yyCache];
    [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [cache setObject:responseObject forKey:url];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([cache containsObjectForKey:url]) {
            success([cache objectForKey:url]);
        }else {
            fail(error);
        }
    }];
}

+ (void)postUrlString:(NSString *)url params:(NSDictionary *)params success:(DWResponseSuccess)success fail:(DWResponseFail)fail {
    AFHTTPSessionManager *manager = [self afnetworingManager];
    YYCache *cache = [self yyCache];
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    success(responseObject);
        [cache setObject:responseObject forKey:url];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([cache containsObjectForKey:url]) {
            success([cache objectForKey:url]);
        }else {
            fail(error);
        }
    }];
}

+ (void)uploacWithImages:(NSArray<UIImage *>*)images url:(NSString *)url fileNames:(NSArray<NSString *> *)fileNames names:(NSArray<NSString *> *)names imgType:(NSString *)imgType parameters:(NSDictionary *)parameters progress:(void(^)(NSProgress *progress))progress success:(DWResponseSuccess)success fail:(DWResponseFail)fail {
    AFHTTPSessionManager *manager = [self afnetworingManager];
    [manager POST:[NSString stringWithFormat:@"%@%@", [self baseUrlString], url] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i = 0; i < images.count; i ++) {
            NSData *data = UIImageJPEGRepresentation([self compressImage:images[i]], 1);
            [formData appendPartWithFileData:data name:names[i] fileName:fileNames[i] mimeType:imgType];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseData) {
        success(responseData);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
}

+ (void)cancelAllTask {
    [[self afnetworingManager].operationQueue cancelAllOperations];
}

+ (void)cleanAllCache {
    YYCache *cache = [self yyCache];
    [cache removeAllObjects];
}

+ (UIImage *)compressImage:(UIImage *)sourceImage {
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetHeight = (sourceImage.size.width / width) * height;
    UIGraphicsBeginImageContext(CGSizeMake(sourceImage.size.width, targetHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.width)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (YYCache *)yyCache {
    YYCache *cache = [YYCache cacheWithName:kNetworkingCache];
    return cache;
}

@end
