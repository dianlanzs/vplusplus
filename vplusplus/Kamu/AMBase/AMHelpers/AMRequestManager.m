//
//  AMRequestManager.m
//  测试Demo
//
//  Created by YGTech on 2018/3/20.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "AMRequestManager.h"



@interface AMRequestManager () 

@end

@implementation AMRequestManager


+ (instancetype)defaultManager{
    
    static AMRequestManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //一个App通常访问的服务器是固定的注意： 末尾需要包含 ‘/’
        
        NSURL *url =[NSURL URLWithString:@"http://push.iotcplatform.com/"];
        //        sharedInstance = (AMRequestManager *)[AFHTTPSessionManager manager];
        sharedInstance =[[self alloc] initWithBaseURL:url];  //只初始化一次父类配置
        
        
        
        //默认提交请求的数据是二进制的,返回格式是JSON,  如果提交数据是JSON的,需要将请求格式设置为AFJSONRequestSerializer
        sharedInstance.requestSerializer = [AFJSONRequestSerializer serializer];
        
        // AFHTTPResponseSerializer就是正常的HTTP请求响应结果: NSData
        // 当请求的返回数据不是JSON,XML,PList,UIImage之外,使用AFHTTPResponseSerializer
        // 例如返回一个html,text...实际上就是AFN没有对响应数据做任何处理的情况
        sharedInstance.responseSerializer = [AFHTTPResponseSerializer serializer];//申明返回的结果是json类型
        sharedInstance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                                    @"text/json",
                                                                    @"text/javascript",
                                                                    @"text/html", nil];
        
        
        
        
        
        //================= 检测网络状况 =====================
        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
       
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    NSLog(@"未知网络");
                    break;
                    
                case AFNetworkReachabilityStatusNotReachable:
                    NSLog(@"无法联网");
                    //                    [AMAlertWindow alert:@"" message:LS(@"NoNetwork") confirm:LS(@"ISeeConfirm") action:nil];
                    [MBProgressHUD showError:@"NoNetWork"];
                    break;
                    
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    NSLog(@"WiFi");
                    break;
                    
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    NSLog(@"蜂窝网络");
                    break;
                    
                default:
                    break;
            }
        }];
        
        
        
         [manager startMonitoring];
        
        
    });
    
    return sharedInstance;
    

}

//-(void)request:(AMRequestMethod)method urlString:(NSString *)urlString parameters:(id)parameters finished:(void (^)(id responseObject,NSError *error))finished{
//    
//    NSString *methodName = (method == GET)? @"GET":@"POST";
//    
//    // dataTaskWithHTTPMethod本类没有实现方法 == （没有重写父类方法），但是父类实现了
//    // 在调用方法的时候，如果本类没有提供，直接调用父类的方法，AFN 内部已经实现！
//    //    [AMRequestManager defaultManager]
//    [[ self dataTaskWithHTTPMethod:methodName URLString:urlString  parameters:parameters uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        finished(responseObject,nil);
//        
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        finished(nil,error);
//    }] resume];
//    
//    
//}

@end
