//
//  SSDBManager.h
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/11.
//  Copyright © 2018年 demo. All rights reserved.
//

#import "FMDB.h"
#import "SSBDBaseModel.h"
#import <Foundation/Foundation.h>

const NSString *SQL_TEXT = @"TEXT"; //文本
const NSString *SQL_INTEGER = @"INTEGER"; //int long integer ...
const NSString *SQL_REAL = @"REAL"; //浮点
const NSString *SQL_BLOB = @"BLOB"; //data

typedef void(^resultBlock)(FMResultSet *result, BOOL opIsSuccess);

@interface SSDBTableManager : NSObject

@property(nonatomic,strong,readonly)FMDatabaseQueue *dbq;
@property(nonatomic,copy,readonly)NSString *modelName;

/**
 通过model初始化数据库表

 @param model model
 @return 根据model生成表的数据库管理对象
 */
+ (instancetype)sharedManagerBy:(id<SSBDBaseModeDelegate>)model;

- (void)insertModel:(id<SSBDBaseModeDelegate>)model result:(resultBlock)rb;

- (void)insertModels:(NSArray<id<SSBDBaseModeDelegate>> *)models result:(resultBlock)rb;

- (void)deleteModel:(id<SSBDBaseModeDelegate>)model result:(resultBlock)rb;

- (void)searchAllItemResult:(resultBlock)rb;

- (void)updateItem:(id<SSBDBaseModeDelegate>)model atKey:(NSString *)key result:(resultBlock)rb;

- (void)deleteTableResult:(resultBlock)rb;

- (NSDictionary *)changeModel2kVDic:(NSObject<SSBDBaseModeDelegate> *)model;

- (NSDictionary *)getModelTypeDic;
@end






