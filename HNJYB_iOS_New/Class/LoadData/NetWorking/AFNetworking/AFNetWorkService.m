//
//  AFNetWorkService.m
//  TBRJL
//
//  Created by zzy on 16/01/16.
//  Copyright (c) 2016年 zzy. All rights reserved.
//

#import "AFNetWorkService.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLSessionManager.h"
#import "Reachability.h"
#import "AFURLResponseSerialization.h"
#import "FileManagerUtil.h"
#import "Util.h"

//登录通知
#define LoginForGetCookId @"LoginForGetCookId"

static AFNetWorkService *service;

@implementation AFNetWorkService

+ (AFNetWorkService *)getAFNetWorkService
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (!service)
        {
            service = [[AFNetWorkService alloc]init];
        }
    });
    return service;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        //初始化登录超时和登出信息
        _loginOutArray = [[NSUserDefaults standardUserDefaults] objectForKey:LOGINOUT_KEY_NAME];
        _sessionTimeOutArray = [[NSUserDefaults standardUserDefaults] objectForKey:SESSION_TIMEOUT_KEY_NAME];
        
        //初始化登录信息
        _requestInfo = [[HttpRequestInfo alloc] init];
        
        _versionStr = [[NSUserDefaults standardUserDefaults] objectForKey:VERSION_KEY_NAME];
        
        NSString *requestType = [[NSUserDefaults standardUserDefaults] objectForKey:REQUEST_TYPE_KEY_NAME];
        if(nil != requestType)
        {
            _requestInfo.httpMethod = requestType;
        }
        else
        {
            _requestInfo.httpMethod = @"POST";
        }
        
        NSString *serviceIP = [[NSUserDefaults standardUserDefaults] objectForKey:IP_KEY_NAME];
        if(nil != serviceIP)
        {
            _requestInfo.serviceIP =serviceIP;
        }
        
        NSString *serviceName = [[NSUserDefaults standardUserDefaults] objectForKey:SERVICENAME_KEY_NAME];
        if(nil != serviceName)
        {
            _requestInfo.serviceName = serviceName;
        }
        
        NSMutableDictionary *params = [[NSUserDefaults standardUserDefaults] objectForKey:PARAMBEAN_KEY_NAME];
        if(nil != params)
        {
            _requestInfo.params = params;
        }
        
        
    }
    return self;
}

