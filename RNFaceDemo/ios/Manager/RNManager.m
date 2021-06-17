//
//  RNManager.m
//  ReactNativeDemo
//
//  Created by 魏良磊 on 2021/3/9.
//

#import "RNManager.h"

#import "AppDelegate.h"



@implementation RNManager

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

RCT_REMAP_METHOD(sendMegToNative,
                 :(NSString *)one
                 :(NSString *)two
                 :(NSString *)three
                 :(RCTResponseSenderBlock)successCallBack
                 :(RCTResponseSenderBlock)errorCallBack
//                 resolver:(RCTPromiseResolveBlock)resolve
//                 rejecter:(RCTPromiseRejectBlock)reject
                 ){
  
  NSLog(@"\n one ==> %@ \n two ==> %@ \n three ==> %@",one, two, three);
  
  
  NSString *title = one;
  NSString *message = two;
  NSString *cancelButtonTitle = @"取消";
  NSString *otherButtonTitle = @"确定";

  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
     
  // Create the actions.
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
       
      if(!errorCallBack){
        return;
      }
    
//       返回字符串
      errorCallBack(@[@"我不学"]);
    
//      if(!reject){
//        return;
//      }
//     NSError *error=[NSError errorWithDomain:@"回调错误信息..." code:101 userInfo:nil];
//     reject(@"no_events", @"There were no events", error);

  }];
     
  UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       
      if(!successCallBack){
        return;
      }
    
//     返回对象
    successCallBack(@[@{@"result" : @"连夜学"}]);
    
//    if(!resolve){
//      return;
//    }
//    resolve(@{@"result" : @"success promise"});
    
    
    }];
     
  
  // Add the actions.
  [alertController addAction:cancelAction];
  [alertController addAction:otherAction];
  
  
  AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
     
  [delegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];


}

@end
