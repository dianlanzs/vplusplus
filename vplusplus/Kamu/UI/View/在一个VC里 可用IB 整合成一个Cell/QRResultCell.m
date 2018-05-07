//
//  QRResultCell.m
//  Kamu
//
//  Created by YGTech on 2017/12/7.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "QRResultCell.h"
#import "NSString+StringFrame.h"

#import "PlayVideoController.h"

#import "ReactiveObjC.h"
@interface QRResultCell()<UICollectionViewDelegate,UICollectionViewDataSource>

//设备信息
@property (strong, nonatomic) UIImageView *deviceLogo;



//播放视图
@property (strong, nonatomic) UICollectionViewFlowLayout *QRflowLayout;


//顶部Bar

@property (strong, nonatomic) UIButton *settingsBtn;
@property (nonatomic, strong) UIImageView *idIcon;
@property (nonatomic, strong) NSTimer *timer;



@end


@implementation QRResultCell



- (void)updateNvr:(void *)nvrHandle withState:(cloud_device_state_t)state  {

    
    if (nvrHandle == self.nvrModel.nvr_h) {
        
        [self.spinner stopAnimating];
        if (state == CLOUD_DEVICE_STATE_CONNECTED) {
            [self.statusLb setText:@"ON-LINE"];
            [self.deviceLogo setTintColor:[UIColor greenColor]];
            [self.statusLb setTextColor:[UIColor greenColor]];
            //connect success , update device cams
            [self upadteCams];
        } else {
            
            if (state ==  CLOUD_DEVICE_STATE_DISCONNECTED) {
                [self.statusLb setText:@"DISCON"];
            }else if (state == CLOUD_DEVICE_STATE_AUTHENTICATE_ERR) {
                [self.statusLb setText:@"AUTH_ERR"];
            }else if (state == CLOUD_DEVICE_STATE_OTHER_ERR) {
                [self.statusLb setText:@"OTHER_ERR"];
            }else if (state == CLOUD_DEVICE_STATE_UNKNOWN) {
                [self.statusLb setText:@"UNKNOWN"];
            }
            
            [self.deviceLogo setTintColor:[UIColor redColor]];
            [self.statusLb setTextColor:[UIColor redColor]];
        }
        self.nvrModel.nvr_status = state;
        [self.statusLb setHidden:NO];
        [self.QRcv reloadData];
    }
  
}

#pragma mark - 生命周期
// Designated initializer.  If the cell can be reused, you must pass in a reuse identifier.  You should use the same reuse identifier for all cells of the same form.  
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        [self.contentView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.topView]; //高度:60
        [self.contentView addSubview:self.QRcv];
        //约束：
        [self.QRcv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_bottom).offset(0);
            make.leading.equalTo(self.contentView).offset(15.0f);
            make.trailing.equalTo(self.contentView).offset(-15.0f);
            make.height.mas_equalTo(220); //100 * 2  +20
        }];
    }
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return self;
}




#pragma mark - 视图数据源和代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.nvrModel.nvr_cams.count < 4 ? 4 : self.nvrModel.nvr_cams.count;
   
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     NSLog(@"2");
    //会注册多次，可以不使用 reuseID
    [self.QRcv registerClass:[VideoCell class] forCellWithReuseIdentifier: [NSString stringWithFormat:@"%@",indexPath]];
    VideoCell *videoCell = [self.QRcv dequeueReusableCellWithReuseIdentifier:[NSString stringWithFormat:@"%@",indexPath] forIndexPath:indexPath];
    
    
    videoCell.nvr_status = _nvrModel.nvr_status;//告诉 videocell nvr 状态
        if (indexPath.item < self.nvrModel.nvr_cams.count) { //并且 防止数组越界
            [videoCell setCam:self.nvrModel.nvr_cams[indexPath.row]];
        }else {
            [videoCell setCam:nil];
        }
    return videoCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_nvrModel.nvr_status == CLOUD_DEVICE_STATE_CONNECTED) {
        indexPath.item < self.nvrModel.nvr_cams.count ? self.play(self, indexPath) :  self.add(self, indexPath);
    }
    
    
    else if (_nvrModel.nvr_status == CLOUD_DEVICE_STATE_UNKNOWN) {
        [MBProgressHUD showPromptWithText:@"正在连接中...请等待"];
    }else {
        [MBProgressHUD showPromptWithText:@"设备已离线，请检查网络"];
        return;
    }
    
    

}




