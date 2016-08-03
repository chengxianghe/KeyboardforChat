//
//  ScreenHelper.m
//  YYTest
//
//  Created by chengxianghe on 16/1/14.
//  Copyright © 2016年 CXH. All rights reserved.
//

#import "ScreenHelper.h"

@implementation ScreenHelper

+ (CGFloat)screenScale {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
}

+ (CGFloat)pixel:(CGFloat)value {
    return value/[ScreenHelper screenScale];
}

/// floor point value for pixel-aligned
+ (CGFloat)pixelFloor:(CGFloat)value {
    CGFloat scale = [ScreenHelper screenScale];
    return floor(value * scale) / scale;
}

+ (CGFloat)pixelRound:(CGFloat)value {
    CGFloat scale = [ScreenHelper screenScale];
    return round(value * scale) / scale;
}

/// round point value for pixel-aligned
+ (CGSize)sizePixelRound:(CGSize)size {
    CGFloat scale = [ScreenHelper screenScale];
    return CGSizeMake(round(size.width * scale) / scale,
                      round(size.height * scale) / scale);
}

+ (CGRect)rectPixelRound:(CGRect)rect {
    CGFloat scale = [ScreenHelper screenScale];

    return CGRectMake(round(rect.origin.x * scale) / scale,
                      round(rect.origin.y * scale) / scale,
                      round(rect.size.width * scale) / scale,
                      round(rect.size.height * scale) / scale);
}

/// floor UIEdgeInset for pixel-aligned
+ (UIEdgeInsets)edgeInsetPixelFloor:(UIEdgeInsets)insets {
    insets.top = CGFloatPixelFloor(insets.top);
    insets.left = CGFloatPixelFloor(insets.left);
    insets.bottom = CGFloatPixelFloor(insets.bottom);
    insets.right = CGFloatPixelFloor(insets.right);
    return insets;
}

@end
