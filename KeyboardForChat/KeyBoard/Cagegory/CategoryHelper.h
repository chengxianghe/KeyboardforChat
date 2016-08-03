//
//  CategoryHelper.h
//  KeyboardForChat
//
//  Created by chengxianghe on 16/8/3.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIImage (YYAdd)
+ (UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size;
@end

@interface NSString (YYAdd)
- (NSString *)stringByAppendingPathScale:(CGFloat)scale;
- (NSString *)stringByAppendingNameScale:(CGFloat)scale;
- (NSString *)stringByTrim;
+ (NSString *)stringWithUTF32Char:(UTF32Char)char32;
@end

@interface NSBundle (YYAdd)
- (NSString *)pathForScaledResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath;
@end

@interface NSNumber (YYAdd)
+ (NSNumber *)numberWithString:(NSString *)string;
@end

@interface UIColor (Face)

+ (UIColor *)colorWithHexString:(NSString *)hexColor;

+ (UIColor *)colorWithHexValue:(uint)hexValue andAlpha:(float)alpha;

@end