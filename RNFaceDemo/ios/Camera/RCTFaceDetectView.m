//
//  RCTFaceDetectView.m
//  KIOSK
//
//  Created by 魏良磊 on 2019/8/15.
//  Copyright © 2019 Facebook. All rights reserved.
//


#import "RCTFaceDetectView.h"
#import "GPUImage.h"
#import "FSKGPUImageBeautyFilter.h"
#import "AppDelegate.h"


@interface RCTFaceDetectView ()<GPUImageVideoCameraDelegate,AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) GPUImageStillCamera *videoCamera; // 美颜相机
@property (nonatomic, strong) GPUImageView *filterView;  //

@property (nonatomic, strong) UIButton *switchButton; // 切换摄像头
@property (nonatomic, strong) UIButton *takePhotoButton; // 拍照
@property (nonatomic, strong) UIButton *beautifyButton; // 是否美颜按钮

@property (strong, nonatomic) AVCaptureMetadataOutput *medaDataOutput;
@property (strong, nonatomic) dispatch_queue_t captureQueue;

@property (nonatomic, strong) NSArray *faceObjects;
@property (nonatomic,strong) UILabel * faceBorderLab; // 人脸识别框
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer; // 预览layer

//BeautifyFace美颜滤镜（默认开启美颜）
@property (nonatomic, strong) FSKGPUImageBeautyFilter *beautifyFilter; // 美颜滤镜

//裁剪1:1
@property (strong, nonatomic) GPUImageCropFilter *cropFilter; // 裁剪滤镜
//滤镜组
@property (strong, nonatomic) GPUImageFilterGroup *filterGroup; // 滤镜组

@property (nonatomic, assign) BOOL isFront; // 判断是前置还是后置摄像头
@property (nonatomic, assign) BOOL isBeautify; // 判断是否开启美颜参数


@end


@implementation RCTFaceDetectView

// 单例
+ (instancetype)sharedInstance {
  static RCTFaceDetectView *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[super alloc] init];
  });
  return sharedInstance;
}

// 初始化界面
- (UIView *)initBeautifyFaceView{
  
  // 前后台切换通知
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
  
//  AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//  delegate.isUsingFaceCamera = true; // 使用美颜相机参数赋值
  
  self.isFront = true; // 默认前置
  self.isBeautify = true; // 默认美颜开
  
  self.captureQueue = dispatch_queue_create("com.gaiaworks.mosaiccamera.videoqueue", NULL);
  
  [self setupUI]; // 设置UI
  
  [self openBeautify]; // 开启美颜
  
  [self.videoCamera startCameraCapture]; // 开启视频捕捉
  
  
  self.videoCamera.horizontallyMirrorFrontFacingCamera = YES; // 前置拍照的时候不是镜像
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
  });
  
  // 配置会话
  self.medaDataOutput = [[AVCaptureMetadataOutput alloc] init];
  if ([self.videoCamera.captureSession canAddOutput:self.medaDataOutput]) {
    [self.videoCamera.captureSession addOutput:self.medaDataOutput];
    self.medaDataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace]; // 面部
    [self.medaDataOutput setMetadataObjectsDelegate:self queue:self.captureQueue];
  }
  
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 14.0f) { // iOS版本 >=14.0 ,解决人脸框不出来的问题,
      [self switchCameraFrontOrBack];
      [self switchCameraFrontOrBack];
  }
  
  return self;
}

- (void)onApplicationWillResignActive
{

    [self.videoCamera pauseCameraCapture];
    [self.videoCamera stopCameraCapture];

    runSynchronouslyOnVideoProcessingQueue(^{
        glFinish();
    });
  
}

- (void)onApplicationDidBecomeActive
{

    [self.videoCamera resumeCameraCapture];
    [self.videoCamera startCameraCapture];
}

