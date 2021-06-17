
#import "EventEmitManager.h"


#define NATIVE_TO_RN_ONNOFIFICATION @"onNotification"

#define NATIVE_ONNOFIFICATION @"native_onNotification"

@implementation EventEmitManager{
  bool hasListeners;
}

RCT_EXPORT_MODULE()

-(NSArray*)supportedEvents {
  
  return@[NATIVE_TO_RN_ONNOFIFICATION];
  
}

- (void)nativeSendNotificationToRN:(NSNotification*)notification {
  
  NSLog(@"NativeToRN notification.userInfo = %@", notification.userInfo);
  
  if (hasListeners) {
    
    [self sendEventWithName:NATIVE_TO_RN_ONNOFIFICATION body:notification.userInfo];
      
  }

}

- (void)startObserving {
  
  hasListeners = YES;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nativeSendNotificationToRN:) name:NATIVE_ONNOFIFICATION object:nil];

}

- (void)stopObserving {
  
   hasListeners = NO;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NATIVE_ONNOFIFICATION object:nil];

}

@end


