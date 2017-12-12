//
//  ViewController.m
//  DWNetworkingDemo
//
//  Created by dawng on 2017/8/29.
//  Copyright © 2017年 CoderDwang. All rights reserved.
//

#import "ViewController.h"
#import "DWNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [DWNetworking postUrlString:@"当输入的请求地址为http://或者https://开头时,则不自动抛弃baseUrl" params:nil resultCallBack:^(id success, NSError *error, BOOL isCache) {
        if (!error) {
            NSLog(@"%@--->%lld", success, [DWNetworking getCachesSize]);
        }
    }];
}
- (IBAction)cleanAllCache:(id)sender {
    NSLog(@"%@", [DWNetworking getCachesPath]);
    [DWNetworking cleanAllCache];
    NSLog(@"缓存:%lldKB", [DWNetworking getCachesSize]);
}


@end
