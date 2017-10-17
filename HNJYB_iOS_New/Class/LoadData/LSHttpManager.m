//
//  LSHttpManager.m
//  CarRecord_Longrise
//
//  Created by Mag1cPanda on 16/6/8.
//  Copyright © 2016年 Mag1cPanda. All rights reserved.
//

#import "LSHttpManager.h"

@implementation LSHttpManager
+ (void)requestUrl:(NSString *)urlString serviceName:(NSString *)serviceName parameters:(NSMutableDictionary *)parameters complete:(CompleteBlock)block
{
    [AFNetWorkServiceCar getAFNetWorkServiceCar].showNotice = NO;

    [[AFNetWorkServiceCar getAFNetWorkServiceCar] requestWithServiceIP2:urlString ServiceName:serviceName params:parameters httpMethod:@"POST" resultIsDictionary:YES completeBlock:^(id result, ResultType resultType) {

        if (result) {
            block(result, resultType);
        }
        
        else {
//            block(result, resultType);
            NSLog(@"LSHttpManager ~ 无法访问服务器");
        }

    }];
}



@end
