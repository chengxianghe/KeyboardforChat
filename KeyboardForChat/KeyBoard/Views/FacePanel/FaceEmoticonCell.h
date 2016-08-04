//
//  FaceEmoticonCell.h
//  KeyboardForChat
//
//  Created by chengxianghe on 16/8/3.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceEmoticon.h"


@interface FaceEmoticonCell : UICollectionViewCell

@property (nonatomic, strong) FaceEmoticon *emoticon;
@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic, strong) UIImageView *imageView;

@end
