//
//  Device.m


#import "Device.h"


@implementation Device

+ (NSArray *)ignoredProperties {

    //@"deviceHandle"
    return @[@"nvr_pwd",
             @"nvr_h",
             @"nvr_status",
             @"nvr_tag",
             @"alarmShowed",
             @"nvr_data",
             @"delegate"];
}


//- (void *)nvr_h {
//    if (!_nvr_h && _nvr_id) {
//        _nvr_h = cloud_create_device([self.nvr_id UTF8String]);
//    }
//    return _nvr_h;
//}

//- (void)setNvr_id:(NSString *)nvr_id {
//    if (nvr_id != _nvr_id) {
//        _nvr_h  = cloud_create_device([self.nvr_id UTF8String]);
//    }
//}
@end

