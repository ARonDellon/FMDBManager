//
//  SSDBDemoModel.h
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/13.
//  Copyright © 2018年 demo. All rights reserved.
//

#import "SSBDBaseModel.h"

@interface SSDBDemoModel : SSBDBaseModel

@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)NSUInteger age;
@property(nonatomic,copy)NSString *timeStamp;

@end