- (void)requestWithServiceIP:(NSString *) serviceIP ServiceName:(NSString *)serviceName params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod resultIsDictionary:(BOOL)resultIsDictionary completeBlock:(RequestCompelete)block
{
    
    //拼接URL
    NSString *url = [NSString stringWithFormat:@"%@/%@/query",serviceIP,serviceName];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(!resultIsDictionary)
    {
        manager.responseSerializer = [AFCompoundResponseSerializer serializer];//响应
    }
    else
    {
        //manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    //设置相应内容类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/plain",@"text/javascript",nil];
    
    NSArray *array = [params allKeys];
    if(array.count != 0)
    {
        for (int  i = 0; i < array.count; i++)
        {
            NSString *key = array[i];
            id object = [params objectForKey:key];
            
            //判断参数类型
            if([object isKindOfClass:[NSNumber class]])
            {
                
            }
            else if([object isKindOfClass:[NSString class]])
            {
                
            }
            else if([object isKindOfClass:[NSData class]])
            {
                
            }
            else
            {
                NSString *string = [self objectToJson:object];
                if(nil != string)
                {
                    [params setValue:string forKey:key];
                }
            }
        }
    }
    
    //添加版本号到head里面
    [manager.requestSerializer setValue:(nil == self.versionStr?@"":self.versionStr) forHTTPHeaderField:@"App-Version"];
    
    //处理POST的参数
    NSComparisonResult compareRet = [httpMethod caseInsensitiveCompare:@"POST"];
    if(NSOrderedSame == compareRet)
    {
        [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            //判断cookID是否超时
            if(operation.responseString == nil ||
               [@"" isEqualToString:operation.responseString])
            {
                if(nil != self.requestInfo && operation.response.statusCode == 200)
                {
                    _count++;
                    if(self.count > 3)
                    {
                        self.count = 0;
                        block(nil);
                    }
                    else
                    {
                        //获取新的cookID
                        [self getCookIdSeviceIP:serviceIP ServiceName:serviceName params:params httpMethod:httpMethod resultIsDictionary:resultIsDictionary completeBlock:block];
                    }
                    
                    return;
                }
                
            }
            
            if(block != nil)
            {
                self.count = 0;
                block(resultIsDictionary ? responseObject:operation.responseString);
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            NSLog(@"调用服务出错(POST)");
            if(block != nil)
            {
                self.count = 0;
                block(nil);
            }
        }];
    }
    else
    {
        [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            //判断cookID是否超时
            if(operation.responseString == nil ||
               [@"" isEqualToString:operation.responseString])
            {
                if(nil !=self.requestInfo && operation.response.statusCode == 200)
                {
                    self.count++;
                    if(self.count > 3)
                    {
                        block(nil);
                        self.count = 0;
                    }
                    else
                    {
                        //获取新的cookID
                        [self getCookIdSeviceIP:serviceIP ServiceName:serviceName params:params httpMethod:httpMethod resultIsDictionary:resultIsDictionary completeBlock:block];
                    }
                    
                    return;
                }
                
            }
            
            if(block != nil)
            {
                self.count = 0;
                block(resultIsDictionary ? responseObject:operation.responseString);
                
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            NSLog(@"调用服务出错(GET)");
            if(block != nil)
            {
                self.count = 0;
                block(nil);
            }
        }];
    }
}

- (void)requestWithServiceIP2:(NSString *) serviceIP ServiceName:(NSString *)serviceName params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod resultIsDictionary:(BOOL)resultIsDictionary completeBlock:(RequestCompelete2)block2
{
    //判断网络
    if([self getNetState] == 0)
    {
        if(block2)
        {
            block2(nil,UnknownNet);
        }
        
        if(self.alert == nil)
        {
            self.alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有网络连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        }
        
        if(self.alert != nil)
        {
            [self.alert dismissWithClickedButtonIndex:0 animated:YES];
        }
        [self.alert show];
        
        return;
    }
    
    
    //拼接URL
    NSString *url = [NSString stringWithFormat:@"%@/%@/query",serviceIP,serviceName];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(!resultIsDictionary)
    {
        manager.responseSerializer = [AFCompoundResponseSerializer serializer];//响应
    }
    else
    {
        //manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    
    //设置相应内容类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/plain",@"text/javascript",nil];
    
    NSArray *array = [params allKeys];
    if(array.count != 0)
    {
        for (int  i = 0; i < array.count; i++)
        {
            NSString *key = array[i];
            id object = [params objectForKey:key];
            
            //判断参数类型
            if([object isKindOfClass:[NSNumber class]])
            {
                
            }
            else if([object isKindOfClass:[NSString class]])
            {
                
            }
            else if([object isKindOfClass:[NSData class]])
            {
                
            }
            else
            {
                NSString *string = [self objectToJson:object];
                if(nil != string)
                {
                    [params setValue:string forKey:key];
                }
            }
        }
    }

    
    //添加版本号到head里面
    [manager.requestSerializer setValue:(nil == self.versionStr?@"":self.versionStr) forHTTPHeaderField:@"App-Version"];
    
    //处理POST的参数
    NSComparisonResult compareRet = [httpMethod caseInsensitiveCompare:@"POST"];
    if(NSOrderedSame == compareRet)
    {
        [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //判断cookID是否超时
             if(operation.responseString == nil ||
                [@"" isEqualToString:operation.responseString])
             {
                 if(nil != self.requestInfo && operation.response.statusCode == 200)
                 {
                     _count++;
                     if(self.count > 3)
                     {
                         self.count = 0;
                         block2(nil,Failure);
                     }
                     else
                     {
                         //获取新的cookID
                         [self getCookIdSeviceIP2:serviceIP ServiceName:serviceName params:params httpMethod:httpMethod resultIsDictionary:resultIsDictionary completeBlock:block2];
                     }
                     
                     return;
                 }
                 
             }
             
             if(block2 != nil)
             {
                 self.count = 0;
                 block2(resultIsDictionary ? responseObject:operation.responseString,Success);
             }
         }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"调用服务出错(POST)");
             if(block2 != nil)
             {
                 self.count = 0;
                 block2(nil,Failure);
             }
         }];
    }
    else
    {
        [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //判断cookID是否超时
             if(operation.responseString == nil ||
                [@"" isEqualToString:operation.responseString])
             {
                 if(nil !=self.requestInfo && operation.response.statusCode == 200)
                 {
                     self.count++;
                     if(self.count > 3)
                     {
                         block2(nil,Failure);
                         self.count = 0;
                     }
                     else
                     {
                         //获取新的cookID
                         [self getCookIdSeviceIP2:serviceIP ServiceName:serviceName params:params httpMethod:httpMethod resultIsDictionary:resultIsDictionary completeBlock:block2];
                     }
                     
                     return;
                 }
                 
             }
             
             if(block2 != nil)
             {
                 self.count = 0;
                 block2(resultIsDictionary ? responseObject:operation.responseString,Success);
                 
             }
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"调用服务出错(GET)");
             if(block2 != nil)
             {
                 self.count = 0;
                 block2(nil,Failure);
             }
         }];
    }
}


