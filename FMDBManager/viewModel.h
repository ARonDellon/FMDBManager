//
//  viewModel.h
//  FMDBManager
//
//  Created by wangweiyi on 2018/6/14.
//  Copyright © 2018年 demo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface viewModel : NSObject



- (void)loadMainListItems:(NSDictionary *)params success:(void(^)(id result))success failure:(void(^)(id result))failure;


@end
