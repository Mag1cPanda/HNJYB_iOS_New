//
//  AFNetWorkServiceCar.h
//  LongriseHttpManageIOS
//
//  Created by 程三 on 16/5/18.
//  Copyright © 2016年 程三. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetWorkService.h"

@interface AFNetWorkServiceCar : AFNetWorkService

@property(nonatomic,assign)BOOL showNotice;

-(void)requestWithServiceIP2:(NSString *)serviceIP ServiceName:(NSString *)serviceName params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod resultIsDictionary:(BOOL)resultIsDictionary completeBlock:(RequestCompelete2)block2;

#pragma mark 增加方法，可以设置超时时间
-(void)requestWithServiceIP3:(NSString *)serviceIP ServiceName:(NSString *)serviceName params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod resultIsDictionary:(BOOL)resultIsDictionary completeBlock:(RequestCompelete2)block2 timeOut:(float)time;

+ (AFNetWorkServiceCar *)getAFNetWorkServiceCar;

@end