- (void)unobserveGlobalNotifications
{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)setupUI {
  
  // 设置相机界面全屏
  CGSize keyWindownSize = [UIApplication sharedApplication].keyWindow.bounds.size;
  self.frame = CGRectMake(0, 0, keyWindownSize.width, keyWindownSize.height);
  
  //  初始化美颜相机
  self.videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
  
  
  self.videoCamera.delegate = self;
  self.videoCamera.videoCaptureConnection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
  self.videoCamera.outputImageOrientation = UIInterfaceOrientationLandscapeLeft;
//  self.videoCamera.horizontallyMirrorFrontFacingCamera = YES; // 前置拍照的时候不是镜像
  
  
  //  预览图层，
  self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.videoCamera.captureSession];
  self.previewLayer.frame = self.frame;
  self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  [self.layer addSublayer:self.previewLayer];
  
  //  初始化滤镜 view
  self.filterView = [[GPUImageView alloc] initWithFrame:self.frame];
  self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
  [self addSubview:self.filterView];
  
  //初始化剪裁滤镜（1:1）
  self.cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 1)];

  
  self.beautifyFilter = [[FSKGPUImageBeautyFilter alloc] init];
  self.beautifyFilter.beautyLevel = 0.9f; //美颜程度  0.9f
  self.beautifyFilter.brightLevel = 0.3f; //美白程度  0.7f
  self.beautifyFilter.toneLevel = 0.2f; //色调强度  0.9f

  //滤镜添加到滤镜组
  self.filterGroup = [[GPUImageFilterGroup alloc] init];
  [self.filterGroup addFilter:self.cropFilter];
  [self.filterGroup addFilter:self.beautifyFilter];
  
  // 人脸识别框
  [self addSubview:self.faceBorderLab];
  
}

// 停止相机捕捉
-(void)stopCamera{
  
  [self.videoCamera stopCameraCapture]; // 停止视频捕捉
  
//  AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//  delegate.isUsingFaceCamera = false; // 使用美颜相机参数赋值

}

// 横竖屏
- (AVCaptureVideoOrientation) videoOrientationFromCurrentDeviceOrientation {
  if(self.isFront){
    return AVCaptureVideoOrientationPortrait;
  }else{
    return AVCaptureVideoOrientationPortraitUpsideDown;
  }
}


//开启美颜
- (void)openBeautify {
  
  [self.filterGroup removeAllTargets];
  [self.videoCamera removeAllTargets];
  [self.beautifyFilter removeAllTargets];
  [self.cropFilter removeAllTargets];
  
  //加上美颜滤镜
  [self.cropFilter addTarget:self.beautifyFilter];
  self.filterGroup.initialFilters = @[self.cropFilter];
  self.filterGroup.terminalFilter = self.beautifyFilter;
  [self.videoCamera addTarget:self.filterGroup];
  [self.filterGroup addTarget:self.filterView];
  
}


//关闭美颜
- (void)closeBeautify {
  
  [self.filterGroup removeAllTargets];
  [self.videoCamera removeAllTargets];
  [self.beautifyFilter removeAllTargets];
  [self.cropFilter removeAllTargets];
  
  self.filterGroup.initialFilters = @[self.cropFilter];
  self.filterGroup.terminalFilter = self.cropFilter;

  [self.videoCamera addTarget:self.filterGroup];
  [self.filterGroup addTarget:self.filterView];
  
}


// 设置美颜系数
//-(void)setBeautyLevel:(NSString *)level{
//  self.beautifyFilter.beautyLevel = [level floatValue];
//}


#pragma make - 切换摄像头、拍照、美颜开关
// 切换摄像头
- (void)switchCameraFrontOrBack {
    
    self.isFront = !self.isFront;
    [self.videoCamera rotateCamera];
    self.videoCamera.videoCaptureConnection.videoOrientation = [self videoOrientationFromCurrentDeviceOrientation];
    self.faceBorderLab.hidden = YES;
    
}

