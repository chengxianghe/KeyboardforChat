//
//  FaceEmoticonInputView.m
//  KeyboardForChat
//
//  Created by chengxianghe on 16/8/3.
//  Copyright © 2016年 ruofei. All rights reserved.
//

#import "FaceEmoticonInputView.h"
#import "FaceEmoticonCell.h"
#import "FaceEmoticonCollectionView.h"
#import "FaceEmoticonGroup.h"
#import "FaceEmoticon.h"
#import "YYModel.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kViewHeight 216
#define kToolbarHeight 37
#define kToolbarBtnWidtn 50

#define kToolbarAddBtnWidth kToolbarHeight
#define kToolbarSettingBtnWidth 50

#define kOneEmoticonHeight 50
#define kOnePageCount 20
#define kOnePageCustomCount 10

#ifndef UIColorHex
#define UIColorHex(_hex_)   [UIColor colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif

@interface FaceEmoticonInputView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIInputViewAudioFeedback,FaceEmoticonCollectionViewDelegate>
@property (nonatomic, strong) NSArray<UIButton *> *toolbarButtons;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *pageControl;
@property (nonatomic, strong) NSArray<FaceEmoticonGroup *> *emoticonGroups;
@property (nonatomic, strong) NSArray<NSNumber *> *emoticonGroupPageIndexs;
@property (nonatomic, strong) NSArray<NSNumber *> *emoticonGroupPageCounts;
@property (nonatomic, assign) NSInteger emoticonGroupTotalPageCount;
@property (nonatomic, assign) NSInteger currentPageIndex;

@end

@implementation FaceEmoticonInputView

+ (instancetype)sharedView {
    static FaceEmoticonInputView *v;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [self new];
    });
    return v;
}

- (instancetype)init {
    self = [super init];
    self.frame = CGRectMake(0, 0, kScreenWidth, kViewHeight);
    self.backgroundColor = UIColorHex(f9f9f9);
    [self _initGroups];
    [self _initTopLine];
    [self _initCollectionView];
    [self _initToolbar];
    
    _currentPageIndex = NSNotFound;
    [self _toolbarBtnDidTapped:_toolbarButtons.firstObject];
    
    return self;
}

- (void)_initGroups {
    _emoticonGroups = [self.class emoticonGroups];
    NSMutableArray *indexs = [NSMutableArray new];
    NSUInteger index = 0;
    for (FaceEmoticonGroup *group in _emoticonGroups) {
        [indexs addObject:@(index)];
        if (group.emoticonType != FaceEmoticonTypeCustom) {
            NSUInteger count = ceil(group.emoticons.count / (float)kOnePageCount);
            if (count == 0) count = 1;
            index += count;
        } else {
            NSUInteger count = ceil(group.emoticons.count / (float)kOnePageCustomCount);
//            if (count == 0) count = 1;
            index += count;
        }
    }
    _emoticonGroupPageIndexs = indexs;
    
    NSMutableArray *pageCounts = [NSMutableArray new];
    _emoticonGroupTotalPageCount = 0;
    for (FaceEmoticonGroup *group in _emoticonGroups) {
        if (group.emoticonType != FaceEmoticonTypeCustom) {
            NSUInteger pageCount = ceil(group.emoticons.count / (float)kOnePageCount);
            if (pageCount == 0) pageCount = 1;
            [pageCounts addObject:@(pageCount)];
            _emoticonGroupTotalPageCount += pageCount;
        } else {
            NSUInteger pageCount = ceil(group.emoticons.count / (float)kOnePageCustomCount);
            if (pageCount == 0) continue;
            [pageCounts addObject:@(pageCount)];
            _emoticonGroupTotalPageCount += pageCount;
        }
    }
    _emoticonGroupPageCounts = pageCounts;
}

- (void)_initTopLine {
    UIView *line = [UIView new];
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(self.bounds.size.width, 1.0 / [UIScreen mainScreen].scale);
    line.frame = frame;
    line.backgroundColor = UIColorHex(bfbfbf);
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:line];
}

