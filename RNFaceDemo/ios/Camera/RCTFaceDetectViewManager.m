//
//  RCTFaceDetectViewManager.m
//  KIOSK
//
//  Created by 魏良磊 on 2019/8/15.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RCTFaceDetectViewManager.h"
#import "RCTFaceDetectView.h"

@implementation RCTFaceDetectViewManager


RCT_EXPORT_MODULE();
RCT_EXPORT_VIEW_PROPERTY(onFaceCallback, RCTBubblingEventBlock) // 识别人脸回调方法
RCT_EXPORT_VIEW_PROPERTY(beautyLevel, NSString) // 美颜程度


- (UIView *)view {
  
  return [[RCTFaceDetectView sharedInstance] initBeautifyFaceView];

}


@end
