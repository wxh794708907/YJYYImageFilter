//
//  ViewController.m
//  YJYYImageFilter
//
//  Created by 遇见远洋 on 17/2/17.
//  Copyright © 2017年 遇见远洋. All rights reserved.
//

#import "ViewController.h"

#define ScreenWidth [self.view bounds].size.width
#define ScreenHeight [self.view bounds].size.height

@interface ViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
/** 数据源 */
@property(nonatomic,strong) NSArray *dataArray;
/** 显示数据 */
@property(nonatomic,strong) NSArray *pickerData;
/** 展示图 */
@property(nonatomic,strong) UIImageView *showImageV;
/** 原始图片 */
@property(nonatomic,strong) UIImage *originalImage;
/** pickView */
@property(nonatomic,strong) UIPickerView *pickView;
/** 亮度inputBrightness */
@property(nonatomic,strong) NSMutableArray *inputBrightness;
/** 饱和度inputSaturation */
@property(nonatomic,strong) NSMutableArray *inputSaturation;
/** 对比度inputContrast */
@property(nonatomic,strong) NSMutableArray *inputContrast;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //展示视图
    [self.view addSubview:self.showImageV];
    
    //pickView
    [self.view addSubview:self.pickView];
}


#pragma  mark -  pickView数据源以及代理方法
#pragma  mark -
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

//返回每个组件上的行数
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return self.dataArray.count;
            break;
        case 1:
            return self.inputBrightness.count;
            break;
        case 2:
            return self.inputContrast.count;
            break;
        case 3:
            return self.inputSaturation.count;
            break;
        default:
            return 0;
            break;
    }
}

//设置每行显示的内容
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [self.pickerData objectAtIndex:row];
            break;
        case 1:
          return  [NSString stringWithFormat:@"%@",self.inputBrightness[row]];
            break;
        case 2:
            return  [NSString stringWithFormat:@"%@",self.inputContrast[row]];
            break;
        case 3:
            return  [NSString stringWithFormat:@"%@",self.inputSaturation[row]];
            break;
        default:
            return nil;
            break;
    }
}

//选中某一行时调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0://滤镜
            [self filterImageWithfilterName:self.dataArray[row]];
            break;
        case 1://亮度
            [self colorControlsWithSaturation:1.f brightness:[self.inputBrightness[row] floatValue] contrast:1.f];
            break;
        case 2://对比度
            [self colorControlsWithSaturation:1.f brightness:0 contrast:[self.inputContrast[row] floatValue]];
            break;
        case 3://饱和度
            [self colorControlsWithSaturation:[self.inputSaturation[row] floatValue] brightness:0 contrast:1.f];
            break;
        default:
            break;
    }
}


#pragma  mark -  对图片进行滤镜处理
#pragma  mark -
// 怀旧 --> CIPhotoEffectInstant
// 单色 --> CIPhotoEffectMono
// 黑白 --> CIPhotoEffectNoir
// 褪色 --> CIPhotoEffectFade
// 色调 --> CIPhotoEffectTonal
// 冲印 --> CIPhotoEffectProcess
// 岁月 --> CIPhotoEffectTransfer
// 铬黄 --> CIPhotoEffectChrome
- (void )filterImageWithfilterName:(NSString *)name{
    if ([name isEqualToString:@"OriginalImage"]) {//原图
        self.showImageV.image = [UIImage imageNamed:@"original"];
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //将UIImage转换成CIImage
        CIImage *ciImage = [[CIImage alloc] initWithImage:self.originalImage];
        
        //创建滤镜
        CIFilter *filter = [CIFilter filterWithName:name keysAndValues:kCIInputImageKey, ciImage, nil];
        
        //已有的值不改变，其他的设为默认值
        [filter setDefaults];
        
        //获取绘制上下文
        CIContext *context = [CIContext contextWithOptions:nil];
        
        //渲染并输出CIImage
        CIImage *outputImage = [filter outputImage];
        
        //创建CGImage句柄
        CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
        
        //获取图片
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        
        //释放CGImage句柄
        CGImageRelease(cgImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.showImageV.image = image;
        });
    });
}

