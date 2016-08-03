//
//  FaceEmoticon.m
//  KeyboardForChat
//
//  Created by chengxianghe on 16/8/3.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import "FaceEmoticon.h"
#import "YYModel.h"

@implementation FaceEmoticon
+ (NSArray *)modelPropertyBlacklist {
    return @[@"group"];
}
@end
