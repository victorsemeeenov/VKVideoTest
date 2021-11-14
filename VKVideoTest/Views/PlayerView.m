//
//  PlayerView.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 13.11.2021.
//

#import "PlayerView.h"

@interface PlayerView ()

@property (nonatomic) AVPlayerLayer *playerLayer;

@end

@implementation PlayerView

- (instancetype)init {
  self = [super init];
  if (self) {
    _playerLayer = [AVPlayerLayer new];
    [self setup];
  }
  return self;
}

- (void)setPlayer:(AVPlayer *)player {
  [self playerLayer].player = player;
}

- (AVPlayer *)player {
  return _playerLayer.player;
}

- (AVLayerVideoGravity)videoGravity {
  return _playerLayer.videoGravity;
}

- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
  _playerLayer.videoGravity = videoGravity;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _playerLayer.frame = self.bounds;
}

- (void)setup {
  [self.layer addSublayer:_playerLayer];
  _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
}

@end
