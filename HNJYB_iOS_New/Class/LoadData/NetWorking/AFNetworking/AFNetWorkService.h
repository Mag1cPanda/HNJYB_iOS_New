//
//  AFNetWorkService.h
//  TBRJL
//
//  Created by zzy on 16/01/16.
//  Copyright (c) 2016年 zzy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequestInfo.h"
#import <UIKit/UIKit.h>

//请求类型Key
#define REQUEST_TYPE_KEY_NAME @"requestTypeKeyName"
//版本key
#define VERSION_KEY_NAME @"versionKeyName"
//IP名称
#define IP_KEY_NAME @"ipKeyName"
//服务名称
#define SERVICENAME_KEY_NAME @"serviceNameKeyName"
//参数名称
#define PARAMBEAN_KEY_NAME @"paramBeanKeyName"
//用户Session过期标志符数组
#define SESSION_TIMEOUT_KEY_NAME @"sessionTimeOutKeyName"
//用户被挤掉标志符数组
#define LOGINOUT_KEY_NAME @"loginOutKeyName"

//返回类型
typedef NS_ENUM(NSInteger,ResultType)
{
    UnknownNet = -1,//没有网络
    Failure = 0,//失败
    Success = 1,//成功
};

typedef void(^ProgressBlock)(float progress);
typedef void(^RequestCompelete)(id result);
typedef void(^RequestCompelete2) (id result,ResultType resultType);

@interface AFNetWorkService : NSObject
{
    ProgressBlock myProgressBlock;
}

@property(nonatomic,retain)UIAlertView *alert;
@property(nonatomic,assign)ResultType resultType;
@property(nonatomic,retain)id result;
//设置获取cookID的服务参数对象
@property(nonatomic,retain)HttpRequestInfo *requestInfo;
//版本
@property(nonatomic,copy)NSString *versionStr;
//调用登录次数，防止无限循环
@property(nonatomic,assign)int count;
//用户Session过期标志符数组
@property(nonatomic,retain)NSArray *sessionTimeOutArray;
//用户被挤掉标志符数组
@property(nonatomic,retain)NSArray *loginOutArray;

-(void)requestWithServiceIP:(NSString *) serviceIP ServiceName:(NSString *)serviceName
                       params:(NSMutableDictionary *)params
                       httpMethod:(NSString *)httpMethod
                       resultIsDictionary:(BOOL)resultIsDictionary
                       completeBlock:(RequestCompelete)block;

- (void)requestWithServiceIP2:(NSString *) serviceIP ServiceName:(NSString *)serviceName
                      params:(NSMutableDictionary *)params
                      httpMethod:(NSString *)httpMethod
                      resultIsDictionary:(BOOL)resultIsDictionary
                      completeBlock:(RequestCompelete2)block2;

/*
 mimeType的所有类型如下：
 
 text/plain（纯文本）
 text/html（HTML文档）
 application/xhtml+xml（XHTML文档）
 image/gif（GIF图像）
 image/jpeg（JPEG图像）【PHP中为：image/pjpeg】
 image/png（PNG图像）【PHP中为：image/x-png】
 video/mpeg（MPEG动画）
 application/octet-stream（任意的二进制数据）
 application/pdf（PDF文档）
 application/msword（Microsoft Word文件）
 message/rfc822（RFC 822形式）
 multipart/alternative（HTML邮件的HTML形式和纯文本形式，相同内容使用不同形式表示）
 application/x-www-form-urlencoded（使用HTTP的POST方法提交的表单）
 multipart/form-data（同上，但主要用于表单提交时伴随文件上传的场合）
 */
#pragma mark 文件上传，参数说明：上传路径/本地文件的完整路径/附带的参数(可以为空)/上传文件对应的Key/文件名称(如：xxxx.png)/上传的类型(如：image/png)/上传进度block/完成block
-(void)uploadUrl:(NSString *) serviceIP ServiceName:(NSString *)serviceName
                fileFullPath:(NSString *)fileFullpath
                params:(NSMutableDictionary *)params
                name:(NSString *)name
                fileName:(NSString *)fileName
                mimeType:(NSString *)mimeType
                progressBlock:(ProgressBlock)progressBlock
                completeBlock:(RequestCompelete)block;

#pragma mark 文件上传，参数说明：上传路径/nsdata对象/上传的文件类型(如：jpg)/附带的参数(可以为空)/上传文件对应的Key/上传的类型(如：image/png)/上传进度block/完成block
-(void)uploadUrl:(NSString *) serviceIP ServiceName:(NSString *)serviceName
            data:(NSData *)data fileType:(NSString *)fileType
            params:(NSMutableDictionary *)params
            name:(NSString *)name mimeType:(NSString *)mimeType
            progressBlock:(ProgressBlock)progressBlock
            completeBlock:(RequestCompelete)block;

-(NSString*)objectToJson:(NSObject *)object;

-(int)getNetState;

+ (AFNetWorkService *)getAFNetWorkService;

@end
