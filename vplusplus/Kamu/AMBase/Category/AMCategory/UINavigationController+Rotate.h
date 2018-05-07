//
//  UINavigationController+Rotate.h
//  XiaXianBing
//
//  Created by XiaXianBing on 2016-2-13.
//  Copyright © 2016年 XiaXianBing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Rotate)

- (BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

- (void)pushAnimationDidStop;
- (UIViewController *)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition;


@end
