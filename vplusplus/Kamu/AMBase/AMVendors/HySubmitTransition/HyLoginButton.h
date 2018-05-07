//
//  HyLoglnButton.h
//  Example
//
//  Created by  东海 on 15/9/2.
//  Copyright (c) 2015年 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HySpinerLayer.h"

typedef void(^HyAnimationCompletion)();

@interface HyLoginButton : UIButton

@property (nonatomic, strong) HySpinerLayer *spinerLayer;
- (void)scaleAnimation;
- (void)scaleToSmall;

-(void)failedAnimationWithCompletion:(HyAnimationCompletion)completion;

-(void)succeedAnimationWithCompletion:(HyAnimationCompletion)completion;

@end
