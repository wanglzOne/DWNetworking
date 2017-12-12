//
//  AppDelegate.m
//  DWNetworkingDemo
//
//  Created by dawng on 2017/8/29.
//  Copyright © 2017年 CoderDwang. All rights reserved.
//

#import "AppDelegate.h"
#import "DWNetworking.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DWNetworking setBaseUrlString:@"基础url"];
    [DWNetworking setNotAutoUseCacheUrls:@[@"不使用自动缓存的url"]];
    [DWNetworking setReturnCacheHiddenError:@"返回缓存数据时是否隐藏error信息/默认不隐藏"];
    [DWNetworking setAutoCleanCacheSize:1024];
    [DWNetworking networkEnvironmentChange:^(DWNetworkReachabilityStatus reachabilityStatus) {
        NSLog(@"%ld", reachabilityStatus);
    }];
    return YES;
}

@end