#pragma mark - Required!！
- (UICollectionViewFlowLayout *)QRflowLayout {
    
    if (!_QRflowLayout) {
        _QRflowLayout = [[UICollectionViewFlowLayout alloc] init];
        // _QRflowLayout.estimatedItemSize = CGSizeMake(AM_SCREEN_WIDTH , 200); //预估宽高 ，Cell约束高度宽度
        if (@available(iOS 10.0, *)) {
            _QRflowLayout.itemSize = UICollectionViewFlowLayoutAutomaticSize;
        } else {
            // Fallback on earlier versions
        }
        _QRflowLayout.itemSize = CGSizeMake( (AM_SCREEN_WIDTH - 40) * 0.5, 100);//80+30
        _QRflowLayout.minimumInteritemSpacing = 10;
        _QRflowLayout.minimumLineSpacing = 10.f;
        _QRflowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _QRflowLayout;
}


#pragma mark - cams
- (void)upadteCams{
    
    device_cam_info_t ipc_info[4];
    int camsNum = cloud_device_get_cams(self.nvrModel.nvr_h, 4, ipc_info);
    NSLog(@"==== 获取Cams:%d ====",camsNum);
    if (camsNum) {
        
        for (NSInteger i = 0; i < camsNum; i++) {
            
            Cam *searchedCam = [Cam new];
            searchedCam.cam_id = [NSString stringWithUTF8String:ipc_info[i].camdid];
            searchedCam.cam_h = ipc_info[i].index;
            
            
            
            
            RLMArray *db_cams = self.nvrModel.nvr_cams;
            Cam *db_cam =  [[db_cams objectsWhere:[NSString stringWithFormat:@"cam_id = '%@'",searchedCam.cam_id]] firstObject];
            if (!db_cam) {
                [RLM transactionWithBlock:^{
                    [self.nvrModel.nvr_cams addObject:searchedCam]; //if 别人往中继 添加cam？？
                }];
            } 
          
            
        }
        
    }
    
}


- (void)setNvrModel:(Device *)nvrModel {
    
    if (_nvrModel != nvrModel) {
        
        _nvrModel = nvrModel;
        _nvrModel.nvr_h = cloud_create_device([self.nvrModel.nvr_id UTF8String]);
        cloud_set_data_callback(nvrModel.nvr_h, my_device_callback, (__bridge void *) self);
        cloud_set_status_callback(nvrModel.nvr_h,my_device_callback,(__bridge void *) self);
        cloud_set_event_callback(nvrModel.nvr_h, my_device_callback,(__bridge void *) self);
        
        
        if (_nvrModel.nvr_status == CLOUD_DEVICE_STATE_UNKNOWN) {
            [self.spinner startAnimating];
//            UIView *maskView = [[UIView alloc] initWithFrame:self.QRcv.bounds];
//            maskView.alpha = 0.5;
//            [maskView setBackgroundColor:[UIColor redColor]];
//            [self.QRcv setMaskView:maskView];
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                cloud_connect_device(_nvrModel.nvr_h, "admin", "123");
            });
        }
        
        //set nvr name
        if ([nvrModel.nvr_name length]) {
            
            [self.deviceLb setText:[NSString stringWithFormat:@" %@ ",nvrModel.nvr_name]];
            [self.deviceLb setBackgroundColor:[UIColor blueColor]];
            [self.deviceLb setTextColor:[UIColor whiteColor]];
            [self.deviceLb.layer setCornerRadius:3.f];
            [self.deviceLb.layer setMasksToBounds:YES];
        }else {
            [self.deviceLb setText:[NSString stringWithFormat:@"%@",nvrModel.nvr_id]];
        }
        

    }
    
   
  
    
    //默认 展现 DB 的cams
//    [self showRLMCams];

}

