//
//  Device.h
#import "Cam.h"

#import <Foundation/Foundation.h>

//#import "IPC.h"
//#import "NVR.h"

typedef enum {
    
    ipc = 0,
    nvr = 1,
    
}nvr_type;



@class Device;
@protocol ZLNvrDelegate <NSObject>
- (void)device:(Device *_Nullable)nvr sendData:(void * _Nullable )data dataType:(int)type;
@end






@interface Device : RLMObject

///连接 状态handle ，null ,会引用这个指针 ,忽略属性
@property (nonatomic, assign) void * _Nullable nvr_h;
@property (nonatomic, assign) void * _Nullable nvr_data;
@property  int nvr_dataType;


@property  NSString * _Nullable nvr_pwd;
@property (nonatomic, weak)  id<ZLNvrDelegate> _Nullable delegate;

@property  NSString * _Nullable nvr_name;
@property (nonatomic, copy) NSString * _Nonnull nvr_id;

@property  int nvr_type;
@property  int nvr_status;
@property  int alarmShowed;





@property NSString * _Nullable nvr_tag;

@property RLMArray<Cam> * _Nullable nvr_cams;
@end

//这个宏表示支持RLMArray<Device>该属性、、        @throw RLMException(@"Property '%@' requires a protocol defining the contained type - example: RLMArray<Person>.", _name);

//RLM_ARRAY_TYPE (Cam)




