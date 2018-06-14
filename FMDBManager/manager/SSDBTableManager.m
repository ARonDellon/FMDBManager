//
//  SSDBManager.m
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/11.
//  Copyright © 2018年 demo. All rights reserved.
//
#import "SSDBTableManager.h"
#import <objc/runtime.h>
#import <sqlite3.h>

const NSString *dbName = @"soso.sqlite";

const NSString *createTablePrefix = @"create table if not exists";
const NSString *createTableIdString = @"(id integer primary key autoincrement";
const NSString *seletecPrefix = @"select * from";
const NSString *deletePrefix = @"delete from";

@interface SSDBTableManager()

@property(nonatomic,strong)FMDatabaseQueue *dbq;
@property(nonatomic,copy)NSString *modelName;
@property(nonatomic,strong)id modelClass;

@end

@implementation SSDBTableManager

+ (instancetype)sharedManagerBy:(id<SSBDBaseModeDelegate>)model
{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[dbName copy]];
    NSLog(@"fileName = %@",filePath);
    SSDBTableManager *manager = [SSDBTableManager new];
    manager.dbq = [FMDatabaseQueue databaseQueueWithPath:filePath];
    [manager createTableByModel:model result:nil];
    return manager;
}


- (void)createTableByModel:(id<SSBDBaseModeDelegate>)model result:(resultBlock)rb
{
    self.modelName = NSStringFromClass([model class]);
    NSDictionary *keyTypeDic = [self getModelTypeDic];
    NSString *keyTypeStr = [self changeDic:keyTypeDic toStringByFormatString:@", %@ %@"];
    NSMutableString *sqlString = [NSMutableString stringWithFormat:@"%@ %@ %@%@",createTablePrefix,self.modelName,createTableIdString,keyTypeStr];
    [sqlString appendString:@");"];
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:sqlString];
        if (rb) {
            rb(nil,result);
        }
        NSLog(@"表是否创建成功%d",result);
    }];
}


- (void)insertModel:(id<SSBDBaseModeDelegate>)model result:(resultBlock)rb
{
    NSString *insertStr = [self insertString:model];
    NSDictionary *kVDic = [self changeModel2kVDic:model];
    NSMutableArray *argArr = [NSMutableArray arrayWithCapacity:0];
    for (NSString *key in kVDic) {
        [argArr addObject:kVDic[key]];
    }
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:insertStr withArgumentsInArray:argArr];
        if (rb) {
            rb(nil,result);
        }
    }];
}

- (void)insertModels:(NSArray<id<SSBDBaseModeDelegate>> *)models result:(resultBlock)rb
{
    for (SSBDBaseModel *model in models) {
        [self insertModel:model result:rb];
    }
}

- (void)deleteModel:(id<SSBDBaseModeDelegate>)model result:(resultBlock)rb
{
    NSNumber * itemID = [NSNumber numberWithUnsignedInteger:[model itemID]];
    NSString *sqlStr = [NSString stringWithFormat:@"%@ %@ where id = %@",[deletePrefix copy],self.modelName,itemID.stringValue];
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:sqlStr];
        if (rb) {
            rb(nil,result);
        }
    }];
}

- (BOOL)deleteItemWhereKey:(NSString *)key
                 threshold:(NSString *)threshold
                 fromTable:(NSString *)tableName
{
    return NO;
}

- (void)deleteTableResult:(resultBlock)rb
{
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        if ([db tableExists:self.modelName]) {
            BOOL result = [db executeUpdate:[NSString stringWithFormat:@"drop table %@",self.modelName]];
            if (rb) {
                rb(nil,result);
            }
        }
    }];
}

- (void)updateItem:(id<SSBDBaseModeDelegate>)model atKey:(NSString *)key result:(resultBlock)rb
{
    NSDictionary *kVDic = [self changeModel2kVDic:model];
    id value = kVDic[key];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set %@ = ? where id = %lu",self.modelName,key,(unsigned long)[model itemID]];
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:sqlStr withArgumentsInArray:@[value]];
        if (rb) {
            rb(nil,result);
        }
    }];
}



- (void)searchAllItemResult:(resultBlock)rb
{
    [self searchItemByThresholdArr:nil limit:0 orderKey:nil orderBy:NO result:rb];
}


//    select * from table where a>3 and b=5 and c<7 order by c DESC limit 10