int my_device_callback(cloud_device_handle handle,CLOUD_CB_TYPE type, void *param,void *context) {
    
    Device *d = [[Device alloc] init];
    QRResultCell *ctx = (__bridge QRResultCell *)context;

    if (type == CLOUD_CB_STATE) {
        cloud_device_state_t state = *((cloud_device_state_t *)param);
        dispatch_async(dispatch_get_main_queue(), ^{
            [ctx updateNvr:handle withState:state];
        });
    }
    
    else if (type == CLOUD_CB_VIDEO || type == CLOUD_CB_AUDIO ){
        

            [ctx.nvrModel.delegate device:ctx.nvrModel sendData:param dataType:type];

        
    }
    
    
    else if (type == CLOUD_CB_RECORD_LIST) {
  
       [ctx.nvrModel.delegate device:ctx.nvrModel sendData:param dataType:type];

        
    }
    
    
    
    else if (type == CLOUD_CB_ALARM){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (d.alarmShowed == 0) {
                d.alarmShowed = 1;
                Popup *p_alarm = [[Popup alloc] initWithTitle:@"alarm" subTitle:[NSString stringWithUTF8String:"test"] cancelTitle:nil successTitle:@"ok" cancelBlock:nil successBlock:^{
                    d.alarmShowed = 0;
                }];
                [p_alarm showPopup];
            }
        });
    }
    
    return 0;
}

#pragma mark - Collection View 设置
- (UICollectionView *)QRcv {
    
    if (!_QRcv) {
        
        //      NSInteger muti = (self.device.ipcCount * 0.5) + (self.device.ipcCount % 2);
        _QRcv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.QRflowLayout];
        
        
        //设置代理 数据源
        _QRcv.dataSource = self;
        _QRcv.delegate = self;
        
        //设置 cv 背景色
        [_QRcv setBackgroundColor:[UIColor whiteColor]];
    }
    
    return _QRcv;
    
}


///MARK:UI -顶部视图
- (UIView *)topView {
    
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(8, 0, AM_SCREEN_WIDTH - 16, 80)];
        [_topView setBackgroundColor:[UIColor whiteColor]];
        
        _deviceLogo = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_deviceLogo setContentMode:UIViewContentModeScaleAspectFit];
        UIImage *deviceLogo = [[UIImage imageNamed:@"button_nvr"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_deviceLogo setImage:deviceLogo];
        [_deviceLogo setTintColor:[UIColor lightGrayColor]]; //默认是浅灰色
        
        
        _statusLb = [[UILabel alloc] initWithFrame:CGRectZero];

        [_statusLb setText:@""];  //设置设备状态 默认值，
        [_statusLb setTextColor:[UIColor lightGrayColor]];
        [_statusLb setFont:[UIFont systemFontOfSize:15.0f]];
        
        _deviceLb = [[UILabel alloc] initWithFrame:CGRectZero];
        [_deviceLb setFont:[UIFont systemFontOfSize:17.0f]];
        
        _spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleThreeBounce color:[UIColor lightGrayColor] spinnerSize:20.f];
        [_spinner setHidesWhenStopped:YES];
        
        
        _settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_settingsBtn setTintColor:[UIColor blackColor]];
        UIImage *icon = [[UIImage imageNamed:@"button_settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_settingsBtn setImage:icon forState:normal];
        [_settingsBtn setContentMode:UIViewContentModeScaleAspectFit];
        [_settingsBtn addTarget:self action:@selector(entryAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //Top View
        [_topView addSubview:self.deviceLogo];
        [_topView  addSubview:self.statusLb];
        [_topView addSubview:self.deviceLb];
        [_topView addSubview:_spinner];
        [_topView  addSubview:self.settingsBtn];
        
        
        
        [_deviceLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_topView).offset(0.f);
            make.top.equalTo(_topView).offset(2.f);
            make.size.mas_equalTo(CGSizeMake(35,35));
        }];
        
        [_statusLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_deviceLogo.mas_centerY);
            make.leading.equalTo(_deviceLogo.mas_trailing).offset(2.f);
        }];
        
        [_spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_deviceLogo.mas_centerY).offset(-2.f);
            make.leading.equalTo(_deviceLogo.mas_trailing).offset(3.f);

        }];
    
        [_deviceLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([@"foo" boundingRectWithFont:[UIFont systemFontOfSize:15.f]]  + 5.f);
            make.top.equalTo(_topView.mas_centerY).offset(-2.f);
            make.leading.equalTo(_topView).offset(0.0f);
        }];
        
        ///中继 设置按钮
        [_settingsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_topView);
            make.size.mas_equalTo(CGSizeMake(20, 20.f));
            make.trailing.equalTo(_topView.mas_trailing).offset(-2.0f);
        }];
        
    }
    
    return _topView;
}

#pragma mark - 点击事件
- (void)entryAction:(UIButton *)entry {
    self.setNvr(self);
}

@end
