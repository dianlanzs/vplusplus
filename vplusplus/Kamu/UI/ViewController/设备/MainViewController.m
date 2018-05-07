
//  MainViewController.m
//  Kamu
//
//  Created by YGTech on 2017/12/4.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "MainViewController.h"
#import "SpecViewController.h"
#import "PlayVideoController.h"


#import "AddCamsViewController.h"

#import "UIBarButtonItem+Item.h"

#import "NSAttributedString+Attributes.h"

#import "QRResultCell.h"
#import "DeviceListCell.h"


#import "AppDelegate.h"

#import "MGSwipeButton.h"
#import "ReactiveObjC.h"



#import "DataBuilder.h"
#import "NvrSettingsController.h"



@interface MainViewController() <UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate>

@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) RLMResults<Device *> *results;
@property (nonatomic, strong) RLMNotificationToken *token;

@end




@implementation MainViewController



#pragma mark - 生命周期方法
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"设备";
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.view addSubview:self.tableView];
    
    __weak typeof (self) ws = self;
    self.token = [self.results addNotificationBlock:^(RLMResults<Device *> * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        if (!results.count) {
            [ws.tableView setTableHeaderView:ws.emptyView];
            ws.navigationItem.rightBarButtonItem = nil;
            ws.tableView.scrollEnabled = NO;
        }else{
            [ws.tableView setTableHeaderView:nil];
            ws.tableView.scrollEnabled = YES;
            if (!ws.navigationItem.rightBarButtonItem) {
                [ws setNavBar];
            }
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNew:) name:@"addNew" object:nil];

}

- (void)addNew:(NSNotification *)notification {
    
    [RLM transactionWithBlock:^{
        [RLM addObject:notification.object]; //KVO-Comapliant
    }];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.results.count - 1] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)delete:(NSIndexPath *)path {
    [RLM transactionWithBlock:^{
        [RLM deleteObject:[self.results objectAtIndex:path.section]];
    }];
    
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:path.section] withRowAnimation:UITableViewRowAnimationTop];
    //  cloud_destroy_device(deleteDevice.nvr_h);
}
    
- (void)setNavBar {
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barItemWithimage:[UIImage imageNamed:@"nav_add"]  highImage:nil target:self action:@selector(addNvr:) title:@"添加新设备"];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    // 移除当前对象监听的事件（从列表中移除该观察者）//当vc pop掉之后,防止通知中心转发消息 再次访问该vc造成crash!!
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotate {
    return NO;
}


#pragma mark - Table view 数据源回调方法
//swipe  删除会调用 numberOfSection  ，和 numberOfRows 方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"section");
    return self.results.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"row");
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     NSLog(@"cell");
    Device *nonCams_device = self.results[indexPath.section];
    if (nonCams_device.nvr_type == CLOUD_DEVICE_TYPE_GW) {
        QRResultCell *nvrCell = [[QRResultCell alloc] init];
        tableView.rowHeight = 300; //110*2 + 60 （itemH *2  + topBar ）
        [nvrCell setNvrModel:nonCams_device];
        
        __weak typeof (self) weakself = self;
        __weak typeof (nvrCell) weakNvrCell = nvrCell;
        
        //设置中继
        weakNvrCell.setNvr = ^(QRResultCell *nvrCell){
            QRootElement *rootForm = [[DataBuilder new] createForNvrSettings:nvrCell]; //创建数据
            NvrSettingsController *nvrSettingsVc = [[NvrSettingsController alloc] initWithRoot:rootForm];
            [weakself.navigationController pushViewController:nvrSettingsVc  animated:YES];
        };
        
        weakNvrCell.play = ^(QRResultCell *nvrCell, NSIndexPath *indexPath) {
            
            PlayVideoController *playVc = [PlayVideoController new];
            playVc.cam = nvrCell.nvrModel.nvr_cams[indexPath.row];
            playVc.indexpath = indexPath;
            playVc.nvr_h = nonCams_device.nvr_h;
            playVc.nvrCell = nvrCell;
            [weakself.navigationController pushViewController:playVc animated:YES];
        };
        
        //添加cam
        weakNvrCell.add = ^(QRResultCell *cell, NSIndexPath *path) {
            
            AddCamsViewController *addCamVc = [AddCamsViewController new];
            addCamVc.nvrCell = cell;
            addCamVc.indexPath = path;
            [addCamVc.view setBackgroundColor:[UIColor whiteColor]];
            [self.navigationController pushViewController:addCamVc animated:YES];
        };
        
        
        
        nvrCell.delegate = self;
        return nvrCell;
    }
    
    //IPC
    if (nonCams_device.nvr_type == CLOUD_DEVICE_TYPE_IPC) {
        
        tableView.rowHeight = 200;
        DeviceListCell *ipcCell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceListCell class]) forIndexPath:indexPath];
        ipcCell.ipcModel = nonCams_device;
        ipcCell.delegate = self;
        return ipcCell;
    }
    
    return nil;
}


#pragma mark - getter

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.tableFooterView = [UIView new];        //去除分隔线
        [_tableView setShowsVerticalScrollIndicator:NO];
        
        _pullRefresh = [[UIRefreshControl alloc] init];
        _pullRefresh.tintColor = [UIColor lightGrayColor];
        _pullRefresh.attributedTitle = [NSAttributedString attrText:@"正在刷新..." withFont:[UIFont systemFontOfSize:15.f] color:[UIColor lightGrayColor] aligment:NSTextAlignmentCenter];
        [_pullRefresh addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:_pullRefresh];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //注册 Cell
        [_tableView registerClass:[DeviceListCell class] forCellReuseIdentifier:NSStringFromClass([DeviceListCell class])];
    }
    
    return _tableView;
    
}


