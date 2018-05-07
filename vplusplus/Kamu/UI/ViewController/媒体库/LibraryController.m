//
//  LibraryController.m
//  Kamu
//
//  Created by YGTech on 2018/1/9.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "LibraryController.h"
#import "UIBarButtonItem+Item.h"
#import "PageController.h"


@interface LibraryController ()<UIScrollViewDelegate,ScrollableDatepickerDelegate>



@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;


@property (nonatomic, strong) UILabel *selectedDateLb;

@end

@implementation LibraryController

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self createSegments];
    [self.segmentedControl setSelectedSegmentIndex:1];
    
    [self.view addSubview:self.selectedDateLb];
    [self.view addSubview:self.datepicker];
    

    [self setNavgation];
    [self makeConstraints];

    
    //contentSize == 0 ,不会走ScrollToRect方法
    //已经标记了？？可以直接调用 setNeedsLayout（标记需要 刷新tag)
    [self.view layoutIfNeeded]; //刷新有标记刷新的视图 ，同步调用layoutSubviews
//    self.automaticallyAdjustsScrollViewInsets = NO;///MARK:针对 根视图第一个添加scrollView vc会自动调整一段 内容 y值 的Inset
 
    [self addListController];//添加子控制器Page vc
//    UIViewController *vc = [self.childViewControllers firstObject];
//    [self.scrollView addSubview:vc.view];
//    vc.view.frame = self.scrollView.bounds;
//    [vc didMoveToParentViewController:self];

    
    
}

- (void)makeConstraints {
    //约束：
    [self.selectedDateLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedControl.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
    }];
    [self.datepicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.selectedDateLb.mas_bottom).offset(10);
        make.leading.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(self.view.frame), 50));
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.datepicker.mas_bottom).offset(10);
        make.leading.equalTo(self.view).offset(0);
        make.trailing.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
    }];
}
- (void)setNavgation {
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barItemWithTarget:self action:@selector(choose:) title:@"选择"];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barItemWithimage:[UIImage imageNamed:@"button_filter_normal"] highImage:[UIImage imageNamed:@"button_filter_normal"] target:self action:@selector(filter:) title:@"筛选"];
}
- (void)addListController {
    for (int i = 0 ; i <  self.segmentedControl.sectionTitles.count ;i++){
        PageController *page = [[PageController alloc] init];
        
        page.title = self.segmentedControl.sectionTitles[i];
//        page.URL = self.arrayLists[i][@"urlString"];
        [self addChildViewController:page];
        [page didMoveToParentViewController:self];

    }
}
- (void)filter:(id)sender {
    ;
}
- (void)choose:(id)sender {
    ;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setApperanceForLabel:(UILabel *)label {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    label.backgroundColor = color;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:23.0f];
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.scrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(self.view.frame) * self.segmentedControl.selectedSegmentIndex, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.scrollView.frame)) animated:YES];
    [self showSelectedDate];
}
- (void)createSegments {
  
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.scrollView];
  
    
//label indicator
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), AM_SCREEN_HEIGHT - 104)];
    [self setApperanceForLabel:label1];
    label1.text = @"SD卡";
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(self.view.frame), AM_SCREEN_HEIGHT - 104)];
    [self setApperanceForLabel:label2];
    label2.text = @"中继";
  
    /*
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(viewWidth * 2, 0, viewWidth, AM_SCREEN_HEIGHT - 104)];
    [self setApperanceForLabel:label3];
    label3.text = @"云存储";
    [self.scrollView addSubview:label3];
    */
    
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) * 3, 0, CGRectGetWidth(self.view.frame), AM_SCREEN_HEIGHT - 104)];
    [self setApperanceForLabel:label4];
    label4.text = @"本地";

    [self.scrollView addSubview:label1];
    [self.scrollView addSubview:label2];
    [self.scrollView addSubview:label4];
    
}


