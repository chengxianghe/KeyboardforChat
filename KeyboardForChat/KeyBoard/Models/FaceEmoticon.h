//
//  FaceEmoticon.h
//  KeyboardForChat
//
//  Created by chengxianghe on 16/8/3.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FaceEmoticonType) {
    FaceEmoticonTypeImage   = 0, ///< 图片表情
    FaceEmoticonTypeEmoji   = 1, ///< Emoji表情
    FaceEmoticonTypeGif     = 2, ///< 图片Gif表情
    FaceEmoticonTypeCustom  = 3, ///< 自定义表情 60*60
};

@class FaceEmoticonGroup;
@interface FaceEmoticon : NSObject
@property (nonatomic, strong) NSString *chs;  ///< 例如 [吃惊]
@property (nonatomic, strong) NSString *cht;  ///< 例如 [吃驚]
@property (nonatomic, strong) NSString *gif;  ///< 例如 d_chijing.gif
@property (nonatomic, strong) NSString *png;  ///< 例如 d_chijing.png
@property (nonatomic, strong) NSString *code; ///< 例如 0x1f60d
@property (nonatomic, assign) FaceEmoticonType type;
@property (nonatomic, weak) FaceEmoticonGroup *group;
@end