-(void)getCookIdSeviceIP:(NSString *) serviceIP ServiceName:(NSString *)serviceName params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod resultIsDictionary:(BOOL)resultIsDictionary completeBlock:(RequestCompelete)block
{
    //拼接URL
    NSString *url = [NSString stringWithFormat:@"%@/%@/query",self.requestInfo.serviceIP,self.requestInfo.serviceName];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(!resultIsDictionary)
    {
        manager.responseSerializer = [AFCompoundResponseSerializer serializer];//响应
    }
    else
    {
        //manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    
    //设置相应内容类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/plain",@"text/javascript",nil];
    
    //处理POST的参数
    NSComparisonResult compareRet = [self.requestInfo.httpMethod caseInsensitiveCompare:@"POST"];
    if(NSOrderedSame == compareRet)
    {
        [manager POST:url parameters:self.requestInfo.params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //发送成功通知
             NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
             [center postNotificationName:@"LoginForGetCookId" object:resultIsDictionary ? responseObject:operation.responseString];
             
             //成功，继续调用当前服务
             [self requestWithServiceIP:serviceIP ServiceName:serviceName params:params httpMethod:httpMethod resultIsDictionary:resultIsDictionary completeBlock:block];
             
         }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             //发送失败通知
             NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
             [center postNotificationName:@"LoginForGetCookId" object:nil];
             
             if(block != nil)
             {
                 block(nil);
             }
         }];
    }
    else
    {
        [manager GET:url parameters:self.requestInfo.params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //发送成功通知
             NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
             [center postNotificationName:LoginForGetCookId object:resultIsDictionary ? responseObject:operation.responseString];
             
             //成功，继续调用当前服务
             [self requestWithServiceIP:serviceIP ServiceName:serviceName params:params httpMethod:httpMethod resultIsDictionary:resultIsDictionary completeBlock:block];
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             //发送失败通知
             NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
             [center postNotificationName:LoginForGetCookId object:nil];
             
             if(block != nil)
             {
                 block(nil);
             }
         }];
    }
}

