//
//  FaceEmoticonCell.m
//  KeyboardForChat
//
//  Created by chengxianghe on 16/8/3.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import "FaceEmoticonCell.h"
#import "FaceEmoticon.h"
#import "FaceEmoticonInputView.h"
#import "FaceEmoticonGroup.h"

@implementation FaceEmoticonCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _imageView = [UIImageView new];
    _imageView.frame = CGRectMake(0, 0, 32, 32);
    _imageView.center = self.center;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageView];
    return self;
}

- (void)setEmoticon:(FaceEmoticon *)emoticon {
    if (_emoticon == emoticon) return;
    _emoticon = emoticon;
    [self updateContent];
}

- (void)setIsDelete:(BOOL)isDelete {
    if (_isDelete == isDelete) return;
    _isDelete = isDelete;
    [self updateContent];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayout];
}

- (void)updateContent {
    _imageView.image = nil;
    
    CGRect frame = _imageView.frame;
    if (_emoticon.type == FaceEmoticonTypeCustom) {
        frame.size = CGSizeMake(60, 60);
    } else {
        frame.size = CGSizeMake(32, 32);
    }
    
    if (_isDelete) {
        _imageView.image = [UIImage imageNamed:@"Delete_ios7"];
    } else if (_emoticon) {
        if (_emoticon.type == FaceEmoticonTypeEmoji) {
            NSNumber *num = [NSNumber numberWithString:_emoticon.code];
            NSString *str = [NSString stringWithUTF32Char:num.unsignedIntValue];
            if (str) {
                UIImage *img = [UIImage imageWithEmoji:str size:CGRectGetWidth(_imageView.frame)];
                _imageView.image = img;
            }
        } else {
            NSString *pngPath = [[FaceEmoticonInputView emoticonBundle] pathForScaledResource:_emoticon.png ofType:nil inDirectory:_emoticon.group.groupID];
            if (!pngPath) {
                NSString *addBundlePath = [[FaceEmoticonInputView emoticonBundle].bundlePath stringByAppendingPathComponent:@"additional"];
                NSBundle *addBundle = [NSBundle bundleWithPath:addBundlePath];
                pngPath = [addBundle pathForScaledResource:_emoticon.png ofType:nil inDirectory:_emoticon.group.groupID];
            }
            if (pngPath) {
                _imageView.image = [UIImage imageWithContentsOfFile:pngPath];
            }
        }
    }
}

- (void)updateLayout {
    _imageView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

@end
