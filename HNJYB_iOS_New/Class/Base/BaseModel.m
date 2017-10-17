//
//  BaseModel.m
//  HNJYB_iOS_New
//
//  Created by panshen on 2017/10/17.
//  Copyright © 2017年 panshen. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"forUndefinedKey -> %@",key);
}

-(instancetype)initWithDict:(NSDictionary *)dic{
    [self setValuesForKeysWithDictionary:dic];
    return self;
}

@end
