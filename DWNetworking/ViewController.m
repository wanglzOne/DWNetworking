//
//  ViewController.m
//  DWNetworking
//
//  Created by dawng on 2017/8/28.
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
    [DWNetworking postUrlString:@"Mapp/Pub/getBannerList" params:@{@"position":@"13"} resultCallBack:^(id success, NSError *error) {
        NSLog(@"%@--->%lld", success, [DWNetworking getCachesSize]);
    }];
}
- (IBAction)cleanAllCache:(id)sender {
    NSLog(@"%@", [DWNetworking getCachesPath]);
    [DWNetworking cleanAllCache];
    NSLog(@"缓存:%lldKB", [DWNetworking getCachesSize]);
}

@end