// 拍照
-(void)takeFaceDetectCamera:(RCTResponseSenderBlock)successBlock{
  
  [self.videoCamera capturePhotoAsJPEGProcessedUpToFilter:self.videoCamera.targets.firstObject withCompletionHandler:^(NSData *processedJPEG, NSError *error) {
    
    if (!error) {
      
      //  拍照照片
      UIImage *image = [UIImage imageWithData:processedJPEG];
      image = [self image:image rotation:UIImageOrientationLeft]; // 图片矫正
      
      //  图片转 base64
      NSString *base64Str = [UIImageJPEGRepresentation(image, 1) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
      
//      NSLog(@"美颜拍照图片base64Str -->%@", base64Str);
      successBlock(@[base64Str]);
      
    } else {
      successBlock(@[@""]);
    }
    
    
  }];
  
}


// 图片旋转矫正
- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

// 美颜开关方法
-(void)beautifyButtonAction{
    
    self.isBeautify = !self.isBeautify;
    if(self.isBeautify){
        [self openBeautify];
    }else{
        [self closeBeautify];
    }
}


//转换坐标
- (NSArray*)transformedFaces:(NSArray<AVMetadataFaceObject*>*)faces {
  
  NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:faces.count];
  for (AVMetadataFaceObject* face in faces) {
    
//    NSLog(@"transfromedFace 1 -->%@",NSStringFromCGRect(face.bounds));
    
    // 此方法将人脸在摄像头中的坐标转为在屏幕中的坐标
    AVMetadataObject *transfromedFace = [self.previewLayer transformedMetadataObjectForMetadataObject:face];
    
//    NSLog(@"transfromedFace 2-->%@",NSStringFromCGRect(transfromedFace.bounds));
    
    if(transfromedFace != nil) {
      [mArr addObject:transfromedFace];
    }
  }
  
  return [mArr copy];
}

// 添加人脸框
- (void)makeFaceWithCIImage:(CIImage *)inputImage{
  NSArray *transformedFaces = [self transformedFaces:self.faceObjects]; // 坐标转换
  for (AVMetadataFaceObject *faceObject in transformedFaces) { // 遍历人脸信息
    CGRect faceBounds = faceObject.bounds;
    dispatch_async(dispatch_get_main_queue(), ^{
      self.faceBorderLab.hidden = NO;
      self.faceBorderLab.frame = faceBounds;
    });
  }
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
  

  NSInteger faceCount = metadataObjects.count;
//  NSLog(@"faceCount -->%ld",(long)faceCount);
  
  //  回调 识别的面部个数，用于判断是否包含人脸
  if (self.onFaceCallback){
    self.onFaceCallback(@{@"detectFaceCount": [NSString stringWithFormat:@"%ld", (long)faceCount]});
  }
  
  self.faceObjects = metadataObjects;
}


#pragma mark - GPUImageVideoCameraDelegate
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
  
  CIImage *sourceImage;
  CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  sourceImage = [CIImage imageWithCVPixelBuffer:imageBuffer options:nil];
  
  if (self.faceObjects && self.faceObjects.count > 0) {
  
    [self makeFaceWithCIImage:sourceImage]; // 添加人脸框
    
  } else {
    
    dispatch_async(dispatch_get_main_queue(), ^{
      self.faceBorderLab.hidden = YES; // 隐藏人脸框
    });
    
  }
}

#pragma mark - lazy

- (UILabel *)faceBorderLab {
  if (_faceBorderLab == nil) {
    _faceBorderLab = [[UILabel alloc] init];
    _faceBorderLab.backgroundColor = [UIColor clearColor];
    _faceBorderLab.layer.borderColor = [UIColor colorWithRed:43/255.0 green:163/255.0 blue:254/255.0 alpha:1/1.0].CGColor;
    _faceBorderLab.layer.borderWidth = 2.0;
  }
  return _faceBorderLab;
}


- (void)setBeautyLevel:(NSString *)level{
  
  NSLog(@"setBeautyLevel -->%@", level);
  
  _beautyLevel = level ;
  
  self.beautifyFilter.beautyLevel = [level floatValue];
}

@end

