//
//  SSDBTableManager+Model.h
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/13.
//  Copyright © 2018年 demo. All rights reserved.
//

#import "SSDBTableManager.h"

@interface SSDBTableManager (Model)

- (NSArray *)changeFromResult:(FMResultSet *)result;

@end
