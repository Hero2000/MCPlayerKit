//
//  PlayerConfig.m
//  WaQuVideo
//
//  Created by imooc on 16/5/4.
//  Copyright © 2016年 mjc inc. All rights reserved.
//

#import "PlayerConfig.h"


//////////////////////AVPlayerKVO///////////////////////////////////////////
NSString * const _k_Player_ExternalPlayBackActive               = @"externalPlaybackActive";
NSString * const _k_Player_Status                               = @"status";
NSString * const _k_Player_CurrentItem                          = @"currentItem";

//////////////////////AVPlayerItem//////////////////////////////////////////////////////
NSString * const _k_PlayerItem_Status                           = @"status";
NSString * const _k_PlayerItem_PlaybackBufferEmpty              = @"playbackBufferEmpty";
NSString * const _k_PlayerItem_PlaybackLikelyToKeepUp           = @"playbackLikelyToKeepUp";
NSString * const _k_PlayerItem_LoadedTimeRanges                 = @"loadedTimeRanges";

@implementation PlayerConfig

+ (instancetype)sharedPlayerConfig {
    static dispatch_once_t predicate;
    static PlayerConfig * _playerConfig = nil;
    dispatch_once(&predicate, ^{
        _playerConfig = [[self alloc] init];
    });
    return _playerConfig;
}

@end