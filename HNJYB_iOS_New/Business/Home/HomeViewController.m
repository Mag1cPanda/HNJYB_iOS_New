//
//  HomeViewController.m
//  CZT_HN_Longrise
//
//  Created by OSch on 16/5/12.
//  Copyright © 2016年 OSch. All rights reserved.
//

#import "HomeViewController.h"
#import "CaseViewController.h"
#import "GPSNoticeViewController.h"
#import "InfoViewController.h"
#import "LoginViewController.h"
#import "LRNavigationController.h"
#import "BeforeQRCodeViewController.h"
#import "SignViewController.h"
#import "JCAlertView.h"
#import "AFNetworking.h"
#import "Alert.h"
#import "NSDate+Extension.h"

@interface HomeViewController ()
<UIAlertViewDelegate>
{
    JCAlertView *jcAlert;
    UIAlertView *tipsAlert;
}
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *bindInfoAry;

@end

@implementation HomeViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"快处快赔";
    self.soundIcon.hidden = YES;
    
    self.scrollLab.font = [UIFont systemFontOfSize:15];
    self.scrollLab.textColor = [UIColor colorWithHexString:@"99ffff"];
    self.scrollLab.backgroundColor = [UIColor clearColor];
    self.scrollLab.labelSpacing = ScreenWidth;
    self.scrollLab.pauseInterval = 1.5;
    self.scrollLab.scrollSpeed = 30;
    self.scrollLab.textAlignment = NSTextAlignmentCenter;
    self.scrollLab.fadeLength = 12.f;
    self.scrollLab.scrollDirection = CBAutoScrollDirectionLeft;
    [self.scrollLab observeApplicationNotifications];
    
    UIImage *image1 = [UIImage imageNamed:@"sound1"];
    UIImage *image2 = [UIImage imageNamed:@"sound2"];
    UIImage *image3 = [UIImage imageNamed:@"sound3"];
    _soundIcon.image = image1;
    _soundIcon.animationImages = @[ image1, image2, image3 ];
    _soundIcon.animationDuration = 2;    //设置动画时间
    _soundIcon.animationRepeatCount = 0; //设置动画次数 0 表示无限
    [_soundIcon startAnimating];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc] init];
    //初始化地理编码类
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    
    //初始化UI
    [self init_UI];
    
    //获取用户位置
    //    [self getPositionInfo];
    
    //加载数据
    //    [self loadData];
    
    if (![UserDefaultsUtil getDataForKey:@"isReminded"]) {
        
        Alert *alert = [[Alert alloc] initWithTitle:@"亲，请关注增加的功能：" message:[self getTips] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alert.contentAlignment = NSTextAlignmentLeft;
        alert.cancelBlock = ^(Alert *alert){
            [UserDefaultsUtil saveNSUserDefaultsForBOOL:true forKey:@"isReminded"];
        };
        [alert show];
        
    }
    
    //开始追踪用户位置信息
//    [self startTrackingUserLocation];
    
}

#pragma mark - 更新内容
-(NSString *)getTips
{
//    return @"1、事故时间和事故地点挪至填写车辆信息界面.\n2、可将事故时间进行修改，但必须小于事故照片上传时间.\n3、对事故情形增加图形描述.\n4、针对拍照不规范导致证件信息识别率低的问题，在姓名及车架号后面点击拍照按钮，可以重新拍摄规范的证件照片进行重新识别，以便提高数据录入效率.\n5、挪车提示语优化、优化大小写强制转换.";
    return @"1.优化了历史记录的查询。";
}


#pragma mark - 追踪用户信息
-(void)startTrackingUserLocation
{
    //每隔多长时间发送位置信息到服务器
    self.locationUpdateTimer =
    [NSTimer scheduledTimerWithTimeInterval:self.timeInterval
                                     target:self
                                   selector:@selector(updateLocation)
                                   userInfo:nil
                                    repeats:YES];
}

-(NSTimeInterval)timeInterval
{
    if (!_timeInterval) {
        _timeInterval = 300;
    }
    
    return _timeInterval;
}

-(void)updateLocation {
    NSLog(@"updateLocation");
    [_locService startUserLocationService];
}

#pragma mark - LocationTrackerDelegate


#pragma mark - 检查印章权限
-(void)checkTimeOrAuthority
{
    NSMutableDictionary *bean = [NSMutableDictionary dictionary];
    [bean setValue:GlobleInstance.userflag forKey:@"userflag"];
    [bean setValue:GlobleInstance.token forKey:@"token"];
    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [LSHttpManager requestUrl:HNServiceURL serviceName:@"jjappcheckTimeIsTrue" parameters:bean complete:^(id result, ResultType resultType) {
        
//        [hud hideAnimated:YES];
        NSLog(@"jjappcheckTimeIsTrue ~ %@", result);
        
        if ([result[@"restate"] isEqualToString:@"1"])
        {
            //判断定位是否开启
            if ([CLLocationManager locationServicesEnabled] &&
                ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)) {
                BeforeQRCodeViewController *vc = [BeforeQRCodeViewController new];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else {
                GPSNoticeViewController *gpstyVC = [GPSNoticeViewController new];
                [self.navigationController pushViewController:gpstyVC animated:YES];
            }
            
        }
        
        else {
            [Util showHudWithView:self.view message:result[@"redes"] hideAfterDelay:1.5];
        }
        
    }];
}

