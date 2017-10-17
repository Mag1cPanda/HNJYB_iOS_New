//
//  PermissionManager.m
//  LongriseHttpManageIOS
//
//  Created by 程三 on 17/5/19.
//  Copyright © 2017年 程三. All rights reserved.
//

#import "PermissionManager.h"
#import <UIKit/UIKit.h>
#import "Util.h"

#define PermissionNotificationKey @"isFirst"

static PermissionManager *permissionManager;

@implementation PermissionManager

#pragma mark 获取单例对象
+(PermissionManager *)getPermissionManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        if(!permissionManager)
        {
            permissionManager = [[PermissionManager alloc] init];
        }
    });
    
    return permissionManager;
}


//========================定位权限================================
#pragma mark 定位权限请求
-(void)requestLocationPermissionBlock:(PermissionBlock)block
{
    permissionBlock = block;
    
    BOOL isLocation = [CLLocationManager locationServicesEnabled];
    if (!isLocation)
    {
        NSLog(@"定位服务不可用");
        [self showNoticeTitle:@"定位服务不可用"];
        return;
    }
    
    CLAuthorizationStatus CLstatus = [CLLocationManager authorizationStatus];
    switch (CLstatus) {
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            [self canDo];
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            [self canDo];
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            [self showChooseWhenNotPermissionTitle:@"请打开定位权限"];
            break;
        }
        case kCLAuthorizationStatusNotDetermined:
        {
            [self startRequestLocation];
            break;
        }
        case kCLAuthorizationStatusRestricted:
        {
            [self showChooseWhenNotPermissionTitle:@"请打开定位权限"];
            break;
        }
        default:
            break;
    }
}

#pragma mark 开始请求权限
-(void)startRequestLocation
{
     _manager = [[CLLocationManager alloc] init];
    
    _manager.delegate = self;
    [_manager requestAlwaysAuthorization];//一直获取定位信息
    [_manager requestWhenInUseAuthorization];//使用的时候获取定位信息
}

#pragma mark
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    switch (status)
    {
    case kCLAuthorizationStatusAuthorizedAlways:
        [self canDo];
        break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
        [self canDo];
        break;
    case kCLAuthorizationStatusDenied:
        [self showChooseWhenNotPermissionTitle:@"请打开定位权限"];
        break;
    case kCLAuthorizationStatusNotDetermined:
        //[self startRequestLocation];
        break;
    case kCLAuthorizationStatusRestricted:
        [self showChooseWhenNotPermissionTitle:@"请打开定位权限"];
        break;
    default:
        break;
    }
}

//========================相机权限================================

#pragma mark 相机权限请求
-(void)requestCameraPermissionBlock:(PermissionBlock)block
{
    permissionBlock = block;
    AVAuthorizationStatus AVstatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (AVstatus) {
        case AVAuthorizationStatusAuthorized:
            [self canDo];
            break;
        case AVAuthorizationStatusDenied:
            [self showChooseWhenNotPermissionTitle:@"请打开相机权限"];
            break;
        case AVAuthorizationStatusNotDetermined:
            [self startRequestCamera];
            break;
        case AVAuthorizationStatusRestricted:
            [self showChooseWhenNotPermissionTitle:@"请打开相机权限"];
            break;  
        default:      
            break;
    }

}

#pragma mark 请求相机权限
-(void)startRequestCamera
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
        if (granted)
        {
            [self canDo];
        }
        else
        {
            [self showChooseWhenNotPermissionTitle:@"请打开相机权限"];
        }
    }];
}

//========================麦克风权限================================

#pragma mark 麦克风权限请求
-(void)requestMicrophonePermissionBlock:(PermissionBlock)block
{
    permissionBlock = block;
    AVAuthorizationStatus AVstatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];//麦克风权限
    switch (AVstatus) {
        case AVAuthorizationStatusAuthorized:
            [self canDo];
            break;
        case AVAuthorizationStatusDenied:
            [self showChooseWhenNotPermissionTitle:@"请打开麦克风权限"];
            break;
        case AVAuthorizationStatusNotDetermined:
            [self startRequestMicrophone];
            break;
        case AVAuthorizationStatusRestricted:
            [self showChooseWhenNotPermissionTitle:@"请打开麦克风权限"];
            break;
        default:
            break;
    }
    
}

#pragma mark 请求麦克风权限
-(void)startRequestMicrophone
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        //麦克风权限
        if (granted)
        {
            [self canDo];
        }
        else
        {
            [self showChooseWhenNotPermissionTitle:@"请打开麦克风权限"];
        }
    }];
}