- (void) handleRefresh:(UIRefreshControl *)sender{
    
    NSInteger idx = 0;
    for (Device *nvr in self.results) {
        if (nvr.nvr_status != 1 && nvr.nvr_status !=0) {
            
            NSLog(@"[nvr_status = %d]",nvr.nvr_status);
            
            //re-connect
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                nvr.nvr_status = cloud_connect_device(nvr.nvr_h, "admin", "123");
            });
            
            //animation
           QRResultCell * c = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:idx]];
            [c.spinner startAnimating];
            [c.spinner setColor:[UIColor colorWithHex:@"800000"]];
            [c.statusLb setHidden:YES];
        }
        idx++;
    }
    
    
    
    [sender endRefreshing];
    
}

//无数据展现视图
- (UIView *)emptyView {
    
    
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:self.tableView.bounds];
        _emptyView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        //添加按钮
        MRoundedButton *addButton = [[MRoundedButton alloc] initWithFrame:CGRectZero buttonStyle:MRoundedButtonCentralImage appearanceIdentifier:@"11"];
        addButton.imageView.image = [[UIImage imageNamed:@"add2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [addButton addTarget:self action:@selector(addNvr:) forControlEvents:UIControlEventTouchUpInside];
        //富文本
        UILabel *titleLabel = [UILabel labelWithText:@"欢迎进入视佳新界面！" withFont:[UIFont boldSystemFontOfSize:25.0f] color:[UIColor darkGrayColor] aligment:NSTextAlignmentCenter];
        UILabel *describeLabel = [UILabel labelWithText:@"点击此处'➕'按钮，扫描设备底部二维码，添加一个摄像机设备" withFont:[UIFont systemFontOfSize:18.0f] color:[UIColor lightGrayColor] aligment:NSTextAlignmentCenter];
        
        //添加控件
        [_emptyView addSubview:addButton];
        [_emptyView addSubview:titleLabel];
        [_emptyView addSubview:describeLabel];
        
        //设置约束
        [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_emptyView);
            make.size.mas_equalTo(CGSizeMake(100 , 100));
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_emptyView).offset(15);
            make.trailing.equalTo(_emptyView).offset(15);
            make.bottom.equalTo(describeLabel.mas_top).offset(- 20);
        }];
        [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_emptyView).offset(15);
            make.trailing.equalTo(_emptyView).offset(- 15);
            make.bottom.equalTo(addButton.mas_top).offset(- 40);
        }];
    }
    
    return _emptyView;
}

- (void)addNvr:(id)sender {
    [self.navigationController pushViewController:[SpecViewController new] animated:YES];
}




#pragma mark - MGSwipeCell delegate
- (BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    
    //fromExpansion : 是否来自（设置了）扩展 == NO ，不扩展
    if (direction == MGSwipeDirectionRightToLeft && index == 0 && fromExpansion == NO) {
        //会刷新 tableView ，---> QRcv 也会刷新
        //        QRResultCell * nvrCell = (QRResultCell * )cell ;
        //        [nvrCell.tempCams removeAllObjects];
        
        
        
        Popup *p = [[Popup alloc] initWithTitle:@"提示" subTitle:@"请确认是否需要删除该设备？" cancelTitle:@"取消" successTitle:@"确认" cancelBlock:nil successBlock:^{
            [self delete:[self.tableView indexPathForCell:cell]];
        }];
        [p setBackgroundBlurType:PopupBackGroundBlurTypeDark];
        [p setIncomingTransition:PopupIncomingTransitionTypeEaseFromCenter];
        [p showPopup];
        
        
        return YES; //不隐藏，展现扩展button 动画
    }
    return YES;// @return YES隐藏当前的 buttons
}

//返回 button 数组 和样式
- (NSArray *)swipeTableCell:(MGSwipeTableCell *) cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    swipeSettings.transition = MGSwipeTransitionStatic;
    /*
     if (direction == MGSwipeDirectionRightToLeft) {
     //扩展动画设置
     expansionSettings.buttonIndex = 0;
     expansionSettings.fillOnTrigger = NO;
     return [self createRightButtons:1];
     }
     */
    
    if (direction == MGSwipeDirectionRightToLeft) {
        return [self createRightButtons:1];
    }
    
    return nil;
}


//创建右侧按钮
- (NSArray *)createRightButtons: (int) number {
    
    NSMutableArray *result = [NSMutableArray array];
    //    NSString *titles[1] = {@"删除"};
    UIColor  *colors[1] = {[UIColor redColor]};
    UIImage *image = [[UIImage imageNamed:@"trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    for (int i = 0; i < number; ++i) {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:@"" icon:image backgroundColor:colors[i] padding:10.0f callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            NSLog(@"Convenience callback received (right).");
            BOOL autoHide = ( i != 0 );
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        
        button.tintColor = [UIColor whiteColor];
        [result addObject:button];
    }
    
    return result;
}

#pragma mark - getter

- (RLMResults<Device *> *)results {
    return [Device allObjects];
}
@end
