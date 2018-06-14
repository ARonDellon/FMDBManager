//
//  viewModel.m
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/14.
//  Copyright © 2018年 demo. All rights reserved.
//

#import "viewModel.h"
#import "SSDBTableManager.h"
#import "SSDBTableManager+Model.h"

@interface viewModel()

@property(nonatomic,strong)SSDBTableManager *dbManager;
@property(nonatomic,strong)NSMutableArray *dataArr;

@end

@implementation viewModel

- (instancetype)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.dbManager = [SSDBTableManager sharedManagerBy:[SSBDBaseModel new]];
    self.dataArr = [NSMutableArray arrayWithCapacity:0];
    [self createFakeData];
}

- (void)createFakeData
{
    for (int i = 0 ; i < 50 ; i ++) {
        SSBDBaseModel *model = [SSBDBaseModel new];
        model.age = i;
        model.name = [NSString stringWithFormat:@"我是%d",i];
        model.timeStamp = @"5891372189";
        [self.dbManager insertModel:model
                             result:^(FMResultSet *result, BOOL opIsSuccess) {
                                 NSLog(@"%d",opIsSuccess);
                             }];
    }
}

- (void)loadMainListItems:(NSDictionary *)params
                  success:(void(^)(id result))success
                  failure:(void(^)(id result))failure
{
    
    [self.dbManager searchItemByThresholdArr:@[@"age<20"]
                                       limit:10
                                    orderKey:@"age"
                                     orderBy:YES
                                      result:^(FMResultSet *result, BOOL opIsSuccess) {
                                          self.dataArr = [NSMutableArray arrayWithArray:[self.dbManager changeFromResult:result]];
                                          success(self.dataArr);
                                      }];

}

- (void)deleteAtIndex:(NSUInteger)index
{

}

@end
