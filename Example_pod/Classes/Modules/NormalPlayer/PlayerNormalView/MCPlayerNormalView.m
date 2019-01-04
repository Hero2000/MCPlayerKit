//
// Created by majiancheng on 2017/3/17.
// Copyright (c) 2017 mjc inc. All rights reserved.
//

#import "MCPlayerNormalView.h"

#import <MCStyle/MCStyleDef.h>

#import "MCPlayerNormalHeader.h"
#import "MCPlayerNormalFooter.h"
#import "MCPlayerNormalTouchView.h"
#import "MCRotateHelper.h"
#import "MCPlayerKit.h"
#import "MCPlayerLoadingView.h"

@interface MCPlayerNormalView () <MCPlayerDelegate>

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) MCPlayerNormalTouchView *touchView;
@property(nonatomic, strong) MCPlayerBaseView *playerView;
@property(nonatomic, strong) MCPlayerLoadingView *loadingView;

@property(nonatomic, strong) MCPlayerNormalHeader *topView;
@property(nonatomic, strong) MCPlayerNormalFooter *bottomView;
@property(nonatomic, strong) UIButton *lockBtn;
@property(nonatomic, strong) UIView *definitionView;

@property(nonatomic, weak) MCPlayerKit *playerKit;


@end

@implementation MCPlayerNormalView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self createViews];
    [self addLayout];
    [self addActions];
    [self.loadingView startRotating];
}

- (void)updatePlayerStyle:(MCPlayerStyleSizeType)styleSizeType {
    if (self.styleSizeType == styleSizeType) return;
    self.styleSizeType = styleSizeType;
    [self.topView updatePlayerStyle:styleSizeType];
    [self.bottomView updatePlayerStyle:styleSizeType];
    switch (self.styleSizeType) {
        case PlayerStyleSizeClassRegularHalf: {
        }
            break;
        case PlayerStyleSizeClassRegular: {

        }
            break;
        case PlayerStyleSizeClassCompact: {

        }
            break;
    }
}

- (void)updateTitle:(NSString *)title {
    self.topView.titleLabel.text = title;
}

- (BOOL)isLock {
    return self.lockBtn.selected;
}

- (void)currentTime:(double)time {
    [self updateProgress:time / self.playerKit.duration];
    [self.bottomView currentTime:time];
}

- (void)duration:(double)time {
    [self.bottomView duration:time];
}

- (void)updateProgress:(float)progress {
    [self.bottomView updateProgress:progress];
}

- (void)updateBufferProgress:(float)progress {
    [self.bottomView updateBufferProgress:progress];
}

- (void)updateAction:(MCPlayerKit *)playerKit {
    self.playerKit = playerKit;
    self.playerKit.delegate = self;
}


#pragma mark - views

- (void)createViews {
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.playerView];
    [self.containerView addSubview:self.touchView];
    [self.containerView addSubview:self.topView];
    [self.containerView addSubview:self.bottomView];
    [self.containerView addSubview:self.lockBtn];
    [self.containerView addSubview:self.definitionView];

    [self.containerView addSubview:self.loadingView];

    self.topView.titleLabel.text = @"Skipping code signing because the target does not have an Info.plist file. (in target 'App')";
}

- (void)addLayout {
    if (CGRectIsEmpty(self.frame)) return;
    self.containerView.frame = self.bounds;
    //TODO:: 2018 devices
    self.touchView.frame = self.containerView.bounds;
    self.playerView.frame = self.containerView.bounds;
    CGFloat w = CGRectGetWidth(self.containerView.frame);
    CGFloat h = CGRectGetHeight(self.containerView.frame);
    CGFloat barRate = 0.1f;
    CGFloat barHeight = 44;
    self.topView.frame = CGRectMake(0, 0, w, barHeight + self.topView.top);
    self.bottomView.frame = CGRectMake(0, h - barHeight, w, barHeight);

    CGFloat lockW = 44;
    self.lockBtn.frame = CGRectMake(10, (h - lockW) / 2.0f, lockW, lockW);
    self.loadingView.frame = self.containerView.bounds;
}

