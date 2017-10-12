//
//  ViewController.m
//  WKWebViewDemo
//
//  Created by Caofeng on 2017/10/11.
//  Copyright © 2017年 深圳中业兴融互联网金融服务有限公司. All rights reserved.
//

#define kHelloWorld @"helloworld"
#define kSay @"say"

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "WKDelegateController.h"
#import "NextViewController.h"

@interface ViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKDelegate>

@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic, strong)WKUserContentController *userContentController;

@end

@implementation ViewController

- (void)dealloc
{
    //这句一定要有
    [self.userContentController removeAllUserScripts];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    NSLog(@"释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    WKBackForwardList: 之前访问过的 web 页面的列表，可以通过后退和前进动作来访问到。
    WKBackForwardListItem: webview 中后退列表里的某一个网页。
    WKFrameInfo: 包含一个网页的布局信息。
    WKNavigation: 包含一个网页的加载进度信息。
    WKNavigationAction: 包含可能让网页导航变化的信息，用于判断是否做出导航变化.
    WKNavigationResponse: 包含可能让网页导航变化的返回内容信息，用于判断是否做出导航变化.
    WKPreferences: 概括一个 webview 的偏好设置。
    WKProcessPool: 表示一个 web 内容加载池.
    WKUserContentController: 提供使用 JavaScript post 信息和注射 script 的方法。
    WKScriptMessage: 包含网页发出的信息。
    WKUserScript: 表示可以被网页接受的用户脚本。
    WKWebViewConfiguration: 初始化 webview 的设置。
    WKWindowFeatures: 指定加载新网页时的窗口属性。
    */
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc]init];
    self.userContentController = [[WKUserContentController alloc]init];
    conf.userContentController = self.userContentController;
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) configuration:conf];
    
    
    
    //注册方法--JS调用原生
    WKDelegateController *delegateController = [[WKDelegateController alloc]init];
    delegateController.delegate = self;
    /*
    1.addScriptMessageHandler要和removeScriptMessageHandlerForName配套出现，否则会造成内存泄漏。
     
    2.h5只能传一个参数，如果需要多个参数就需要用字典或者json组装。
     */
    [self.userContentController addScriptMessageHandler:delegateController name:@"helloworld"];
    [self.userContentController addScriptMessageHandler:delegateController name:@"say"];
    //...在此可以注册很多方法

    
    /**********************------------*************************/
    NSString *inject = @"AppInjectJS('曹峰')";
    //原生传值给JS--方式1，
    [self.userContentController addUserScript:[[WKUserScript alloc]initWithSource:inject injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO]];
    //注入一个js端不存在的方法，完全没问题
    [self.userContentController addUserScript:[[WKUserScript alloc]initWithSource:@"hahhaha('hehehe')" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO]];

    
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        
        // Fallback on earlier versions
    }
    
    self.webView.navigationDelegate = self;
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hello" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    //监听进度
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
}

// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        NSLog(@"加载进度:%.2f",newprogress);
    }
}

#pragma mark---WKNavigationDelegate
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    //是否允许加载当前URL
    //WKNavigationActionPolicyCancel
    //WKNavigationActionPolicyAllow
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    //是否允许响应
    //WKNavigationResponsePolicyAllow
    //WKNavigationResponsePolicyCancel
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 接收到服务器跳转请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
}

#pragma mark----------
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"开始加载");
    
    //OC注入JS方式二，在此注入会失败
    //NSString *inject = @"AppInjectJS('caofeng')";
//    [webView evaluateJavaScript:inject completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//        NSLog(@"==response:%@",response);
//    }];
}

//网页加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"开始失败");
    
}
 // 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"内容开始返回");
}
//网页加载完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    
    //OC注入JS方式二，在网页加载完成时可以注入成功
    NSLog(@"加载完成");
    NSString *inject = @"AppInjectJS('caofeng')";
    [webView evaluateJavaScript:inject completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"==response:%@",response);
    }];
}

/*
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
}
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
}
*/

#pragma mark---WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    //在这里获取js触发的方法名,根据方法名做原生动作----->JS调OC
    NSLog(@"name:%@ \n body:%@ \n",message.name,message.body);
    if ([message.name isEqualToString:kHelloWorld]) {
        NextViewController *vc = [[NextViewController alloc]initWithNibName:@"NextViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
