//
//  LibraryController.h
//  Kamu
//
//  Created by YGTech on 2018/1/9.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"
#import "DateScroll-Swift.h"

//@class LibraryController;
//@protocol mediaLibControllerDelegate <NSObject>
//- (void)handle:(LibraryController *)libController sender:(HMSegmentedControl *)sgc;
//@end






@interface LibraryController : UIViewController


//@property (nonatomic, weak)   id<mediaLibControllerDelegate> delegate;
@property (nonatomic, strong)  ScrollableDatepicker* datepicker;


@end