- (void)addActions {
    __weak typeof(self) weakSelf = self;
    self.topView.callBack = ^id(NSString *action, id value) {
        __strong typeof(weakSelf) strongself = weakSelf;
        if ([action isEqualToString:kMCPlayerHeaderBack2Half]) {
            [MCRotateHelper updatePlayerRegularHalf];
            [strongself updatePlayerStyle:PlayerStyleSizeClassRegularHalf];
        } else if ([action isEqualToString:kMCPlayerHeaderBack]) {
            UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *navigationController;
            if ([viewController isKindOfClass:[UINavigationController class]]) {
                navigationController = (UINavigationController *) viewController;
            } else if (viewController.navigationController) {
                navigationController = viewController.navigationController;
            }
            if (navigationController) {
                [navigationController popViewControllerAnimated:YES];
            } else {
                //TODO test presentDismiss
                [viewController dismissViewControllerAnimated:YES completion:NULL];
            }
        }
        if (strongself.eventCallBack) {
            strongself.eventCallBack(action, value);
        }
        return nil;
    };

    self.touchView.callBack = ^id(NSString *action, id value) {
        __strong typeof(weakSelf) strongself = weakSelf;
        if ([action isEqualToString:kMCTouchTapAction]) {
            [strongself showControlThenHide];
        }
        if (strongself.eventCallBack) {
            return strongself.eventCallBack(action, value);
        }
        return nil;
    };

    self.bottomView.callBack = ^id(NSString *action, id value) {
        __strong typeof(weakSelf) strongself = weakSelf;
        if ([action isEqualToString:kMCPlayer2HalfScreenAction]) {
            [MCRotateHelper updatePlayerRegularHalf];
            [strongself updatePlayerStyle:PlayerStyleSizeClassRegularHalf];
            [strongself showControlThenHide];
        } else if ([action isEqualToString:kMCPlayer2FullScreenAction]) {
            //TODO:: 竖屏全屏
            [MCRotateHelper updatePlayerRegular];
            [strongself updatePlayerStyle:PlayerStyleSizeClassCompact];
            [strongself showControlThenHide];
        } else if ([action isEqualToString:kMCPlayer2PlayAction]) {
            [strongself showControlThenHide];
        } else if ([action isEqualToString:kMCPlayer2PauseAction]) {
            [strongself showControlThenHide];
        } else if ([action isEqualToString:kMCControlProgressStartDragSlider]) {
            [strongself showControl];
        } else if ([action isEqualToString:kMCDragProgressToProgress]) {
            [strongself.playerKit seekSeconds:strongself.playerKit.duration * [value floatValue]];
        } else if ([action isEqualToString:kMCControlProgressEndDragSlider]) {
            [strongself showControlThenHide];
        }

        if (strongself.eventCallBack) {
            strongself.eventCallBack(action, value);
        }
        return nil;
    };

    self.eventCallBack = ^id(NSString *action, id value) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([action isEqualToString:kMCPlayer2PlayAction]) {
            [strongSelf.playerKit play];
        } else if ([action isEqualToString:kMCPlayer2PauseAction]) {
            [strongSelf.playerKit pause];
        } else if ([action isEqualToString:kMCTouchCurrentTimeAction]) {
            return @(strongSelf.playerKit.currentTime);
        } else if ([action isEqualToString:kMCTouchDurationAction]) {
            return @(strongSelf.playerKit.duration);
        } else if ([action isEqualToString:kMCTouchSeekAction]) {
            [strongSelf.playerKit seekSeconds:[value integerValue]];
        }
        return nil;
    };
}

- (void)fadeHiddenControl {
    [self.topView fadeHiddenControl];
    [self.bottomView fadeHiddenControl];
    self.lockBtn.hidden = YES;
}

- (void)showControl {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeHiddenControl) object:nil];
    [self.topView showControl];
    [self.bottomView showControl];
    self.lockBtn.hidden = NO;
}

- (void)showControlThenHide {
    if ([self isLock]) {
        self.lockBtn.hidden = NO;
        [self.lockBtn performSelector:@selector(setHidden:) withObject:@(YES) afterDelay:3];
    } else {
        [self showControl];
        [self performSelector:@selector(fadeHiddenControl) withObject:nil afterDelay:3];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addLayout];
}

#pragma mark Actions

- (void)lockBtnClick {
    self.lockBtn.selected = !self.lockBtn.selected;
    //TODO:: lock
}


#pragma mark - MCPlayerDelegate

- (void)playLoading {
    [self.loadingView startRotating];
}

- (void)playBuffer {
    [self.loadingView startRotatingNoBg];
}

- (void)playStart {
    [self.loadingView endRotating];
    [self duration:self.playerKit.duration];
}

- (void)playPlay {

}

- (void)playEnd {

}

- (void)playError {

}

- (void)updatePlayView {

}

#pragma mark - getter

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
    }
    return _containerView;
}

- (MCPlayerNormalTouchView *)touchView {
    if (!_touchView) {
        _touchView = [MCPlayerNormalTouchView new];
    }
    return _touchView;
}

- (MCPlayerBaseView *)playerView {
    if (!_playerView) {
        _playerView = [MCPlayerBaseView new];
        _playerView.userInteractionEnabled = NO;
    }
    return _playerView;
}

- (MCPlayerNormalHeader *)topView {
    if (!_topView) {
        _topView = [MCPlayerNormalHeader new];
    }
    return _topView;
}

- (MCPlayerNormalFooter *)bottomView {
    if (!_bottomView) {
        _bottomView = [MCPlayerNormalFooter new];
    }
    return _bottomView;
}

- (UIButton *)lockBtn {
    if (!_lockBtn) {
        _lockBtn = [UIButton new];
        [_lockBtn setImage:[MCStyle customImage:@"player_body_0"] forState:UIControlStateNormal];
        [_lockBtn setImage:[MCStyle customImage:@"player_body_0_s"] forState:UIControlStateSelected];
        [_lockBtn addTarget:self action:@selector(lockBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lockBtn;
}

- (UIView *)definitionView {
    return nil;
}

- (MCPlayerLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [MCPlayerLoadingView new];
    }
    return _loadingView;
}

@end

