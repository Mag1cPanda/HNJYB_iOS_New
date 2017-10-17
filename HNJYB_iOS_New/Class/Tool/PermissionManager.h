//
//  PermissionManager.h
//  LongriseHttpManageIOS
//
//  Created by 程三 on 17/5/19.
//  Copyright © 2017年 程三. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h> //定位包
#import <Photos/PHPhotoLibrary.h>     //相册包
#import <AVFoundation/AVFoundation.h> //相机和麦克风包
#import <AddressBook/AddressBook.h>   //通讯录包
#import <Contacts/Contacts.h>         //通讯录包
#import <UIKit/UIKit.h>

typedef void(^PermissionBlock)(BOOL b);

@interface PermissionManager : NSObject<CLLocationManagerDelegate,UIAlertViewDelegate>
{
    PermissionBlock permissionBlock;
    UIAlertView *myAlert;
}
@property(nonatomic,retain)CLLocationManager *manager;
+(PermissionManager *)getPermissionManager;

#pragma mark 定位权限请求
-(void)requestLocationPermissionBlock:(PermissionBlock)block;
#pragma mark 相册权限请求
-(void)requestPhotoPermissionBlock:(PermissionBlock)block;
#pragma mark 相机权限请求
-(void)requestCameraPermissionBlock:(PermissionBlock)block;
#pragma mark 麦克风权限请求
-(void)requestMicrophonePermissionBlock:(PermissionBlock)block;
#pragma mark 推送权限请求
-(void)requestNotificationPermissionBlock:(PermissionBlock)block;
#pragma mark 通讯录权限请求
-(void)requestAddressBookPermissionBlock:(PermissionBlock)block;

@end
