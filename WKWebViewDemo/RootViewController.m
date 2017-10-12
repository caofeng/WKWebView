//
//  RootViewController.m
//  WKWebViewDemo
//
//  Created by Caofeng on 2017/10/12.
//  Copyright © 2017年 深圳中业兴融互联网金融服务有限公司. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)buttonclick:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    [self.navigationController pushViewController:[story instantiateInitialViewController] animated:YES];
    
}



@end
