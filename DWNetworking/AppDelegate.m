//
//  AppDelegate.m
//  DWNetworking
//
//  Created by dawng on 2017/8/28.
//  Copyright © 2017年 CoderDwang. All rights reserved.
//

#import "AppDelegate.h"
#import "DWNetworking.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DWNetworking setBaseUrlString:@"http://ceshi.sihaiinvest.com/"];
    [DWNetworking setNotAutoUseCacheUrls:@[@"Mapp/Pub/getBannerList"]];
    [DWNetworking networkEnvironmentChange:^(DWNetworkReachabilityStatus reachabilityStatus) {
        NSLog(@"%ld", reachabilityStatus);
    }];
    return YES;
}

@end
