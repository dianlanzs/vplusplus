//
//  UIWindow+CurrentViewController.m
//  Kamu
//
//  Created by YGTech on 2018/1/8.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "UIWindow+ZLCurrentViewController.h"


@implementation UIWindow (ZLCurrentViewController)

+ (UIViewController*)zl_currentViewController; {
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    UIViewController *topViewController = [window rootViewController];
    
    while (true) {
        
        if (topViewController.presentedViewController) {
            
            topViewController = topViewController.presentedViewController;
        }
        
        else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            
            topViewController = [(UINavigationController *)topViewController topViewController];
        }
        
        else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        }
        
        else {
            
            break;
        }
    }
    return topViewController;
}

@end

