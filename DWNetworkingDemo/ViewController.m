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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [DWNetworking postUrlString:@"url" params:nil resultCallBack:^(id success, NSError *error) {
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
