//
//  LRNavigationController.m
//  HNJYB_iOS_New
//
//  Created by panshen on 2017/10/17.
//  Copyright © 2017年 panshen. All rights reserved.
//

#import "LRNavigationController.h"

@interface LRNavigationController ()

@end

@implementation LRNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *img = [UIImage imageNamed:@"blue"];
    // 指定为拉伸模式，伸缩后重新赋值
    img = [img resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    [self.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
    
    //去除导航栏底部黑线
    [self.navigationBar setShadowImage:[UIImage new]];
    
    //导航栏文字颜色变为白色
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    //去掉系统自带返回按钮的文字，只保留箭头
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    //改变返回按钮的颜色
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    
    //设置原点坐标从标题栏下面开始
    self.navigationBar.translucent = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