- (void)searchItemByThresholdArr:(NSArray<NSString *> *)thresholdArr
                           limit:(NSInteger)limit
                        orderKey:(NSString *)orederKey
                         orderBy:(BOOL)isDESC
                          result:(resultBlock)rb
{
    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"select * from %@",self.modelName];
    if (thresholdArr.count > 0) {
        NSString *conditionStr = [thresholdArr componentsJoinedByString:@" and "];
        [sqlStr appendFormat:@" where %@",conditionStr];
    }

    if (orederKey != nil) {
        [sqlStr appendFormat:@" order by %@ %@",orederKey,isDESC?@"DESC":@"ASC"];
    }

    if (limit > 0) {
        [sqlStr appendFormat:@" limit %ld",limit];
    }

    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet * result = [db executeQuery:sqlStr];
        if (rb) {
            rb(result,nil);
        }
    }];

}



#pragma mark - runtime method

/**
 模型转成字典

 @param model 模型
 @return 字典
 */
- (NSDictionary *)changeModel2kVDic:(NSObject<SSBDBaseModeDelegate> *)model
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(NSClassFromString(self.modelName), &outCount);
    for (int i = 0; i < outCount; i++) {

        NSString *name = [NSString stringWithCString:property_getName(properties[i])
                                            encoding:NSUTF8StringEncoding];
        
        NSString *value = [model valueForKey:name];
        if (value) {
            [mDic setObject:value forKey:name];
        }

    }
    free(properties);

    return mDic;
}


/**
 model转换成key和type的Dic。用来创建表

 @return 集合字典
 */
- (NSDictionary *)getModelTypeDic
{

    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(NSClassFromString(self.modelName), &outCount);
    for (int i = 0; i < outCount; i++) {

        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];


        NSString *type = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];

        id value = [self propertTypeConvert:type];
        if (value) {
            [mDic setObject:value forKey:name];
        }

    }
    free(properties);

    return mDic;
}


/**
 类型转换成sqlite中的类型

 @param typeStr 类型名
 @return sqlite类型名
 */
- (NSString *)propertTypeConvert:(NSString *)typeStr
{
    NSString *resultStr = nil;
    if ([typeStr hasPrefix:@"T@\"NSString\""]) {
        resultStr = [SQL_TEXT copy];
    } else if ([typeStr hasPrefix:@"T@\"NSData\""]) {
        resultStr = [SQL_BLOB copy];
    } else if ([typeStr hasPrefix:@"Ti"]||[typeStr hasPrefix:@"TI"]||[typeStr hasPrefix:@"Ts"]||[typeStr hasPrefix:@"TS"]||[typeStr hasPrefix:@"T@\"NSNumber\""]||[typeStr hasPrefix:@"TB"]||[typeStr hasPrefix:@"Tq"]||[typeStr hasPrefix:@"TQ"]) {
        resultStr = [SQL_INTEGER copy];
    } else if ([typeStr hasPrefix:@"Tf"] || [typeStr hasPrefix:@"Td"]){
        resultStr= [SQL_REAL copy];
    }

    return resultStr;
}


/**
 获取表中的所有key

 @param tableName 表名
 @param db 数据库
 @return key数组
 */
- (NSArray *)getColumnArr:(NSString *)tableName db:(FMDatabase *)db
{
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];

    FMResultSet *resultSet = [db getTableSchema:tableName];

    while ([resultSet next]) {
        [mArr addObject:[resultSet stringForColumn:@"name"]];
    }

    return mArr;
}


/**
 按照format规则拼接dic内容

 @param dic dic
 @param format 规则 比如 @“, %@ %@”
 @return 拼接好的字符串 比如 @“, A int, B char, C float”
 */
- (NSString *)changeDic:(NSDictionary *)dic toStringByFormatString:(NSString *)format
{
    NSMutableString *result = [NSMutableString stringWithFormat:@""];
    for (NSString * key in dic.keyEnumerator) {
        [result appendString:[NSString stringWithFormat:format,key,dic[key]]];
    }
    return result;
}

- (NSString *)insertString:(id<SSBDBaseModeDelegate>)model
{
    NSMutableString *finalString = [NSMutableString stringWithFormat:@"insert into %@ (",NSStringFromClass([self.modelName class])];
    NSDictionary *kVDic = [self changeModel2kVDic:model];
    NSMutableString *tempString = [NSMutableString stringWithCapacity:0];

    for (NSString *key in kVDic.allKeys) {
        [finalString appendString:[NSString stringWithFormat:@"%@,",key]];
        [tempString appendString:@"?,"];
    }
    [finalString deleteCharactersInRange:NSMakeRange(finalString.length-1, 1)];
    [tempString deleteCharactersInRange:NSMakeRange(tempString.length-1, 1)];
    [finalString appendFormat:@") value (%@)",tempString];

    return finalString;
}






@end