-(void)getCookIdSeviceIP2:(NSString *) serviceIP ServiceName:(NSString *)serviceName params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod resultIsDictionary:(BOOL)resultIsDictionary completeBlock:(RequestCompelete2)block2
{
    //拼接URL
    NSString *url = [NSString stringWithFormat:@"%@/%@/query",self.requestInfo.serviceIP,self.requestInfo.serviceName];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(!resultIsDictionary)
    {
        manager.responseSerializer = [AFCompoundResponseSerializer serializer];//响应
    }
    else
    {
        //manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    
    //设置相应内容类型
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/plain",@"text/javascript",nil];
    
    //处理POST的参数
    NSComparisonResult compareRet = [self.requestInfo.httpMethod caseInsensitiveCompare:@"POST"];
    if(NSOrderedSame == compareRet)
    {
        [manager POST:url parameters:self.requestInfo.params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //成功通知
             NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
             [center postNotificationName:@"LoginForGetCookId" object:resultIsDictionary ? responseObject:operation.responseString];
             
             //继续调用当前服务
             [self requestWithServiceIP2:serviceIP ServiceName:serviceName params:params httpMethod:httpMethod resultIsDictionary:resultIsDictionary completeBlock:block2];
             
         }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             //失败通知
             NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
             [center postNotificationName:@"LoginForGetCookId" object:nil];
             
             //继续调用当前服务
             [self requestWithServiceIP2:serviceIP ServiceName:serviceName params:params httpMethod:httpMethod resultIsDictionary:resultIsDictionary completeBlock:block2];
         }];
    }
    else
    {
        [manager GET:url parameters:self.requestInfo.params success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //发送成功通知
             NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
             [center postNotificationName:LoginForGetCookId object:resultIsDictionary ? responseObject:operation.responseString];
             
             //成功，继续调用当前服务
             [self requestWithServiceIP2:serviceIP ServiceName:serviceName params:params httpMethod:httpMethod resultIsDictionary:resultIsDictionary completeBlock:block2];
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             //发送失败通知
             NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
             [center postNotificationName:LoginForGetCookId object:nil];
             
             if(block2 != nil)
             {
                 block2(nil,Failure);
             }
         }];
    }
}

#pragma mark 文件上传，参数说明：上传路径/本地文件的完整路径/附带的参数(可以为空)/上传文件对应的Key/文件名称(如：xxxx.png)/上传的类型(如：image/png)/上传进度block/完成block
-(void)uploadUrl:(NSString *) serviceIP ServiceName:(NSString *)serviceName
        fileFullPath:(NSString *)fileFullpath
        params:(NSMutableDictionary *)params name:(NSString *)name
        fileName:(NSString *)fileName mimeType:(NSString *)mimeType
        progressBlock:(ProgressBlock)progressBlock
        completeBlock:(RequestCompelete)block
{
    [self longriseUploadUrl:[NSString stringWithFormat:@"%@/%@/query",serviceIP,serviceName] fileFullPath:fileFullpath params:params name:name fileName:fileName  mimeType:mimeType progressBlock:progressBlock completeBlock:block];
    
}

-(void)uploadUrl:(NSString *) serviceIP ServiceName:(NSString *)serviceName
            data:(NSData *)data fileType:(NSString *)fileType
          params:(NSMutableDictionary *)params
            name:(NSString *)name mimeType:(NSString *)mimeType
   progressBlock:(ProgressBlock)progressBlock
   completeBlock:(RequestCompelete)block
{
    NSString *fileName = [NSString stringWithFormat:@"%ld.%@",[Util getCurrentTime],fileType];
    NSString *tempPath = [NSString stringWithFormat:@"%@/%@",[FileManagerUtil tmpPath],fileName];
    
    [FileManagerUtil saveObject:data byPatch:tempPath];
    [self longriseUploadUrl:[NSString stringWithFormat:@"%@/%@/query",serviceIP,serviceName] fileFullPath:tempPath params:params name:name fileName:fileName mimeType:mimeType progressBlock:progressBlock completeBlock:block];
}