//========================通讯录权限================================

#pragma mark 麦克风权限请求
-(void)requestAddressBookPermissionBlock:(PermissionBlock)block
{
    permissionBlock = block;
    if([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
    {
        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (authStatus) {
            case CNAuthorizationStatusAuthorized:
                [self canDo];
                break;
            case CNAuthorizationStatusDenied:
                [self showChooseWhenNotPermissionTitle:@"请打开通讯录权限"];
                break;
            case CNAuthorizationStatusNotDetermined:
                [self startRequestAddressBook];
                break;
            case CNAuthorizationStatusRestricted:
                [self showChooseWhenNotPermissionTitle:@"请打开通讯录权限"];
                break;
            default:
                break;
        }
    }
    else
    {
        ABAuthorizationStatus ABstatus = ABAddressBookGetAuthorizationStatus();
        
        switch (ABstatus) {
            case kABAuthorizationStatusAuthorized:
                [self canDo];
                break;
            case kABAuthorizationStatusDenied:
                [self showChooseWhenNotPermissionTitle:@"请打开通讯录权限"];
                break;
            case kABAuthorizationStatusNotDetermined:
                [self startRequestAddressBook];
                break;
            case kABAuthorizationStatusRestricted:
                [self showChooseWhenNotPermissionTitle:@"请打开通讯录权限"];
                break;
            default:      
                break;
        }
    }
}

-(void)startRequestAddressBook
{
    if([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
    {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
            {
                [self canDo];
            }
            else
            {
                [self showChooseWhenNotPermissionTitle:@"请打开通讯录权限"];
            }
        }];
    }
    else
    {
        __block ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted)
            {
                [self canDo];
            }
            else
            {
                [self showChooseWhenNotPermissionTitle:@"请打开通讯录权限"];
            }
            
            if (addressBook)
            {
                CFRelease(addressBook);
                addressBook = NULL;
            }
        });

    }
}

//========================推送权限================================

#pragma mark 推送权限请求,该方法从8.0开始支持，低于8.0的请提出再提出
-(void)requestNotificationPermissionBlock:(PermissionBlock)block;
{
    permissionBlock = block;
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    switch (settings.types)
    {
        case UIUserNotificationTypeNone:
            [self showChooseWhenNotPermissionTitle:@"请打开通知权限"];
            break;
        case UIUserNotificationTypeAlert:
            [self canDo];
            break;
        case UIUserNotificationTypeBadge:
            [self canDo];
            break;
        case UIUserNotificationTypeSound:
            [self canDo];
            break;
        default:
            [self canDo];
            break;
    }
}

#pragma mark 请求推送权限
-(void)startRequestNotification
{
    if ([UIDevice currentDevice].systemVersion.floatValue > 8.0)
    {
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

//========================相册权限================================

#pragma mark 相册权限请求 该方法从IOS8.0开始支持，8.0以前如果有需要支持的再说
-(void)requestPhotoPermissionBlock:(PermissionBlock)block
{
    permissionBlock = block;
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoAuthorStatus)
    {
        case PHAuthorizationStatusAuthorized:
            // 用户授权此应用程序访问图片数据
            [self canDo];
            break;
        case PHAuthorizationStatusDenied:
            // 用户已经明确否认了这个应用程序访问图片数据
            [self showChooseWhenNotPermissionTitle:@"请打开相册权限"];
            break;
        case PHAuthorizationStatusNotDetermined:
            // 用户还没有关于这个应用程序做出了选择
            [self startRequestPhoto];
            break;
        case PHAuthorizationStatusRestricted:
            // 这个应用程序未被授权访问图片数据。用户不能更改该应用程序的状态,可能是由于活动的限制,如家长控制到位。
            [self showChooseWhenNotPermissionTitle:@"请打开相册权限"];
            break;
        default:
            break;
    }
}

#pragma mark 请求相册权限
-(void)startRequestPhoto
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized)
        {
            [self canDo];
        }
        else
        {
            [self showChooseWhenNotPermissionTitle:@"请打开相册权限"];
        }
    }];
}

//====================================================

#pragma mark 拥有权限，进行回调
-(void)canDo
{
    if(permissionBlock)
    {
        permissionBlock(YES);
    }
}

#pragma mark 弹出提示
-(void)showNoticeTitle:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
    [alert show];
}

#pragma mark 问权限拒绝时弹出选择框
-(void)showChooseWhenNotPermissionTitle:(NSString *)msg
{
    myAlert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
    [myAlert show];
}

#pragma mark UIAlertView代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == myAlert)
    {
        if(buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}
@end
