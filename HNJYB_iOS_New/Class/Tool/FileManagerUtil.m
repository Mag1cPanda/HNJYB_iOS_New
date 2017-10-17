//
//  FileManagerUtil.m
//  AVPlayerDemo2
//
//  Created by 程三 on 17/5/25.
//  Copyright © 2017年 程三. All rights reserved.
//

#import "FileManagerUtil.h"

@implementation FileManagerUtil

+ (NSString *)homePath{
    return NSHomeDirectory();
}

+ (NSString *)appPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)docPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)libPrefPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *paths1 = [[paths objectAtIndex:0] stringByAppendingFormat:@"/Preference"];
    [self hasLive:paths1];
    return paths1;
}

+ (NSString *)libCachePath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    NSString *paths1 = [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
    [self hasLive:paths1];
    
    return paths1;
}

+ (NSString *)tmpPath
{
    NSString * paths = [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
    [self hasLive:paths];
    return paths;
}

+ (BOOL)hasLive:(NSString *)path
{
    if(path)
    {
        if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:path] )
        {
            return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:NULL];
        }
    }
    
    return NO;
}

#pragma mark 创建目录
+ (BOOL)createDirectory:(NSString *)path
{
    if(path)
    {
        if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            return [[NSFileManager defaultManager] createDirectoryAtPath:path
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:NULL];
        }
        else
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark 获取文件的目录
+ (NSString *)getDirectoryForPath:(NSString *)path
{
    if(path)
    {
        for (int i = (int)[path length] - 1; i >= 0; i--)
        {
            NSString *tempStr = [path substringWithRange:NSMakeRange(i, 1)];
            if([@"/" isEqualToString:tempStr])
            {
                NSLog(@"截取到的目录：%@",[path substringToIndex:i]);
                //截取目录
                return [path substringToIndex:i];
            }
        }
    }
    return nil;
}
#pragma mark 创建文件
+ (BOOL)createFile:(NSString *)path isDelForExist:(BOOL) b
{
    if(path)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            if(b)
            {
                [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            }
            else
            {
                return YES;
            }
        }
        //判断目录是否存在
        NSString *tempDir = [self getDirectoryForPath:path];
        if(tempDir)
        {
            BOOL b = [self createDirectory:tempDir];
            if(!b)
            {
                return NO;
            }
        }
        
        //创建文件
        return [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:NULL];
    }
    return NO;
}

#pragma mark 删除某个文件目录（包括里面的文件）
+ (void)deleteDirectoryWhitPath:(NSString *)path
{
    //判断目录是否为空
    if(!path)
    {
        return;
    }
    
    //dispatch_async开启一个异步操作，第一个参数是指定一个gcd队列，第二个参数是分配一个处理事物的程序块到该队列。
    //dispatch_get_global_queue(0, 0)，指用了全局队列。
    //一般来说系统本身会有3个队列。
    //global_queue，current_queue,以及main_queue.
    //获取一个全局队列是接受两个参数，第一个是我分配的事物处理程序块队列优先级。分高低和默认，0为默认2为高，-2为低
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
            if(nil != contents && contents.count > 0)
            {
                NSEnumerator *e = [contents objectEnumerator];
                NSString *fileName;
                while (fileName = [e nextObject])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:[[path stringByAppendingString:@"/"] stringByAppendingString:fileName] error:NULL];
                }
            }
            //删除文件夹
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }

    });
    
}

+ (BOOL)delteFileWithPath:(NSString *)path
{
    if(path)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            return [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        }
    }
    
    return NO;
}

#pragma mark 保存数据到指定文件中，目录不存在会创建
+ (void)saveObject:(NSData *)object byPatch:(NSString*)path
{
    if(!object)
    {
        return;
    }
    if(!path)
    {
        return;
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        BOOL b= [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        if(!b)
        {
            return;
        }
    }
    
    NSString *tempDir = [self getDirectoryForPath:path];
    if(tempDir)
    {
        [self createDirectory:tempDir];
    }
    
    NSLog(@"路径：%@",path);
    
    BOOL result = [[NSFileManager defaultManager] createFileAtPath:path contents:object attributes:NULL];
    NSLog(@"写入结果：%d",result);
}


#pragma mark 存储用户偏好设置到NSUserDefults
+(void)saveUserData:(id)data forKey:(NSString*)key
{
    if (data)
    {
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:key];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}
#pragma mark 读取用户偏好设置
+(id)readUserDataForKey:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:key];
    
}
#pragma mark 删除用户偏好设置
+(void)removeUserDataForkey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
}


@end
