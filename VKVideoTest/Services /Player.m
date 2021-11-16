//
//  Player.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 11.11.2021.
//

#import "Player.h"
#import "AVPlayer+IsPlaying.h"
#import "Throttler.h"
#import "DiskCache.h"

static int32_t const Timescale = 1000.0;
static NSTimeInterval const SkipTimeInterval = 15;

@interface Player ()

@property (nonatomic) AVPlayer *player;
@property (nonatomic) NSObject *timeObserverToken;
@property (nonatomic) dispatch_queue_t playerQueue;
@property (nonatomic) NSTimeInterval fastForwardTime;
@property (nonatomic) Throttler *throttler;
@property (nonatomic) BOOL isSeeking;
@property (nonatomic) DiskCache *diskCache;

@end

@implementation PlayerMulticastDelegate
@end

@implementation Player
#pragma mark - Init

- (instancetype)init {
  self = [super init];
  if (self) {
    _delegates = [[PlayerMulticastDelegate alloc] init];
    dispatch_queue_attr_t attributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL,
                                                                        QOS_CLASS_USER_INITIATED,
                                                                        -1);
    _playerQueue = dispatch_queue_create("com.vkvideotest.player.serial.queue", attributes);
    _throttler = [[Throttler alloc] initWithTimeInterval:0.4];
    _diskCache = [DiskCache videosCache];
    [self addPlayerObserver];
  }
  return self;
}

- (void)dealloc {
  [self removeTimerObserver];
  [self removePlayerObserver];
  [self removeStatusObserver];
}

#pragma mark - Public

- (AVPlayer *)player {
  return _player;
}

- (void)playOrPause {
  if (self.isPlaying) {
    [self pause];
  } else {
    [self play];
  }
}

- (BOOL)isPlaying {
  if (_player) {
    return _player.isPlaying;
  } else {
    return NO;
  }
}

- (void)setItemWithURL:(NSURL *)url {
  AVPlayerItem *playerItem = [self makePlayerItemWithURL:url];
  if (_player == nil) {
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    [self addTimerObserver];
  } else {
    [_player replaceCurrentItemWithPlayerItem:playerItem];
  }
}

- (void)play:(NSURL *)url {
  [self setItemWithURL:url];
  [self play];
}

- (NSTimeInterval)currentTime {
  return CMTimeGetSeconds(_player.currentTime);
}

- (NSTimeInterval)duration {
  return CMTimeGetSeconds(_player.currentItem.asset.duration);
}

- (float)progress {
  return (float)(self.currentTime / self.duration);
}

- (void)skipForward {
  [self skipFewSeconds:SkipTimeInterval];
}

- (void)skipBackward {
  [self skipFewSeconds:-SkipTimeInterval];
}

- (void)skipFewSeconds:(NSTimeInterval)seconds {
  _isSeeking = YES;
  if (seconds > 0) {
    _fastForwardTime = MIN(_fastForwardTime + seconds, self.duration);
  } else {
    _fastForwardTime = MAX(_fastForwardTime + seconds, 0);
  }
  __weak Player *weakSelf = self;
  [_throttler perform:^{
    [weakSelf seekTime:weakSelf.fastForwardTime];
  }];
}

- (void)seekTime:(NSTimeInterval)timeInterval {
  __weak Player *weakSelf = self;
  [_player seekToTime:CMTimeMakeWithSeconds(timeInterval, Timescale) completionHandler:^(BOOL finished) {
    weakSelf.isSeeking = NO;
    if (!finished) {
      return;
    }
    [weakSelf.delegates player:weakSelf
          didUpdateCurrentTime:weakSelf.currentTime
                  withProgress:weakSelf.progress];
  }];
}

- (void)pause {
  dispatch_sync(_playerQueue, ^{
    [_player pause];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.delegates player:self didUpdatePlayingState:self.isPlaying];
    });
  });
}

- (void)play {
  dispatch_sync(_playerQueue, ^{
    [_player play];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.delegates player:self didUpdatePlayingState:self.isPlaying];
    });
  });
}

- (BOOL)isMuted {
  return _player.isMuted;
}

- (void)setMuted:(BOOL)isMuted {
  [_player setMuted:isMuted];
}

- (void)toggleMute {
  [self setMuted:!self.isMuted];
}

#pragma mark - Private

- (AVPlayerItem *)makePlayerItemWithURL:(NSURL *)url {
  AVAsset *asset = [self makeAssetWithURL:url];
  return [[AVPlayerItem alloc] initWithAsset:asset];
}

- (AVAsset *)makeAssetWithURL:(NSURL *)url {
  NSString *key = url.absoluteString;
  if ([_diskCache hasDataForKey:key]) {
    NSURL *url = [_diskCache fileURLForKey:key];
    AVAsset *loadedAsset = [AVAsset assetWithURL:url];
    return loadedAsset;
  } else {
    AVAsset *loadableAsset = [AVAsset assetWithURL:url];
    return loadableAsset;
  }
}

- (void)addTimerObserver {
  CMTimeScale timeScale = (CMTimeScale)NSEC_PER_SEC;
  CMTime time = CMTimeMakeWithSeconds(0.5, timeScale);
  
  __weak Player *weakSelf = self;
  _timeObserverToken = [_player addPeriodicTimeObserverForInterval:time
                                                             queue:dispatch_get_main_queue()
                                                        usingBlock:^(CMTime time) {
    [weakSelf updateCurrentTime];
  }];
}

- (void)addPlayerStatusObserver {
  [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeStatusObserver {
  [_player removeObserver:self forKeyPath:@"status"];
}

- (void)removeTimerObserver {
  if (_timeObserverToken) {
    [self.player removeTimeObserver:_timeObserverToken];
    self.timeObserverToken = nil;
  }
}

- (void)addPlayerObserver {
  NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
  [notificationCenter addObserver:self
                         selector:@selector(didFinishPlay)
                             name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
  [notificationCenter addObserver:self
                         selector:@selector(didFinishPlay)
                             name:AVPlayerItemFailedToPlayToEndTimeNotification
                           object:nil];
}

- (void)removePlayerObserver {
  NSNotificationCenter *notificationCenter = NSNotificationCenter.defaultCenter;
  [notificationCenter removeObserver:self
                                name:AVPlayerItemDidPlayToEndTimeNotification
                              object:nil];
  [notificationCenter removeObserver:self
                                name:AVPlayerItemFailedToPlayToEndTimeNotification
                              object:nil];
}

- (void)didFinishPlay {
  if (_player.status != AVPlayerStatusFailed) {
    [self seekTime:0];
  }
}

- (void)updateCurrentTime {
  if (!_isSeeking) {
    _fastForwardTime = self.currentTime;
  }
  [_delegates player: self didUpdateCurrentTime:self.currentTime withProgress: self.progress];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
  if (![keyPath  isEqual: @"status"] && object != _player) {
    return;
  }
  if (_player.status == AVPlayerStatusFailed && _player.error) {
    [_delegates player:self didReceiveError:_player.error];
  }
}

@end
