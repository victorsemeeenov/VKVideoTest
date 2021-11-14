//
//  Player.h
//  VKVideoTest
//
//  Created by Виктор Семенов on 11.11.2021.
//

@import AVFoundation;
#import "MulticastDelegate.h"

@class Player;

#pragma mark - VideoPlayerDelegate
@protocol PlayerDelegate

@optional
- (void)player:(Player *)player didUpdatePlayingState:(BOOL)isPlaying;
- (void)player:(Player *)player didUpdateCurrentTime:(NSTimeInterval)currentTime
                          withProgress:(float)progress;

@end

#pragma mark - VideoPlayerMulticastDelegate
@interface PlayerMulticastDelegate: MulticastDelegate<PlayerDelegate>
@end

#pragma mark - VideoPlayer
@interface Player: NSObject

@property (nonatomic) PlayerMulticastDelegate *delegates;
@property (readonly) BOOL isPlaying;
@property (nonatomic, readwrite, setter=setMuted:) BOOL isMuted;
@property (readonly) float progress;
@property (readonly) NSTimeInterval currentTime;
@property (readonly) NSTimeInterval duration;

- (AVPlayer *)player;
- (void)playOrPause;
- (void)play:(NSURL *)url;
- (void)skipForward;
- (void)skipBackward;
- (void)seekTime:(NSTimeInterval)timeInterval;
- (void)pause;
- (void)play;
- (void)setMuted:(BOOL)isMuted;
- (void)toggleMute;

@end