#pragma mark - 退出登录
- (void)backAction
{
    UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:nil message:@"确定退出登录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定退出", nil];
    [logoutAlert show];
}

#pragma mark - 初始化UI
- (void)init_UI
{
    self.bindInfoAry = [NSMutableArray array];
    
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topClick)];
    [self.caseDispose addGestureRecognizer:singleTap1];
    singleTap1.cancelsTouchesInView = NO;
    
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(middleClick)];
    [self.historyCase addGestureRecognizer:singleTap2];
    singleTap2.cancelsTouchesInView = NO;
    
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomClick)];
    [self.userInfo addGestureRecognizer:singleTap3];
    singleTap3.cancelsTouchesInView = NO;
    
    //置空单双车的类型 区域id(事故地点每次都要重新识别)
    [Globle getInstance].areaid = @"";
    [Globle getInstance].imageaddress = @"";
}

#pragma mark - 加载数据
- (void)loadData
{
    NSMutableDictionary *bean = [NSMutableDictionary dictionary];
    
    [bean setValue:GlobleInstance.userid forKey:@"userid"];
    [bean setValue:GlobleInstance.policeno forKey:@"policeno"];
    [bean setValue:GlobleInstance.userflag forKey:@"username"];
    [bean setValue:GlobleInstance.token forKey:@"token"];
    
    [LSHttpManager requestUrl:HNServiceURL serviceName:@"kckpjjSearchAllCaseNum" parameters:bean complete:^(id result, ResultType resultType) {
        
        NSLog(@"kckpjjSearchAllCaseNum ~ %@", result);
        
        if ([result[@"restate"] isEqualToString:@"1"]) {
            [_userIcon sd_setImageWithURL:[NSURL URLWithString:GlobleInstance.photo]
                         placeholderImage:[UIImage imageNamed:@"default"]];
            _contentLab.text = [NSString stringWithFormat:@"您目前已处理完成事故%@起",result[@"data"]];
            _userName.text = GlobleInstance.userflag;
            
            if ([result[@"play"] isKindOfClass:[NSDictionary class]]) {
                
                NSArray *tmpArr = result[@"play"][@"notice"];
                
                NSMutableString *remark = [NSMutableString stringWithString:@""];
                for (int i=0; i<tmpArr.count; i++) {
                    NSDictionary *tmpDic = tmpArr[i];
                    
                    NSString *tmpStr;
                    if (i==0) {
                        tmpStr = [NSString stringWithFormat:@"%@",tmpDic[@"remark"]];
                    }
                    
                    else {
                        
                        CGSize size = [@" " sizeWithAttributes:@{@"NSFontAttributeName":[UIFont systemFontOfSize:15]}];
//                        NSLog(@"size.width = %f",size.width);
                        
                        float f = ScreenWidth/size.width;
                        int a;
                        a = floor(f);
//                        NSLog(@"a = %d",a);
                        
                        for (int i=0; i<a/2; i++) {
                            [remark appendString:@" "];
                        }
                        
                        tmpStr = [NSString stringWithFormat:@"                                                  %@",tmpDic[@"remark"]];
                    }
                    
                    [remark appendString:tmpStr];
                }
                
                //没有通知内容隐藏通知图标
                if ([remark isEqualToString:@""]) {
                    self.scrollLab.text = @"";
                    self.soundIcon.hidden = YES;
                }
                else {
                    [self.scrollLab setText:remark refreshLabels:YES];
                    //                    self.scrollLab.text = remark;
                    self.soundIcon.hidden = NO;
                }
                
            }
            
        }
    }];
}

#pragma mark - Life Circle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //获取用户位置
    [self getPositionInfo];
    
    //加载数据
    [self loadData];
    
    _locService.delegate = self;
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _locService.delegate = nil;
    _geocodesearch.delegate = nil; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

