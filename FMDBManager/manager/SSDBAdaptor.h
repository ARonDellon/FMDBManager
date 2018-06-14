//
//  SSDBAdaptor.h
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/13.
//  Copyright © 2018年 demo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSDBTableManager.h"


//@protocol SSDBAdaptorDelegate<NSObject>
//
//
//
//@end

@interface SSDBAdaptor : NSObject

@property(nonatomic,strong,readonly)SSDBTableManager *tableManager;

//- (instancetype)initWithModel:(NSObject<SSBDBaseModeDelegate> *)model delegate:(id<SSDBAdaptorDelegate>)delegate;
//
//- (void)getModelListByLastModel:(NSObject<SSBDBaseModeDelegate> *)model
//                           page:(NSUInteger)page
//                           size:(NSUInteger)size;
//- (void)changeModel:(NSObject<SSBDBaseModeDelegate> *)model;
//- (void)deleteModel:(NSObject<SSBDBaseModeDelegate> *)model;

@end
