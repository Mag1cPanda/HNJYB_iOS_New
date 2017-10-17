//
//  BaseViewController.m
//  HNJYB_iOS_New
//
//  Created by panshen on 2017/10/17.
//  Copyright © 2017年 panshen. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    
    NSArray *arr = self.navigationController.viewControllers;
    if (arr.count > 1)
    {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(0, 0, 40, 40);
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:1 << 6];
        
        [_backBtn setImage:[UIImage imageNamed:@"IP020"] forState:0];
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:_backBtn];
        self.navigationItem.leftBarButtonItem = item;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
