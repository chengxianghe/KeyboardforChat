//
//  FaceEmoticonCollectionView.m
//  KeyboardForChat
//
//  Created by chengxianghe on 16/8/3.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import "FaceEmoticonCollectionView.h"
#import "FaceEmoticonCell.h"
#import "YYImage.h"

@implementation FaceEmoticonCollectionView
{
    NSTimeInterval *_touchBeganTime;
    BOOL _touchMoved;
    UIImageView *_magnifier;
    YYAnimatedImageView *_magnifierContent;
    UILabel *_magnifierLabel;
    __weak FaceEmoticonCell *_currentMagnifierCell;
    NSTimer *_backspaceTimer;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [UIView new];
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.clipsToBounds = NO;
    self.canCancelContentTouches = NO;
    self.multipleTouchEnabled = NO;
    
    _magnifier = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emoticon_keyboard_magnifier"]];
    _magnifier.frame = CGRectMake(0, 0, _magnifier.frame.size.width, _magnifier.frame.size.height * 1.2);
    _magnifierContent = [YYAnimatedImageView new];
    _magnifierContent.frame = CGRectMake(0, 0, 40, 40);
    _magnifierContent.center = CGPointMake(CGRectGetWidth(_magnifier.frame) / 2, 0);

    [_magnifier addSubview:_magnifierContent];
    
    _magnifierLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 45, CGRectGetWidth(_magnifier.frame) - 6, 16)];
    _magnifierLabel.textAlignment = NSTextAlignmentCenter;
    _magnifierLabel.font = [UIFont systemFontOfSize:12.0];
    _magnifierLabel.adjustsFontSizeToFitWidth = YES;
    _magnifierLabel.textColor = [UIColor darkGrayColor];
    [_magnifier addSubview:_magnifierLabel];

    _magnifier.hidden = YES;
    [self addSubview:_magnifier];
    return self;
}

- (void)dealloc {
    [self endBackspaceTimer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchMoved = NO;
    FaceEmoticonCell *cell = [self cellForTouches:touches];
    _currentMagnifierCell = cell;
    [self showMagnifierForCell:_currentMagnifierCell];
    
    if (cell.imageView.image && !cell.isDelete) {
        [[UIDevice currentDevice] playInputClick];
    }
    
    if (cell.isDelete) {
        [self endBackspaceTimer];
        [self performSelector:@selector(startBackspaceTimer) withObject:nil afterDelay:0.5];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchMoved = YES;
    if (_currentMagnifierCell && _currentMagnifierCell.isDelete) return;
    
    FaceEmoticonCell *cell = [self cellForTouches:touches];
    if (cell != _currentMagnifierCell) {
        if (!_currentMagnifierCell.isDelete && !cell.isDelete) {
            _currentMagnifierCell = cell;
        }
        [self showMagnifierForCell:cell];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    FaceEmoticonCell *cell = [self cellForTouches:touches];
    if ((!_currentMagnifierCell.isDelete && cell.emoticon) || (!_touchMoved && cell.isDelete)) {
        if ([self.delegate respondsToSelector:@selector(emoticonScrollViewDidTapCell:)]) {
            [((id<FaceEmoticonCollectionViewDelegate>) self.delegate) emoticonScrollViewDidTapCell:cell];
        }
    }
    [self hideMagnifier];
    [self endBackspaceTimer];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideMagnifier];
    [self endBackspaceTimer];
}

- (FaceEmoticonCell *)cellForTouches:(NSSet<UITouch *> *)touches {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    if (indexPath) {
        FaceEmoticonCell *cell = (id)[self cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (void)showMagnifierForCell:(FaceEmoticonCell *)cell {
    if (cell.isDelete || !cell.imageView.image) {
        [self hideMagnifier];
        return;
    }
    CGRect rect = [cell convertRect:cell.bounds toView:self];
    
    if (cell.emoticon.type == FaceEmoticonTypeCustom) {
        _magnifier.frame = CGRectMake(0, 0, 100, 120);
        _magnifierContent.frame = CGRectMake(0, 0, 60, 60);
        _magnifierContent.center = CGPointMake(CGRectGetWidth(_magnifier.frame) / 2, 0);
        _magnifierLabel.hidden = YES;
    } else {
        _magnifier.frame = CGRectMake(0, 0, 70, 104);
        _magnifierContent.frame = CGRectMake(0, 0, 40, 40);
        _magnifierContent.center = CGPointMake(CGRectGetWidth(_magnifier.frame) / 2, 0);
        _magnifierLabel.frame = CGRectMake(3, 45, CGRectGetWidth(_magnifier.frame) - 6, 16);
        _magnifierLabel.hidden = NO;
    }

    _magnifier.center = CGPointMake(CGRectGetMidX(rect), _magnifier.center.y);
    CGRect magnifierFrame = _magnifier.frame;
    
    magnifierFrame.origin.y = CGRectGetMaxY(rect) - 9 - magnifierFrame.size.height;
    _magnifier.frame = magnifierFrame;
    _magnifier.hidden = NO;
    
    NSString *labelText = cell.emoticon.chs;
    
    if ([labelText rangeOfString:@"["].length > 0) {
        labelText = [labelText substringWithRange:NSMakeRange(1, labelText.length - 2)];
    } else if ([labelText rangeOfString:@"/"].length > 0) {
        labelText = [labelText substringWithRange:NSMakeRange(1, labelText.length - 1)];
    }
    
    _magnifierLabel.text = labelText;
    _magnifierContent.image = cell.imageView.image;
    
    __block CGRect magnifierContentFrame = _magnifierContent.frame;
    magnifierContentFrame.origin.y = 20;
    _magnifierContent.frame = magnifierContentFrame;
    
    [_magnifierContent.layer removeAllAnimations];
    NSTimeInterval dur = 0.1;
    [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        magnifierContentFrame.origin.y = 3;
        _magnifierContent.frame = magnifierContentFrame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            magnifierContentFrame.origin.y = 6;
            _magnifierContent.frame = magnifierContentFrame;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                magnifierContentFrame.origin.y = 5;
                _magnifierContent.frame = magnifierContentFrame;
            } completion:^(BOOL finished) {
            }];
        }];
    }];
}

- (void)hideMagnifier {
    _magnifier.hidden = YES;
}

- (void)startBackspaceTimer {
    [self endBackspaceTimer];
    
    _backspaceTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(timeSelector:) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_backspaceTimer forMode:NSRunLoopCommonModes];
}

- (void)timeSelector:(NSTimer *)timer {
    FaceEmoticonCell *cell = self->_currentMagnifierCell;
    if (cell.isDelete) {
        if ([self.delegate respondsToSelector:@selector(emoticonScrollViewDidTapCell:)]) {
            [[UIDevice currentDevice] playInputClick];
            [((id<FaceEmoticonCollectionViewDelegate>) self.delegate) emoticonScrollViewDidTapCell:cell];
        }
    }
}

- (void)endBackspaceTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startBackspaceTimer) object:nil];
    [_backspaceTimer invalidate];
    _backspaceTimer = nil;
}

@end
