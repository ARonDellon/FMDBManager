//
//  SSDBAdaptor.m
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/13.
//  Copyright © 2018年 demo. All rights reserved.
//

#import "SSDBAdaptor.h"

@interface SSDBAdaptor()

@property(nonatomic,strong)SSDBTableManager *manager;
@property(nonatomic,copy)NSString *modelClass;

@end

@implementation SSDBAdaptor

- (instancetype)initWithModel:(SSDBDemoModel *)model
{
    if (self = [super init]) {
        self.manager = [SSDBTableManager sharedManagerBy:model];
        self.modelClass = NSStringFromClass([model class]);
    }
    return self;
}

- (void)saveModel:(NSArray<SSDBDemoModel *> *)models
{
    [self.manager insertModels:models result:^(FMResultSet *result, BOOL opIsSuccess) {

    }];

}
- (void)getModelList:(void (^)(NSArray<SSDBDemoModel *> *, BOOL))resultBlock
{
//    [self.manager searchAllItemFrom:(SSDBDemoModel *)NSClassFromString(self.modelClass)
//                             result:^(FMResultSet *result, BOOL opIsSuccess) {
//                                 
//                             }];
}
- (void)changeModel:(SSDBDemoModel *)model key:(NSString *)key value:(id)value
{

}

@end
