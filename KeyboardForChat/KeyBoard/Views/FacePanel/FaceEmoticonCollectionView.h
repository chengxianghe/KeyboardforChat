//
//  FaceEmoticonCollectionView.h
//  KeyboardForChat
//
//  Created by chengxianghe on 16/8/3.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FaceEmoticonCell;

@protocol FaceEmoticonCollectionViewDelegate <UICollectionViewDelegate>
- (void)emoticonScrollViewDidTapCell:(FaceEmoticonCell *)cell;
@end

@interface FaceEmoticonCollectionView : UICollectionView

@end
