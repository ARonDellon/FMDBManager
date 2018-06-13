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

typedef void(^resultBlock)(FMResultSet *result, BOOL opIsSuccess);

@interface SSDBTableManager : NSObject

- (BOOL)createTable:(NSString *)tableName model:(SSBDBaseModel *)model;

- (BOOL)insertModel:(SSBDBaseModel *)model toTable:(NSString *)tableName;
- (BOOL)insertModels:(NSArray<SSBDBaseModel *> *)models toTable:(NSString *)tableName;

- (BOOL)deleteItemKey:(NSString *)key
                value:(NSString *)value
            fromTable:(NSString *)tableName;

- (BOOL)deleteItemWhereKey:(NSString *)key
                 threshold:(NSString *)threshold
                 fromTable:(NSString *)tableName;

- (BOOL)deleteAllFromTable:(NSString *)tableName;

- (BOOL)updateKey:(NSString *)key value:(NSString *)value atTable:(NSString *)tableName;
- (BOOL)updateItems:(NSArray<SSBDBaseModel *> *)items atTable:(NSString *)tableName;


- (NSArray *)searchAllItemFrom:(NSString *)tableName;
- (NSArray *)searchItemByKey:(NSString *)key
                   threshold:(NSString *)threshold
                   fromTable:(NSString *)tableName;

@end






