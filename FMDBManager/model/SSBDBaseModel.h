//
//  SSBDBaseModel.h
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/11.
//  Copyright © 2018年 demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSBDBaseModeDelegate<NSObject>

- (NSUInteger)itemID;
- (void)setItemId: (NSUInteger)itemID;

@end

@interface SSBDBaseModel : NSObject<SSBDBaseModeDelegate>


@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)NSUInteger age;
@property(nonatomic,copy)NSString *timeStamp;

@end
