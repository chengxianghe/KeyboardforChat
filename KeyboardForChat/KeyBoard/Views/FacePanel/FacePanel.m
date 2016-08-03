//
//  ChatFacePanel.m
//  FaceKeyboard

//  Company：     SunEee
//  Blog:        devcai.com
//  Communicate: 2581502433@qq.com

//  Created by ruofei on 16/3/30.
//  Copyright © 2016年 ruofei. All rights reserved.
//
//  2581502433@qq.com

/**
    尝试了 scroll + scroll
          collection + collection
    最终确定方案  scroll + collection
 */

#import "FacePanel.h"

#import "FaceThemeModel.h"
#import "FaceEmoticonInputView.h"

#import "ChatKeyBoardMacroDefine.h"

@interface FacePanel () <FaceStatusComposeEmoticonViewDelegate>

@property (nonatomic, strong) NSArray<FaceThemeModel *> *faceSources;

@end

@implementation FacePanel
{
    UIScrollView *_scrollView;
    UIPageControl    *_pageControl;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

#pragma mark -- 数据源
- (void)loadFaceThemeItems:(NSArray<FaceThemeModel *>*)themeItems;
{

}

#pragma mark - FaceThemeViewPageControlDelegate
- (void)faceThemeChangeCurrentPage:(NSInteger)currentPage {
    _pageControl.currentPage = currentPage;
}

- (void)initSubViews
{
    self.backgroundColor = kChatKeyBoardColor;
    
    FaceEmoticonInputView *v = [FaceEmoticonInputView sharedView];
    v.delegate = self;
    [self addSubview:v];
}

#pragma mark @protocol WBStatusComposeEmoticonView
- (void)emoticonInputDidTapText:(NSString *)text {
    if ([self.delegate respondsToSelector:@selector(facePanelFacePicked:faceStyle:faceName:isDeleteKey:)]) {
        
        [self.delegate facePanelFacePicked:self faceStyle:0 faceName:text isDeleteKey:NO];
    }
    
}

- (void)emoticonInputDidTapBackspace {
    if ([self.delegate respondsToSelector:@selector(facePanelFacePicked:faceStyle:faceName:isDeleteKey:)]) {
        [self.delegate facePanelFacePicked:self faceStyle:0 faceName:@"" isDeleteKey:YES];
    }
}

- (void)emoticonInputDidTapAdd {
    if ([self.delegate respondsToSelector:@selector(facePanelAddSubject:)]) {
        [self.delegate facePanelAddSubject:self];
    }
}

- (void)emoticonInputDidTapSetting {
    if ([self.delegate respondsToSelector:@selector(facePanelSendTextAction:)]) {
        [self.delegate facePanelSendTextAction:self];
    }
//    if ([self.delegate respondsToSelector:@selector(facePanelSetSubject:)]) {
//        [self.delegate facePanelSetSubject:self];
//    }
}

@end
