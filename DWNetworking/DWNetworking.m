//
//  DWNetworking.m
//  DWNetworking
//
//  Created by dawng on 2017/8/28.
//  Copyright © 2017年 CoderDwang. All rights reserved.
//

#import "DWNetworking.h"
#import "AFNetworking.h"
#import "YYCache.h"

/** 基础url */
static NSString *_networking_baseUrl = nil;
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
/** 设置不使用缓存的url */
static NSArray<NSString *> *_networkingNotAutoUseCache = nil;
static DWNetworkRequestType _networkingRequestType = DWRequestTypePlainText;
static DWNetworkResponseType _networkingResponseType = DWResponseTypeJSON;

/** 设置缓存文件夹 */
static NSString *kNetworkingCache = @"kNetworkingCacheYYPath";

@implementation DWNetworking

+ (void)setBaseUrlString:(NSString *)url {
    _networking_baseUrl = url;
}

+ (NSString *)baseUrlString {
    return _networking_baseUrl;
}

+ (void)setConfigRequestType:(DWNetworkRequestType)requestType
                responseType:(DWNetworkResponseType)responseType {
    _networkingRequestType = requestType;
    _networkingResponseType = responseType;
}

+ (void)setHttpHeaderConfig:(NSDictionary *)config {
    _networkingHttpHeaderConfig = config;
}

+ (void)setTimeoutInterval:(NSTimeInterval)time {
    _networkingTimeout = time;
}

+ (void)setMaxConcurrentOperationCount:(NSInteger)count {
    _networkingMaxConcurrentCount = count;
}

+ (void)setAutoUseCache:(BOOL)cache {
    _networkingAutoUseCache = cache;
}

+ (void)getUrlString:(NSString *)url
              params:(NSDictionary *)params
      resultCallBack:(void(^)(id success, NSError *error))resultCallBack {
    AFHTTPSessionManager *manager = [self afnetworingManager];
    YYCache *cache = [self yyCache];
    __weak __typeof(self)weakSelf = self;
    [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        resultCallBack(responseObject, nil);
        if (![[weakSelf notAutoUseCacheUrl] containsObject:url]) {
            if ([cache containsObjectForKey:url]) {
                [cache removeObjectForKey:url];
            }
            [cache setObject:responseObject forKey:url];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([cache containsObjectForKey:url]) {
            resultCallBack([cache objectForKey:url], nil);
        }else {
            resultCallBack(nil, error);
        }
    }];
}

+ (void)postUrlString:(NSString *)url
               params:(NSDictionary *)params
       resultCallBack:(void(^)(id success, NSError *error))resultCallBack {
    AFHTTPSessionManager *manager = [self afnetworingManager];
    YYCache *cache = [self yyCache];
    __weak __typeof(self)weakSelf = self;
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        resultCallBack(responseObject, nil);
        if (![[weakSelf notAutoUseCacheUrl] containsObject:url]) {
            if ([cache containsObjectForKey:url]) {
                [cache removeObjectForKey:url];
            }
            [cache setObject:responseObject forKey:url];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([cache containsObjectForKey:url]) {
            resultCallBack([cache objectForKey:url], nil);
        }else {
            resultCallBack(nil, error);
        }
    }];
}

+ (void)uploadWithImage:(UIImage *)image
                    url:(NSString *)url
               fileName:(NSString *)fileName
                   name:(NSString *)name
              imageType:(NSString *)imageType
             parameters:(NSDictionary *)parameters
               progress:(void(^)(NSProgress *progress))progress
         resultCallBack:(void(^)(id success, NSError *error))resultCallBack {
    AFHTTPSessionManager *manager = [self afnetworingManager];
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = UIImageJPEGRepresentation([self compressImage:image], 1);
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:imageType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        resultCallBack(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        resultCallBack(nil, error);
    }];
}

+ (void)uploadWithImages:(NSArray<UIImage *>*)images
                     url:(NSString *)url
               fileNames:(NSArray<NSString *> *)fileNames
                   names:(NSArray<NSString *> *)names
               imageType:(NSString *)imageType
              parameters:(NSDictionary *)parameters
                progress:(void(^)(NSProgress *progress))progress
          resultCallBack:(void(^)(id success, NSError *error))resultCallBack {
    AFHTTPSessionManager *manager = [self afnetworingManager];
    [manager POST:[NSString stringWithFormat:@"%@%@", [self baseUrlString], url] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i = 0; i < images.count; i ++) {
            NSData *data = UIImageJPEGRepresentation([self compressImage:images[i]], 1);
            [formData appendPartWithFileData:data name:names[i] fileName:fileNames[i] mimeType:imageType];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseData) {
        resultCallBack(responseData, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        resultCallBack(nil, error);
    }];
}

+ (void)cancelAllTask {
    [[self afnetworingManager].operationQueue cancelAllOperations];
}

+ (long long)getCachesSize {
    NSFileManager *manager = [NSFileManager defaultManager];
    long long size = 0;
    if ([manager fileExistsAtPath:[self getCachesPath]]) {
        // 目录下的文件计算大小
        NSArray *childrenFile = [manager subpathsAtPath:[self getCachesPath]];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [[self getCachesPath] stringByAppendingPathComponent:fileName];
            size += [manager attributesOfItemAtPath:absolutePath error:nil].fileSize;
        }
    }
    return size/1024;
}

+ (void)cleanAllCache {
    [self cleanCaches:[self getCachesPath]];
}

+ (void)setAutoCleanCacheSize:(long long)size {
    if (size <= [self getCachesSize]) {
        [self cleanAllCache];
    }
}

+ (void)setNotAutoUseCacheUrls:(NSArray<NSString *> *)urls {
    _networkingNotAutoUseCache = urls;
}

+ (NSArray <NSString *> *)notAutoUseCacheUrl {
    return _networkingNotAutoUseCache;
}

+ (void)networkEnvironmentChange:(void(^)(DWNetworkReachabilityStatus reachabilityStatus))reachabilityStatus {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                reachabilityStatus(DWNetworkReachabilityStatusUnknown);
                break;
            case AFNetworkReachabilityStatusNotReachable:
                reachabilityStatus(DWNetworkReachabilityStatusNotReachable);
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                reachabilityStatus(DWNetworkReachabilityStatusReachableViaWWAN);
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                reachabilityStatus(DWNetworkReachabilityStatusReachableViaWiFi);
                break;
            default:
                break;
        }
    }];
    
}

+ (AFHTTPSessionManager *)afnetworingManager {
    @synchronized (self) {
        AFHTTPSessionManager *manager = nil;
        if ([self baseUrlString]) {
            manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[self baseUrlString]]];
        }else {
            manager = [AFHTTPSessionManager manager];
        }
        switch (_networkingRequestType) {
            case DWRequestTypeJSON:
                 manager.requestSerializer = [AFJSONRequestSerializer serializer];
                break;
            case DWRequestTypePlainText:
                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                break;
            default:
                break;
        }
        switch (_networkingResponseType) {
            case DWResponseTypeJSON:
                manager.responseSerializer = [AFJSONResponseSerializer serializer];
                break;
            case DWBResponseTypeXML:
                manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
                break;
            case DWBResponseTypeData:
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            default:
                break;
        }
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

+ (void)cleanCaches:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}

+ (NSString *)getCachesPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,YES);
    NSString *cachesDir = [paths lastObject];
    return cachesDir;
}


@end
