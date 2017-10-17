//
//  FileManagerUtil.h
//  AVPlayerDemo2
//
//  Created by 程三 on 17/5/25.
//  Copyright © 2017年 程三. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileManagerUtil : NSObject

/*
 IOS的沙盒结构
   Documents
 
   Library
        Caches //缓存目录
        Preferences //偏好设置目录
   tmp
 */


#pragma mark 程序主目录，可见子目录(3个):Documents、Library、tmp
+ (NSString *)homePath;
#pragma mark 程序目录，不能存任何东西
+ (NSString *)appPath;
#pragma mark 文档目录，需要ITUNES同步备份的数据存这里，可存放用户数据
+ (NSString *)docPath;
#pragma mark 配置目录，配置文件存这里
+ (NSString *)libPrefPath;
#pragma mark 缓存目录，系统永远不会删除这里的文件，ITUNES会删除
+ (NSString *)libCachePath;
#pragma mark 临时缓存目录，APP退出后，系统可能会删除这里的内容
+ (NSString *)tmpPath;

#pragma mark 获取文件的目录
+ (NSString *)getDirectoryForPath:(NSString *)path;
#pragma mark 创建目录
+ (BOOL)createDirectory:(NSString *)path;
#pragma mark 创建目录，目录不存在会自动创建，b表示文件存在是否删除
+ (BOOL)createFile:(NSString *)path isDelForExist:(BOOL) b;

#pragma mark 删除某个文件目录（包括里面的文件）
+ (void)deleteDirectoryWhitPath:(NSString *)path;
#pragma mark 删除指定的文件
+ (BOOL)delteFileWithPath:(NSString *)path;

#pragma mark 保存数据到指定文件中，如果目录不存在会自动创建
+ (void)saveObject:(NSData *)object byPatch:(NSString*)path;

#pragma mark 存储用户偏好设置到NSUserDefults
+ (void)saveUserData:(id)data forKey:(NSString*)key;
#pragma mark 读取用户偏好设置
+ (id)readUserDataForKey:(NSString*)key;
#pragma mark 删除用户偏好设置
+ (void)removeUserDataForkey:(NSString*)key;


@end
