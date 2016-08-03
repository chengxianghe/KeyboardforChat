//
//  FaceEmoticonGroup.m
//  KeyboardForChat
//
//  Created by chengxianghe on 16/8/3.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import "FaceEmoticonGroup.h"
#import "YYModel.h"
#import "FaceEmoticon.h"


@implementation FaceEmoticonGroup
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"groupID" : @"id",
             @"nameCN" : @"group_name_cn",
             @"nameEN" : @"group_name_en",
             @"nameTW" : @"group_name_tw",
             @"displayOnly" : @"display_only",
             @"groupType" : @"group_type"};
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"emoticons" : [FaceEmoticon class]};
}
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    [_emoticons enumerateObjectsUsingBlock:^(FaceEmoticon *emoticon, NSUInteger idx, BOOL *stop) {
        emoticon.group = self;
    }];
    return YES;
}
@end
