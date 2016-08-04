//
//  FaceEmoticonInputView.h
//  KeyboardForChat
//
//  Created by chengxianghe on 16/8/3.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryHelper.h"

@protocol FaceStatusComposeEmoticonViewDelegate <NSObject>
@optional
- (void)emoticonInputDidTapText:(NSString *)text;
- (void)emoticonInputDidTapBackspace;

- (void)emoticonInputDidTapAdd;
- (void)emoticonInputDidTapSetting;

@end

@interface FaceEmoticonInputView : UIView
@property (nonatomic, weak) id<FaceStatusComposeEmoticonViewDelegate> delegate;
+ (instancetype)sharedView;

+ (NSBundle *)emoticonBundle;
+ (NSBundle *)qqEmoticonBundle;

@end

