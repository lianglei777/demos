//
//  RCTFaceDetectView.h
//  KIOSK
//
//  Created by 魏良磊 on 2019/8/15.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTViewManager.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTComponent.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTFaceDetectView : UIView

// 组件回调方法
@property(nonatomic,copy)RCTBubblingEventBlock onFaceCallback;
//传入的美颜参数
@property(nonatomic,copy)NSString *beautyLevel;

+ (instancetype)sharedInstance; // 单例
- (UIView *)initBeautifyFaceView;  // 初始化相机界面

//相机切换前后摄像头
- (void)switchCameraFrontOrBack;
//拍照
-(void)takeFaceDetectCamera:(RCTResponseSenderBlock)successBlock;

//设置美颜系数
-(void)setBeautyLevel:(NSString *)level;

// 停止相机捕捉
-(void)stopCamera;

- (void)unobserveGlobalNotifications;

@end

NS_ASSUME_NONNULL_END
