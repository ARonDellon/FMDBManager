//
//  SSDBTableManager+Model.m
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/13.
//  Copyright © 2018年 demo. All rights reserved.
//

#import "SSDBTableManager+Model.h"

@implementation SSDBTableManager (Model)

- (NSArray *)changeFromResult:(FMResultSet *)result
{
    NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *tableTitleArr = [NSMutableArray arrayWithCapacity:0];//表头字段数组
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db getTableSchema:self.modelName];
        while ([resultSet next]) {
            [tableTitleArr addObject:[resultSet stringForColumn:@"name"]];
        }
    }];

    NSDictionary *modelTypeDic = [self getModelTypeDic];

    while ([result next]) {
        NSObject *item = [[NSClassFromString(self.modelName) class] new];

        for (NSString *name in tableTitleArr) {
            if ([modelTypeDic[name] isEqualToString:[SQL_TEXT copy]]) {
                id value = [result stringForColumn:name];
                if (value)
                    [item setValue:value forKey:name];
            } else if ([modelTypeDic[name] isEqualToString:[SQL_INTEGER copy]]) {
                [item setValue:@([result longLongIntForColumn:name]) forKey:name];
            } else if ([modelTypeDic[name] isEqualToString:[SQL_REAL copy]]) {
                [item setValue:[NSNumber numberWithDouble:[result doubleForColumn:name]] forKey:name];
            } else if ([modelTypeDic[name] isEqualToString:[SQL_BLOB copy]]) {
                id value = [result dataForColumn:name];
                if (value)
                    [item setValue:value forKey:name];
            }
        }
        [resultArr addObject:item];
    }
    return resultArr;
}

@end
