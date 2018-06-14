//
//  SSBDBaseModel.m
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/11.
//  Copyright © 2018年 demo. All rights reserved.
//

#import "SSBDBaseModel.h"

@interface SSBDBaseModel()

@property(nonatomic,assign)NSUInteger itemID;

@end


@implementation SSBDBaseModel

- (NSUInteger)itemID
{
    if (!_itemID) {
        _itemID = 0;
    }
    return _itemID;
}

-(void)setItemId:(NSUInteger)itemID
{
    self.itemID = itemID;
}

@end
