//
//  ScreenHelper.h
//  YYTest
//
//  Created by chengxianghe on 16/1/14.
//  Copyright © 2016年 CXH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef ScreenHelper_h
#define ScreenHelper_h

#define YYScreenScale                   [ScreenHelper screenScale]
#define CGFloatFromPixel(value)         [ScreenHelper pixel:(value)]
#define CGFloatPixelFloor(value)        [ScreenHelper pixelFloor:(value)]
#define CGFloatPixelRound(value)        [ScreenHelper pixelRound:(value)]
#define CGSizePixelRound(value)         [ScreenHelper sizePixelRound:(value)]
#define CGRectPixelRound(value)         [ScreenHelper rectPixelRound:(value)]

#define UIEdgeInsetPixelFloor(value)    [ScreenHelper edgeInsetPixelFloor:(value)]

#define kOneScale (1.0/YYScreenScale)
#endif

@interface ScreenHelper : NSObject

+ (CGFloat)screenScale;
+ (CGFloat)pixel:(CGFloat)value;
+ (CGFloat)pixelFloor:(CGFloat)value;
+ (CGFloat)pixelRound:(CGFloat)value;
+ (CGSize)sizePixelRound:(CGSize)size;
+ (CGRect)rectPixelRound:(CGRect)rect;
+ (UIEdgeInsets)edgeInsetPixelFloor:(UIEdgeInsets)insets;

@end