- (void)_initCollectionView {
    CGFloat itemWidth = (kScreenWidth - 10 * 2) / 7.0;
    itemWidth = itemWidth;
    CGFloat padding = (kScreenWidth - 7 * itemWidth) / 2.0;
    CGFloat paddingLeft = padding;
    CGFloat paddingRight = kScreenWidth - paddingLeft - itemWidth * 7;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(itemWidth, kOneEmoticonHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, paddingLeft, 0, paddingRight);
    
    CGRect collectionViewFrame = CGRectMake(0, 0, kScreenWidth, kOneEmoticonHeight * 3);
    _collectionView = [[FaceEmoticonCollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:layout];
    [_collectionView registerClass:[FaceEmoticonCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    collectionViewFrame.origin.y = 5;
    _collectionView.frame = collectionViewFrame;
    [self addSubview:_collectionView];
    
    _pageControl = [UIView new];
    CGRect pageControlFrame = CGRectZero;
    pageControlFrame.size = CGSizeMake(kScreenWidth, 20);
    pageControlFrame.origin.y = CGRectGetMaxY(_collectionView.frame) - 5;
    _pageControl.frame = pageControlFrame;
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
}


- (void)_initToolbar {
    UIView *toolbar = [UIView new];
    CGRect toolbarFrame = CGRectZero;

    toolbarFrame.size = CGSizeMake(kScreenWidth, kToolbarHeight);
    toolbar.frame = toolbarFrame;
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compose_emotion_table_right_normal"]];
    CGRect bgFrame = CGRectZero;
    bgFrame.size = toolbar.frame.size;
    bg.frame = bgFrame;
    [toolbar addSubview:bg];
    
    UIScrollView *scroll = [UIScrollView new];
    CGRect scrollFrame = CGRectZero;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.alwaysBounceHorizontal = YES;
    scrollFrame.origin.x = kToolbarHeight;
    scrollFrame.size = CGSizeMake(kScreenWidth - kToolbarSettingBtnWidth - kToolbarAddBtnWidth, CGRectGetHeight(toolbar.frame));
    scroll.frame = scrollFrame;
    scroll.contentSize = toolbar.frame.size;
    [toolbar addSubview:scroll];
    
    NSMutableArray *btns = [NSMutableArray new];
    UIButton *btn;

    for (NSUInteger i = 0; i < _emoticonGroups.count; i++) {
        FaceEmoticonGroup *group = _emoticonGroups[i];
        btn = [self _createToolbarButton];
        CGRect btnFrame = btn.frame;

        [btn setTitle:group.nameCN forState:UIControlStateNormal];
        btnFrame.origin.x = CGRectGetWidth(btnFrame) * i;
        btn.frame = btnFrame;
        btn.tag = i;
        [scroll addSubview:btn];
        [btns addObject:btn];
    }
    
    scroll.contentSize = CGSizeMake(kToolbarBtnWidtn * _emoticonGroups.count, CGRectGetHeight(scrollFrame));
    
    toolbarFrame.origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(toolbarFrame);
    toolbar.frame = toolbarFrame;
    
    
    // +
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setTitle:@"+" forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"compose_emotion_table_right_normal"] forState:UIControlStateNormal];

    [addBtn.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [addBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    addBtn.frame = CGRectMake(0, 0, kToolbarAddBtnWidth, kToolbarHeight);
    [addBtn addTarget:self action:@selector(onAddButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:addBtn];
    
    // 设置
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [settingBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [settingBtn setTitle:@"发送" forState:UIControlStateNormal];
    [settingBtn setBackgroundImage:[UIImage imageNamed:@"compose_emotion_table_right_normal"] forState:UIControlStateNormal];
    [settingBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [settingBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    settingBtn.frame = CGRectMake(kScreenWidth - kToolbarSettingBtnWidth, 0, kToolbarSettingBtnWidth, kToolbarHeight);
    [settingBtn addTarget:self action:@selector(onSettingButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:settingBtn];
    
    [self addSubview:toolbar];
    _toolbarButtons = btns;
}

- (UIButton *)_createToolbarButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect btnFrame = btn.frame;

    btn.exclusiveTouch = YES;
    btnFrame.size = CGSizeMake(kToolbarBtnWidtn, kToolbarHeight);
    btn.frame = btnFrame;
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:UIColorHex(5D5C5A) forState:UIControlStateSelected];
    
    UIImage *img;
    img = [UIImage imageNamed:@"compose_emotion_table_mid_normal"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    
    img = [UIImage imageNamed:@"compose_emotion_table_mid_selected"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateSelected];
    
    [btn addTarget:self action:@selector(_toolbarBtnDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)_toolbarBtnDidTapped:(UIButton *)btn {
    NSInteger groupIndex = btn.tag;
    NSInteger page = ((NSNumber *)_emoticonGroupPageIndexs[groupIndex]).integerValue;
    CGRect rect = CGRectMake(page * CGRectGetWidth(_collectionView.frame), 0, CGRectGetWidth(_collectionView.frame), CGRectGetHeight(_collectionView.frame));
    [_collectionView scrollRectToVisible:rect animated:NO];
    [self scrollViewDidScroll:_collectionView];
}

- (FaceEmoticon *)_emoticonForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    for (NSInteger i = _emoticonGroupPageIndexs.count - 1; i >= 0; i--) {
        NSNumber *pageIndex = _emoticonGroupPageIndexs[i];
        if (section >= pageIndex.unsignedIntegerValue) {
            FaceEmoticonGroup *group = _emoticonGroups[i];
            NSUInteger page = section - pageIndex.unsignedIntegerValue;
            
            if (group.emoticonType != FaceEmoticonTypeCustom) {
                NSUInteger index = page * kOnePageCount + indexPath.row;
                
                // transpose line/row
                NSUInteger ip = index / kOnePageCount;
                NSUInteger ii = index % kOnePageCount;
                NSUInteger reIndex = (ii % 3) * 7 + (ii / 3);
                index = reIndex + ip * kOnePageCount;
                
                if (index < group.emoticons.count) {
                    return group.emoticons[index];
                } else {
                    return nil;
                }
            } else {
                NSUInteger index = page * kOnePageCustomCount + indexPath.row;
                
                // transpose line/row
                NSUInteger ip = index / kOnePageCustomCount;
                NSUInteger ii = index % kOnePageCustomCount;
                NSUInteger reIndex = (ii % 2) * 5 + (ii / 2);
                index = reIndex + ip * kOnePageCustomCount;
                
                if (index < group.emoticons.count) {
                    return group.emoticons[index];
                } else {
                    return nil;
                }
            }
        }
    }
    return nil;
}

#pragma mark - Action
- (void)onAddButtonClick {
    if ([self.delegate respondsToSelector:@selector(emoticonInputDidTapAdd)]) {
        [self.delegate emoticonInputDidTapAdd];
    }
}

- (void)onSettingButtonClick {
    if ([self.delegate respondsToSelector:@selector(emoticonInputDidTapSetting)]) {
        [self.delegate emoticonInputDidTapSetting];
    }
}


#pragma mark WBEmoticonScrollViewDelegate

- (void)emoticonScrollViewDidTapCell:(FaceEmoticonCell *)cell {
    if (!cell) return;
    if (cell.isDelete) {
        if ([self.delegate respondsToSelector:@selector(emoticonInputDidTapBackspace)]) {
            [[UIDevice currentDevice] playInputClick];
            [self.delegate emoticonInputDidTapBackspace];
        }
    } else if (cell.emoticon) {
        NSString *text = nil;
        switch (cell.emoticon.type) {
            case FaceEmoticonTypeImage: {
                text = cell.emoticon.chs;
            } break;
            case FaceEmoticonTypeEmoji: {
                NSNumber *num = [NSNumber numberWithString:cell.emoticon.code];
                text = [NSString stringWithUTF32Char:num.unsignedIntValue];
            } break;
            case FaceEmoticonTypeGif: {
                text = cell.emoticon.chs;
            } break;
            case FaceEmoticonTypeCustom: {
                text = cell.emoticon.chs;
            } break;
            default:break;
        }
        if (text && [self.delegate respondsToSelector:@selector(emoticonInputDidTapText:)]) {
            [self.delegate emoticonInputDidTapText:text];
        }
    }
}

#pragma mark UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = round(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame));
    if (page < 0) page = 0;
    else if (page >= _emoticonGroupTotalPageCount) page = _emoticonGroupTotalPageCount - 1;
    if (page == _currentPageIndex) return;
    _currentPageIndex = page;
    NSInteger curGroupIndex = 0, curGroupPageIndex = 0, curGroupPageCount = 0;
    for (NSInteger i = _emoticonGroupPageIndexs.count - 1; i >= 0; i--) {
        NSNumber *pageIndex = _emoticonGroupPageIndexs[i];
        if (page >= pageIndex.unsignedIntegerValue) {
            curGroupIndex = i;
            curGroupPageIndex = ((NSNumber *)_emoticonGroupPageIndexs[i]).integerValue;
            curGroupPageCount = ((NSNumber *)_emoticonGroupPageCounts[i]).integerValue;
            break;
        }
    }

    while (_pageControl.layer.sublayers.count) {
        [_pageControl.layer.sublayers.lastObject removeFromSuperlayer];
    }
    
    CGFloat padding = 5, width = 6, height = 2;
    CGFloat pageControlWidth = (width + 2 * padding) * curGroupPageCount;
    for (NSInteger i = 0; i < curGroupPageCount; i++) {
        CALayer *layer = [CALayer layer];
        CGRect layerFrame = CGRectZero;
        layerFrame.size = CGSizeMake(width, height);
        layer.frame = layerFrame;
        layer.cornerRadius = 1;
        if (page - curGroupPageIndex == i) {
            layer.backgroundColor = UIColorHex(fd8225).CGColor;
        } else {
            layer.backgroundColor = UIColorHex(dedede).CGColor;
        }
        layerFrame.origin.y = CGRectGetHeight(_pageControl.frame) / 2 - layerFrame.size.height * 0.5;
        layerFrame.origin.x = (CGRectGetWidth(_pageControl.frame) - pageControlWidth) / 2 + i * (width + 2 * padding) + padding;
        layer.frame = layerFrame;
        [_pageControl.layer addSublayer:layer];
    }
    [_toolbarButtons enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        btn.selected = (idx == curGroupIndex);
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _emoticonGroupTotalPageCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    FaceEmoticon *emoticon = [self _emoticonForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    if (emoticon.type != FaceEmoticonTypeCustom) {
        return kOnePageCount + 1;
    }
    return kOnePageCustomCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FaceEmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row == kOnePageCount) {
        cell.isDelete = YES;
        cell.emoticon = nil;
    } else {
        cell.isDelete = NO;
        cell.emoticon = [self _emoticonForIndexPath:indexPath];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FaceEmoticon *emoticon = [self _emoticonForIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
    if (emoticon.type != FaceEmoticonTypeCustom) {
        CGFloat itemWidth = (kScreenWidth - 10 * 2) / 7.0;
        return CGSizeMake(itemWidth, kOneEmoticonHeight);
    }
    
    CGFloat itemWidth = (kScreenWidth - 10 * 2) / 5.0;
    return CGSizeMake(itemWidth, kOneEmoticonHeight * 1.5);
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

+ (NSBundle *)qqEmoticonBundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"EmoticonQQ" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return bundle;
}


+ (NSBundle *)emoticonBundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"EmoticonWeibo" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    });
    return bundle;
}

+ (NSArray<FaceEmoticonGroup *> *)emoticonGroups {
    static NSMutableArray *groups;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *emoticonBundlePath = [[NSBundle mainBundle] pathForResource:@"EmoticonWeibo" ofType:@"bundle"];
        NSString *emoticonPlistPath = [emoticonBundlePath stringByAppendingPathComponent:@"emoticons.plist"];
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:emoticonPlistPath];
        NSArray *packages = plist[@"packages"];
        groups = (NSMutableArray *)[NSArray yy_modelArrayWithClass:[FaceEmoticonGroup class] json:packages];
        
        NSMutableDictionary *groupDic = [NSMutableDictionary new];
        for (int i = 0, max = (int)groups.count; i < max; i++) {
            FaceEmoticonGroup *group = groups[i];
            if (group.groupID.length == 0) {
                [groups removeObjectAtIndex:i];
                i--;
                max--;
                continue;
            }
            NSString *path = [emoticonBundlePath stringByAppendingPathComponent:group.groupID];
            NSString *infoPlistPath = [path stringByAppendingPathComponent:@"info.plist"];
            NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPlistPath];
            [group yy_modelSetWithDictionary:info];
            if (group.emoticons.count == 0) {
                i--;
                max--;
                continue;
            }
            groupDic[group.groupID] = group;
        }
        
        NSArray<NSString *> *additionals = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[emoticonBundlePath stringByAppendingPathComponent:@"additional"] error:nil];
        for (NSString *path in additionals) {
            FaceEmoticonGroup *group = groupDic[path];
            if (!group) continue;
            NSString *infoJSONPath = [[[emoticonBundlePath stringByAppendingPathComponent:@"additional"] stringByAppendingPathComponent:path] stringByAppendingPathComponent:@"info.json"];
            NSData *infoJSON = [NSData dataWithContentsOfFile:infoJSONPath];
            FaceEmoticonGroup *addGroup = [FaceEmoticonGroup yy_modelWithJSON:infoJSON];
            if (addGroup.emoticons.count) {
                for (FaceEmoticon *emoticon in addGroup.emoticons) {
                    emoticon.group = group;
                }
                
                NSUInteger i = 0;
                for (id obj in addGroup.emoticons) {
                    [((NSMutableArray *)group.emoticons) insertObject:obj atIndex:i++];
                }
            }
        }
        
        //QQ
        NSString *emoticonQQBundlePath = [[NSBundle mainBundle] pathForResource:@"EmoticonQQ" ofType:@"bundle"];
        NSString *emoticonQQPlistPath = [emoticonQQBundlePath stringByAppendingPathComponent:@"info.plist"];
        NSArray *qqPlist = [NSArray arrayWithContentsOfFile:emoticonQQPlistPath];
        FaceEmoticonGroup *qqGroup = [[FaceEmoticonGroup alloc] init];
        qqGroup.nameCN = qqGroup.nameEN = qqGroup.nameTW = @"QQ";
        NSMutableArray *qqEmoticons = [NSMutableArray array];
        for (int i = 0; i < qqPlist.count; i ++) {
            NSDictionary *dict = qqPlist[i];
            FaceEmoticon *emoticon = [[FaceEmoticon alloc] init];
            emoticon.chs = emoticon.cht = [dict allKeys].firstObject;
            emoticon.png = [[dict allValues].firstObject stringByAppendingString:@"@2x"];
            emoticon.gif = [[dict allValues].firstObject stringByAppendingString:@"@2x"];
            emoticon.type = FaceEmoticonTypeGif;
            emoticon.group = qqGroup;
            
            [qqEmoticons addObject:emoticon];
        }
        qqGroup.emoticons = qqEmoticons;
        
        [groups addObject:qqGroup];
        
        //大表情
        NSString *emoticonBigPlistPath = [[NSBundle mainBundle]pathForResource:@"EmoticonTiaoTiao" ofType:@"bundle"];
        NSDictionary *bigPlist = [NSDictionary dictionaryWithContentsOfFile:[emoticonBigPlistPath stringByAppendingPathComponent:@"emotion.plist"]];
        FaceEmoticonGroup *bigGroup = [[FaceEmoticonGroup alloc] init];
        bigGroup.nameCN = bigGroup.nameEN = bigGroup.nameTW = @"跳跳";
        bigGroup.emoticonType = FaceEmoticonTypeCustom;
        NSArray *bigAllKeys = [bigPlist allKeys];
        NSMutableArray *bigEmoticons = [NSMutableArray array];
        for (int i = 0; i < bigAllKeys.count; i ++) {
            NSString *key = bigAllKeys[i];
            FaceEmoticon *emoticon = [[FaceEmoticon alloc] init];
            emoticon.chs = emoticon.cht = key;
            emoticon.png = [emoticonBigPlistPath stringByAppendingPathComponent:[bigPlist[key] stringByAppendingString:@".gif"]];
            emoticon.gif = [emoticonBigPlistPath stringByAppendingPathComponent:[bigPlist[key] stringByAppendingString:@".gif"]];
            emoticon.type = FaceEmoticonTypeCustom;
            emoticon.group = bigGroup;
            
            [bigEmoticons addObject:emoticon];
        }
        bigGroup.emoticons = bigEmoticons;
        
        [groups addObject:bigGroup];


        //大表情
        NSString *emoticonWordBundlePath = [[NSBundle mainBundle]pathForResource:@"EmoticonWord" ofType:@"bundle"];
        NSDictionary *wordPlist = [NSDictionary dictionaryWithContentsOfFile:[emoticonWordBundlePath stringByAppendingPathComponent:@"emotion.plist"]];
        FaceEmoticonGroup *wordGroup = [[FaceEmoticonGroup alloc] init];
        wordGroup.emoticonType = FaceEmoticonTypeCustom;
        wordGroup.nameCN = wordGroup.nameEN = wordGroup.nameTW = @"文字";
        NSArray *wordAllKeys = [wordPlist allKeys];
        NSMutableArray *wordEmoticons = [NSMutableArray array];
        for (int i = 0; i < wordAllKeys.count; i ++) {
            NSString *key = wordAllKeys[i];
            FaceEmoticon *emoticon = [[FaceEmoticon alloc] init];
            emoticon.chs = emoticon.cht = key;
            emoticon.png = [emoticonWordBundlePath stringByAppendingPathComponent:[wordPlist[key] stringByAppendingString:@".gif"]];
            emoticon.gif = [emoticonWordBundlePath stringByAppendingPathComponent:[wordPlist[key] stringByAppendingString:@".gif"]];
            emoticon.type = FaceEmoticonTypeCustom;
            emoticon.group = wordGroup;
            
            [wordEmoticons addObject:emoticon];
        }
        wordGroup.emoticons = wordEmoticons;
        
        [groups addObject:wordGroup];
        
        //大表情 咸鱼
        NSString *emoticonFishBundlePath = [[NSBundle mainBundle]pathForResource:@"EmoticonFish" ofType:@"bundle"];
        NSDictionary *fishPlist = [NSDictionary dictionaryWithContentsOfFile:[emoticonFishBundlePath stringByAppendingPathComponent:@"emotion.plist"]];
        FaceEmoticonGroup *fishGroup = [[FaceEmoticonGroup alloc] init];
        fishGroup.emoticonType = FaceEmoticonTypeCustom;
        fishGroup.nameCN = fishGroup.nameEN = fishGroup.nameTW = @"咸鱼";
        NSArray *fishAllKeys = [fishPlist allKeys];
        NSMutableArray *fishEmoticons = [NSMutableArray array];
        for (int i = 0; i < fishAllKeys.count; i ++) {
            NSString *key = fishAllKeys[i];
            FaceEmoticon *emoticon = [[FaceEmoticon alloc] init];
            emoticon.chs = emoticon.cht = key;
            emoticon.png = [emoticonFishBundlePath stringByAppendingPathComponent:[fishPlist[key] stringByAppendingString:@".jpg"]];
            emoticon.gif = [emoticonFishBundlePath stringByAppendingPathComponent:[fishPlist[key] stringByAppendingString:@".jpg"]];
            emoticon.type = FaceEmoticonTypeCustom;
            emoticon.group = fishGroup;
            
            [fishEmoticons addObject:emoticon];
        }
        fishGroup.emoticons = fishEmoticons;
        
        [groups addObject:fishGroup];

        //大表情 兔子
        NSString *emoticonRabbitBundlePath = [[NSBundle mainBundle]pathForResource:@"EmoticonRabbit" ofType:@"bundle"];
        NSDictionary *rabbitPlist = [NSDictionary dictionaryWithContentsOfFile:[emoticonRabbitBundlePath stringByAppendingPathComponent:@"emotion.plist"]];
        FaceEmoticonGroup *rabbitGroup = [[FaceEmoticonGroup alloc] init];
        rabbitGroup.emoticonType = FaceEmoticonTypeCustom;
        rabbitGroup.nameCN = rabbitGroup.nameEN = rabbitGroup.nameTW = @"灰兔";
        NSArray *rabbitAllKeys = [rabbitPlist allKeys];
        NSMutableArray *rabbitEmoticons = [NSMutableArray array];
        for (int i = 0; i < rabbitAllKeys.count; i ++) {
            NSString *key = rabbitAllKeys[i];
            FaceEmoticon *emoticon = [[FaceEmoticon alloc] init];
            emoticon.chs = emoticon.cht = key;
            emoticon.png = [emoticonRabbitBundlePath stringByAppendingPathComponent:[rabbitPlist[key] stringByAppendingString:@".png"]];
            emoticon.gif = [emoticonRabbitBundlePath stringByAppendingPathComponent:[rabbitPlist[key] stringByAppendingString:@".png"]];
            emoticon.type = FaceEmoticonTypeCustom;
            emoticon.group = rabbitGroup;
            
            [rabbitEmoticons addObject:emoticon];
        }
        rabbitGroup.emoticons = rabbitEmoticons;
        
        [groups addObject:rabbitGroup];
        
    });
    return groups;
}


@end