/**
 *  调整图片饱和度, 亮度, 对比度
 *  @param saturation 饱和度 默认为1
 *  @param brightness 亮度: -1.0 ~ 1.0 默认是0
 *  @param contrast   对比度 默认为1
 *
 */- (void)colorControlsWithSaturation:(CGFloat)saturation
                            brightness:(CGFloat)brightness
                              contrast:(CGFloat)contrast{
     dispatch_async(dispatch_get_global_queue(0, 0), ^{
         
         CIContext *context = [CIContext contextWithOptions:nil];
         CIImage *inputImage = [[CIImage alloc] initWithImage:self.originalImage];
         CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
         [filter setValue:inputImage forKey:kCIInputImageKey];
         
         [filter setValue:@(saturation) forKey:@"inputSaturation"];
         [filter setValue:@(brightness) forKey:@"inputBrightness"];
         [filter setValue:@(contrast) forKey:@"inputContrast"];
         
         CIImage *result = [filter valueForKey:kCIOutputImageKey];
         CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
         UIImage *resultImage = [UIImage imageWithCGImage:cgImage];
         CGImageRelease(cgImage);
         
         dispatch_async(dispatch_get_main_queue(), ^{
             self.showImageV.image = resultImage;
         });
     });
 }


#pragma  mark -  懒加载部分
#pragma  mark -
- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSArray arrayWithObjects:
                      @"OriginalImage",
                      @"CIPhotoEffectInstant",
                      @"CIPhotoEffectMono",
                      @"CIPhotoEffectNoir",
                      @"CIPhotoEffectFade",
                      @"CIPhotoEffectTonal",
                      @"CIPhotoEffectProcess",
                      @"CIPhotoEffectTransfer",
                      @"CIPhotoEffectChrome",
                      nil];
    }
    return _dataArray;
}

- (NSArray *)pickerData {
    if (!_pickerData) {
        _pickerData = [NSArray arrayWithObjects:
                       @"原图",
                       @"怀旧",
                       @"单色",
                       @"黑白",
                       @"褪色",
                       @"色调",
                       @"冲印",
                       @"岁月",
                       @"铬黄",
                       nil];
    }
    return _pickerData;
}

- (NSMutableArray *)inputBrightness {//亮度
    if (!_inputBrightness) {
        _inputBrightness = [NSMutableArray arrayWithArray:@[@-1,@-0.5,@0,@0.5,@1]];
    }
    return _inputBrightness;
}


- (NSMutableArray *)inputSaturation {//对比度
    if (!_inputSaturation) {
        _inputSaturation = [NSMutableArray arrayWithArray:@[@0,@1,@2,@3,@4]];
    }
    return _inputSaturation;
}


- (NSMutableArray *)inputContrast {//饱和度
    if (!_inputContrast) {
        _inputContrast = [NSMutableArray arrayWithArray:@[@0,@0.5,@1,@1.5,@2]];
    }
    return _inputContrast;
}

- (UIImageView *)showImageV {
    if (!_showImageV) {
        _showImageV = [[UIImageView alloc]initWithImage:self.originalImage];
        _showImageV.contentMode = UIViewContentModeScaleAspectFit;
        _showImageV.frame = CGRectMake(0, 0, 300, 300);
        _showImageV.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
    }
    return _showImageV;
}

- (UIImage *)originalImage {
    if (!_originalImage) {
        _originalImage = [UIImage imageNamed:@"original"];
    }
    return _originalImage;
}

- (UIPickerView *)pickView {
    if (!_pickView) {
        _pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 300, ScreenWidth, 300)];
        _pickView.dataSource = self;
        _pickView.delegate = self;
        //默认选中
        [self.pickView selectRow:0 inComponent:0 animated:YES];
        [self.pickView selectRow:2 inComponent:1 animated:YES];
        [self.pickView selectRow:2 inComponent:2 animated:YES];
        [self.pickView selectRow:1 inComponent:3 animated:YES];
        
    }
    return _pickView;
}



@end