-(void)longriseUploadUrl:(NSString *)url fileFullPath:(NSString *)fileFullpath params:(NSMutableDictionary *)params name:(NSString *)name fileName:(NSString *)fileName
    mimeType:(NSString *)mimeType progressBlock:(ProgressBlock)progressBlock completeBlock:(RequestCompelete)block
{
    myProgressBlock = progressBlock;
    if(!mimeType)
    {
        mimeType = @"application/octet-stream";
    }
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        
        //上传的类型：1、本地文件 2、NSData对象
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:fileFullpath] name:name fileName:fileName mimeType:mimeType error:nil];
        
    } error:nil];
    
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //设置相应返回值支持的类型
    ((AFHTTPResponseSerializer *)(manager.responseSerializer)).acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"text/plain",@"text/javascript",nil];
    
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error){
        
        if(progress)
        {
            [progress removeObserver:self forKeyPath:@"fractionCompleted"];
        }
        
        myProgressBlock = nil;
        
        if (error)
        {
            if(block != nil)
            {
                block(nil);
            }
            NSLog(@"上传出错，错误信息: %@", error);
        }
        else
        {
            if(block != nil)
                
            {
                block(responseObject);
            }
        }
    }];
    
    // 添加上传进度KVO
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    [uploadTask resume];
}

#pragma mark 上传进度回调方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"fractionCompleted"] && [object isKindOfClass:[NSProgress class]]) {
        NSProgress *progress = (NSProgress *)object;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //转到UI线程
            if(myProgressBlock)
            {
                myProgressBlock(progress.fractionCompleted);
            }
        });
        
        NSLog(@"Progress is %f", progress.fractionCompleted);
    }
    //[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (NSString*)objectToJson:(NSObject *)object
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

//#pragma mark 获取网络状态 0:没有网 1:WI-FI 2:手机移动网
-(int)getNetState
{
    // 1.检测wifi状态
    Reachability *wifi = [Reachability reachabilityForLocalWiFi];
    
    // 2.检测手机是否能上网络(WIFI\3G\2.5G)
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    
    // 3.判断网络状态
    if ([wifi currentReachabilityStatus] != NotReachable)
    {
        // 有wifi
        return 1;
    }
    else if ([conn currentReachabilityStatus] != NotReachable)
    {
        // 没有使用wifi, 使用手机自带网络进行上网
        return 2;
    }
    else
    {
        // 没有网络
        return 0;
    }
    
}

#pragma mark 设置登录信息
-(void)setRequestInfo:(HttpRequestInfo *)requestInfo
{
    _requestInfo = requestInfo;
    
    //保存数据到本地
    [[NSUserDefaults standardUserDefaults] setObject:_requestInfo.serviceIP forKey:IP_KEY_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:_requestInfo.serviceName forKey:SERVICENAME_KEY_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:_requestInfo.params forKey:PARAMBEAN_KEY_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:_requestInfo.httpMethod forKey:REQUEST_TYPE_KEY_NAME];
}

#pragma mark 设置版本号
-(void)setVersionStr:(NSString *)versionStr
{
    _versionStr = versionStr;
    [[NSUserDefaults standardUserDefaults] setObject:_versionStr forKey:VERSION_KEY_NAME];
}

#pragma mark 用户Session过期标志符数组
-(void)setLoginOutArray:(NSArray *)loginOutArray
{
    _loginOutArray = loginOutArray;
    [[NSUserDefaults standardUserDefaults] setObject:_loginOutArray forKey:LOGINOUT_KEY_NAME];
}

#pragma mark 用户被挤掉标志符数组
-(void)setSessionTimeOutArray:(NSArray *)sessionTimeOutArray
{
    _sessionTimeOutArray = sessionTimeOutArray;
    [[NSUserDefaults standardUserDefaults] setObject:_sessionTimeOutArray forKey:SESSION_TIMEOUT_KEY_NAME];
}

@end
