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

const NSString *SQL_TEXT = @"TEXT"; //文本
const NSString *SQL_INTEGER = @"INTEGER"; //int long integer ...
const NSString *SQL_REAL = @"REAL"; //浮点
const NSString *SQL_BLOB = @"BLOB"; //data


const NSString *createTablePrifix = @"create table if not exists";
const NSString *createTableIdString = @"(id integer primary key autoincrement";
const NSString *seletecPrifix = @"select * from";

@interface SSDBTableManager()

@property(nonatomic,strong)FMDatabaseQueue *dbq;
@property(nonatomic,copy)NSString *tableName;

@end

@implementation SSDBTableManager

+ (instancetype)sharedManagerBy:(SSBDBaseModel *)model
{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[dbName copy]];
    NSLog(@"fileName = %@",filePath);
    SSDBTableManager *manager = [SSDBTableManager new];
    manager.dbq = [FMDatabaseQueue databaseQueueWithPath:filePath];
    [manager createTableByModel:model result:nil];
    return manager;
}


- (void)createTableByModel:(SSBDBaseModel *)model result:(resultBlock)resultBlock
{
    self.tableName = NSStringFromClass([model class]);
    NSDictionary *keyTypeDic = [self change2CreateDicFromItemModel:model];
    NSString *keyTypeStr = [self changeDic:keyTypeDic toStringByFormatString:@", %@ %@"];
    NSMutableString *sqlString = [NSMutableString stringWithFormat:@"%@ %@ %@%@",createTablePrifix,self.tableName,createTableIdString,keyTypeStr];
    [sqlString appendString:@");"];
    [self.dbq inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:sqlString];
        if (resultBlock) {
            resultBlock(nil,result);
        }
        NSLog(@"表是否创建成功%d",result);
    }];
}


- (BOOL)insertModel:(SSBDBaseModel *)model result:(resultBlock)rb
{
    NSString *insertStr = [self insertStringFromeModel:model];
    NSDictionary *kVDic = [self change2DicFromItemModel:model];
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
    return NO;
}

- (BOOL)insertModels:(NSArray<SSBDBaseModel *> *)models result:(resultBlock)rb
{
    return NO;
}

- (BOOL)deleteItemKey:(NSString *)key
                value:(NSString *)value
            fromTable:(NSString *)tableName
{
    return NO;
}

- (BOOL)deleteItemWhereKey:(NSString *)key
                 threshold:(NSString *)threshold
                 fromTable:(NSString *)tableName
{
    return NO;
}

- (BOOL)deleteAllFromTable:(NSString *)tableName
{
    return NO;
}

- (BOOL)updateKey:(NSString *)key value:(NSString *)value atTable:(NSString *)tableName
{
    return NO;
}
- (BOOL)updateItems:(NSArray<SSBDBaseModel *> *)items atTable:(NSString *)tableName
{
    return NO;
}


- (NSArray *)searchAllItemFrom:(NSString *)tableName
{
    return @[];
}

- (NSArray *)searchItemByKey:(NSString *)key
                   threshold:(NSString *)threshold
                   fromTable:(NSString *)tableName
{
    return @[];
}



#pragma mark - runtime method
/**
 模型转成键值对。用来update数据表

 @param model 模型
 @return key-value字典
 */
- (NSDictionary *)change2DicFromItemModel:(SSBDBaseModel *)model
{
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    for (int i = 0; i < outCount; i++) {

        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];


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

 @param model 模型
 @return 集合字典
 */
- (NSDictionary *)change2CreateDicFromItemModel:(SSBDBaseModel *)model
{

    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:0];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
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

- (NSString *)insertStringFromeModel:(SSBDBaseModel *)model
{
    NSMutableString *finalString = [NSMutableString stringWithFormat:@"insert into %@ (",NSStringFromClass([model class])];
    NSDictionary *kVDic = [self change2DicFromItemModel:model];
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
