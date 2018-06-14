//
//  SSDBAdaptor.h
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/13.
//  Copyright © 2018年 demo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSDBTableManager.h"
#import "SSDBDemoModel.h"

@interface SSDBAdaptor : NSObject

- (instancetype)initWithModel:(SSDBDemoModel *)model;

- (void)saveModel:(NSArray<SSDBDemoModel *> *)models;
- (void)getModelList:(void (^)(NSArray<SSDBDemoModel *> *, BOOL))resultBlock;
- (void)changeModel:(SSDBDemoModel *)model key:(NSString *)key value:(id)value;


@end
