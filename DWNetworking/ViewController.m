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
    NSLog(@"%@", [DWNetworking notAutoUseCacheUrl]);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [DWNetworking postUrlString:@"Mapp/Pub/getBannerList" params:@{@"position":@"13"} success:^(id response) {
        NSLog(@"%@", response);
    } fail:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
- (IBAction)cleanAllCache:(id)sender {
    [DWNetworking cleanAllCache];
}

@end
