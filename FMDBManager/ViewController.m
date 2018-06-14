//
//  ViewController.m
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/11.
//  Copyright © 2018年 demo. All rights reserved.
//

#import "ViewController.h"
#import "viewModel.h"
#import "SSBDBaseModel.h"

@interface ViewController ()

@property(nonatomic,strong)viewModel *vm;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.vm = [[viewModel alloc] init];
    [self.vm loadMainListItems:nil
                       success:^(id result) {

                           for (SSBDBaseModel * model in (NSArray *)result) {
                               NSLog(@"%u",model.age);
                           }
                       } failure:^(id result) {

                       }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