#pragma mark - getter
- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.backgroundColor = [UIColor redColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake((self.view.bounds.size.width) * 3, 1);
    }
    
    return _scrollView;
}
- (ScrollableDatepicker *)datepicker {
    
    if (!_datepicker) {
        _datepicker = [[ScrollableDatepicker alloc] initWithFrame:CGRectZero];
        [_datepicker setBackgroundColor:[UIColor lightGrayColor]];
        
        NSMutableArray *dateArray = [NSMutableArray array];
        for (int i = -5; i < 10; i++) {
            //3600s * 24 = 1 day
            [dateArray addObject:[NSDate dateWithTimeIntervalSinceNow:(i * 3600 * 24)]];
        }
        
        _datepicker.dates = dateArray;
        [_datepicker setSelectedDate:[NSDate date]];
        _datepicker.delegate = self;
        Configuration *configuration = [[Configuration alloc] init];
        configuration.weekendDayStyle.dateTextColor = [UIColor orangeColor];
        configuration.weekendDayStyle.dateTextFont = [UIFont boldSystemFontOfSize:20.f];
        configuration.weekendDayStyle.weekDayTextColor = [UIColor orangeColor];
        
        // 设置选中日期的 样式
        configuration.selectedDayStyle.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        //        configuration.daySizeCalculation = .numberOfVisibleItems(5)
        _datepicker.configuration = configuration;
        

        
    }
    
    return _datepicker;
}
// 选择的日期
- (UILabel *)selectedDateLb {
    
    if (!_selectedDateLb) {
        _selectedDateLb = [[UILabel alloc] init];
        _selectedDateLb.textAlignment = NSTextAlignmentCenter;
    }
    
    return _selectedDateLb;
}
- (HMSegmentedControl *)segmentedControl {
    
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame),40)];
        _segmentedControl.sectionTitles = @[@"SD卡", @"中继",@"本地"];
        _segmentedControl.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
        _segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor] ,
                                                  NSFontAttributeName :[UIFont fontWithName:@"HelveticaNeue" size:15.f]};
        
        _segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHex:@"0066ff"]};
        _segmentedControl.selectionIndicatorColor = [UIColor colorWithHex:@"0066ff"];
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.tag = 3;
        
        __weak typeof(self) weakSelf = self;
        [_segmentedControl setIndexChangeBlock:^(NSInteger index) {
            [weakSelf.scrollView scrollRectToVisible:CGRectMake(CGRectGetWidth(weakSelf.view.frame) * index, 0, CGRectGetWidth(weakSelf.view.frame), CGRectGetHeight(weakSelf.scrollView.frame)) animated:YES];
     
        }];
    }
    
    return  _segmentedControl;
}



#pragma mark - UIScrollViewDelegate

//manually drag  trigger
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    //计算ScrollView 宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
    
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
}


//code trigger
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    PageController *page = self.childViewControllers[self.segmentedControl.selectedSegmentIndex];
    if (!page.view.superview) {
        [self.scrollView addSubview:page.tableView];
        page.view.frame = scrollView.bounds;
        
    }
    
   
}




#pragma mark -  DatePickerDelegate
- (void)datepicker:(ScrollableDatepicker *)datepicker didSelectDate:(NSDate *)date {
    [self showSelectedDate];
}
//日期格式
- (void)showSelectedDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy-MM-dd";//@"dd-MMMM YYYY" yyyy-MM-dd HH:mm:ss ,默认  00:00:00
    self.selectedDateLb.text = [dateFormat stringFromDate:self.datepicker.selectedDate];
    [self.datepicker scrollToSelectedDateWithAnimated:YES];
    [self handle:self sender:self.segmentedControl];
}

- (void)handle:(LibraryController *)libController sender:(HMSegmentedControl *)sgc {
    
    //if index == base station  & online
    //get status
    NSLog(@"libVC 当前线程: %@",[NSThread currentThread]);

    
    if (sgc.selectedSegmentIndex == 1) {
        int sec = [libController.datepicker.selectedDate timeIntervalSince1970];
        
        //test: choose 0
        Device *coludDevice = [[Device allObjects] objectAtIndex:0];
        coludDevice.delegate = [self.childViewControllers objectAtIndex:sgc.selectedSegmentIndex];
        
        //主动获取设备状态
        cloud_device_state_t state = cloud_get_device_status(coludDevice.nvr_h);
        if (state == CLOUD_DEVICE_STATE_CONNECTED) {
            [MBProgressHUD showSpinningWithMessage:@"Downloading..."];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                cloud_device_cam_list_files(coludDevice.nvr_h,0,  sec,sec + 24 * 3600,RECORD_TYPE_ALL);
            });
        }else {
            //prompt device offline & connect
        }
        
        
        
    }
}



@end