#pragma mark 获取位置信息
- (void)getPositionInfo
{
    //判读单例里面是否有定位信息
    if (!GlobleInstance.areaid ||
        !GlobleInstance.imageaddress ||
        !GlobleInstance.imagelat ||
        !GlobleInstance.imagelon)
    {
        //判断是非有定位权限
        if ([CLLocationManager locationServicesEnabled] &&
            ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse))
        {
            //定位功能可用，开始定位
            NSLog(@"开始定位");
            if (_locService != nil)
            {
                [_locService startUserLocationService];
            }
        }
        else
        {
            NSLog(@"定位功能不可用，提示用户");
            SHOWALERT(@"无法获取您的位置信息，请前去开启GPS定位");
        }
    }
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"========= didFailToLocateUserWithError");
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"========= didUpdateBMKUserLocation");
    
    //显示经纬度
    NSLog(@"用户位置更新后的经纬度：lat:%f,long:%f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    
    //停止定位
    if (nil != _locService)
    {
        [_locService stopUserLocationService];
    }
    
    lat = userLocation.location.coordinate.latitude;
    lon = userLocation.location.coordinate.longitude;
    
    GlobleInstance.imagelat = lat;
    GlobleInstance.imagelon = lon;
    
    //上传用户位置信息
    if (GlobleInstance.imagelon && GlobleInstance.imagelat) {
        [self uploadUserLocationInfo];
    }
    
    //根据经纬度获取Areaid
    [self getCurrentAreaId];
    
    //开始检索，将经纬度转化成具体地址
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){lat, lon};
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if (flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

#pragma mark 经纬度转化成地址回调接口
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"========= onGetReverseGeoCodeResult");
    
    if (error == BMK_SEARCH_NO_ERROR)
    {
        //        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        //        item.coordinate = result.location;
        //        item.title = result.address;
        NSLog(@"反向地理编码地址：%@", result.address);
        imageAddress = result.address;
        [Globle getInstance].imageaddress = result.address;
        
        //保存当前时间戳
        [UserDefaultsUtil saveNSUserDefaultsForObject:[NSDate date] forKey:LOCATIONTIMEKEY];
    }
    else
    {
        NSLog(@"经纬度转化成地址回调方法中反geo检索发送失败");
    }
    
}

#pragma mark - 上传用户位置信息
-(void)uploadUserLocationInfo
{
    //向服务器发送位置信息
    NSLog(@"Send to Server: Latitude(%f) Longitude(%f)",GlobleInstance.imagelat, GlobleInstance.imagelon);
    
    NSMutableDictionary *bean = [[NSMutableDictionary alloc] init];
    [bean setValue:[Globle getInstance].userflag forKey:@"userflag"];
    [bean setValue:[Globle getInstance].token forKey:@"token"];
    
    NSString *maplon = [NSString stringWithFormat:@"%f",GlobleInstance.imagelon];
    NSString *maplat = [NSString stringWithFormat:@"%f",GlobleInstance.imagelat];
    [bean setValue:maplon forKey:@"maplon"];
    [bean setValue:maplat forKey:@"maplat"];
    
    [LSHttpManager requestUrl:HNServiceURL serviceName:@"hnkckpjjgetlocation" parameters:bean complete:^(id result, ResultType resultType) {
        
        NSLog(@"hnkckpjjgetlocation ~ %@",result);
        
        if ([result[@"restate"] isEqualToString:@"1"]) {
            NSLog(@"用户位置信息发送成功");
        }
        
        else {
            NSLog(@"%@",result[@"redes"]);
        }
        
    }];
}

#pragma mark - 获取Areaid
- (void)getCurrentAreaId
{
    NSMutableDictionary *bean = [NSMutableDictionary dictionary];
    
    NSString *maplon = [NSString stringWithFormat:@"%f", GlobleInstance.imagelon];
    NSString *maplat = [NSString stringWithFormat:@"%f", GlobleInstance.imagelat];
    NSString *userflag = [NSString stringWithFormat:@"%@", GlobleInstance.userflag];
    NSString *token = [NSString stringWithFormat:@"%@", GlobleInstance.token];
    
    [bean setValue:maplon forKey:@"maplon"];
    [bean setValue:maplat forKey:@"maplat"];
    [bean setValue:userflag forKey:@"userflag"];
    [bean setValue:token forKey:@"token"];
    
//    MBProgressHUD *dwHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [LSHttpManager requestUrl:HNServiceURL serviceName:@"jjappgetweather" parameters:bean complete:^(id result, ResultType resultType) {
        
//        [dwHud hideAnimated:YES];
        
        if (result) {
            NSLog(@"Areaid -> %@", [Util objectToJson:result]);
        }
        
        if ([result[@"restate"] isEqualToString:@"1"])
        {
            self.caseDispose.userInteractionEnabled = true;
            NSString *areaid = result[@"data"];
            GlobleInstance.areaid = areaid;
        }
        else
        {
            self.caseDispose.userInteractionEnabled = false;
            SHOWALERT(result[@"redes"]);
            NSLog(@"获取areaid不成功");
        }
    }];
}

#pragma mark - Lazy
- (NSMutableArray *)dataSource
{
    if (!_dataSource)
    {
    }
    return _dataSource;
}

#pragma mark - 车辆事故
- (void)topClick
{
    
    [self checkTimeOrAuthority];
    
}

#pragma mark - 历史案件
- (void)middleClick
{
    CaseViewController *vc = [CaseViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 个人信息
- (void)bottomClick
{
    InfoViewController *vc = [InfoViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == tipsAlert)
    {
        [UserDefaultsUtil saveNSUserDefaultsForBOOL:true forKey:@"isReminded"];
    }
    
    else
    {
        if (buttonIndex == 0)
        {
            NSLog(@"取消退出登录");
        }
        else
        {
            [UserDefaultsUtil removeAllUserDefaults]; //删除所有本地用户信息
            
            NSLog(@"用户确认安全退出，发送退出登录通知");
            
            NavViewController *nav = [[NavViewController alloc] initWithRootViewController:[LoginViewController new]];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
    
}



@end
