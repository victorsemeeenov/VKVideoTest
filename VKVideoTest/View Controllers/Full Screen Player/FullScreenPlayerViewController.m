//
//  FullScreenPlayerViewController.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 13.11.2021.
//

#import "FullScreenPlayerViewController.h"
#import "PlayerView.h"
#import "Throttler.h"

@interface FullScreenPlayerViewController ()

@property (nonatomic) PlayerView *playerView;
@property (nonatomic) Player *player;
@property (nonatomic) UIButton *playButton;
@property (nonatomic) UIButton *skipForwardButton;
@property (nonatomic) UIButton *skipBackwardButton;
@property (nonatomic) UIProgressView *progressView;
@property (nonatomic) UIButton *muteButton;
@property (nonatomic) BOOL isControlsHidden;
@property (nonatomic) Throttler *throttler;

@end

@implementation FullScreenPlayerViewController
#pragma mark - Init

- (instancetype)initWithPlayer:(Player *)player {
  self = [super init];
  if (self) {
    _player = player;
    [_player.delegates addDelegate:self];
    _playerView = [[PlayerView alloc] init];
    _playerView.player = _player.player;
    _playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _skipForwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _skipBackwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _muteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _progressView = [UIProgressView new];
    _throttler = [[Throttler alloc] initWithTimeInterval:5];
  }
  return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setup];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self hideControlsOnAppear];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  CGSize size = self.view.bounds.size;
  if (size.width > size.height) {
    _playerView.videoGravity = AVLayerVideoGravityResizeAspectFill;
  } else {
    _playerView.videoGravity = AVLayerVideoGravityResizeAspect;
  }
}

#pragma mark - Setup

- (void)hideControlsOnAppear {
  __weak FullScreenPlayerViewController *weakSelf = self;
  [_throttler perform:^{
    [weakSelf toggleControlsVisibility];
  }];
}

- (void)setup {
  self.view.backgroundColor = UIColor.whiteColor;
  [self setupPlayerView];
  [self setupPlayButton];
  [self setupSkipForwardButton];
  [self setupSkipBackwardButton];
  [self setupProgressView];
  [self setupMuteButton];
  [self addTapGesture];
  [self addSwipeGesture];
}

- (void)setupPlayerView {
  [self.view addSubview:_playerView];
  _playerView.translatesAutoresizingMaskIntoConstraints = false;
  NSLayoutConstraint *top = [_playerView.topAnchor constraintEqualToAnchor:self.view.topAnchor];
  NSLayoutConstraint *leading = [_playerView.leadingAnchor
                                 constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor];
  NSLayoutConstraint *trailing = [_playerView.trailingAnchor
                                  constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor];
  NSLayoutConstraint *bottom = [_playerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
  [NSLayoutConstraint activateConstraints:@[top, leading, trailing, bottom]];
}

- (void)setupPlayButton {
  [self.view addSubview:_playButton];
  [_playButton addTarget:self
                  action:@selector(playOrPause)
        forControlEvents:UIControlEventTouchUpInside];
  _playButton.translatesAutoresizingMaskIntoConstraints = false;
  [self updatePlayIcon];
  NSLayoutConstraint *centerY = [_playButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor];
  NSLayoutConstraint *centerX = [_playButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor];
  NSLayoutConstraint *width = [_playButton.widthAnchor constraintEqualToConstant:24];
  NSLayoutConstraint *height = [_playButton.heightAnchor constraintEqualToConstant:24];
  [NSLayoutConstraint activateConstraints:@[centerY, centerX, width, height]];
}

- (void)updatePlayIcon {
  UIImage *icon = [UIImage imageNamed:_player.isPlaying ? @"pause" : @"play"];
  [_playButton setImage:icon forState:UIControlStateNormal];
}

- (void)setupSkipForwardButton {
  [self.view addSubview:_skipForwardButton];
  [_skipForwardButton addTarget:self
                         action:@selector(skipForward)
               forControlEvents:UIControlEventTouchUpInside];
  _skipForwardButton.translatesAutoresizingMaskIntoConstraints = false;
  UIImage *image = [UIImage imageNamed:@"fast-forward"];
  if (image.CGImage) {
    UIImage *icon = [[UIImage imageWithCGImage:image.CGImage
                                        scale:1.0
                                  orientation:UIImageOrientationUpMirrored]
                     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal
                     ];
    [_skipForwardButton setImage:icon forState:UIControlStateNormal];
  }
  NSLayoutConstraint *leading = [_skipForwardButton.leadingAnchor
                                 constraintEqualToAnchor:self.playButton.trailingAnchor
                                 constant:16];
  NSLayoutConstraint *centerY = [_skipForwardButton.centerYAnchor
                                 constraintEqualToAnchor:self.playButton.centerYAnchor];
  NSLayoutConstraint *width = [_skipForwardButton.widthAnchor
                               constraintEqualToConstant:24];
  NSLayoutConstraint *height = [_skipForwardButton.heightAnchor
                                constraintEqualToConstant:24];
  [NSLayoutConstraint activateConstraints:@[leading, centerY, width, height]];
}

- (void)setupSkipBackwardButton {
  [self.view addSubview:_skipBackwardButton];
  [_skipBackwardButton addTarget:self
                          action:@selector(skipBackward)
                forControlEvents:UIControlEventTouchUpInside];
  [_skipBackwardButton setImage:[UIImage imageNamed:@"fast-forward"]
                       forState:UIControlStateNormal];
  _skipBackwardButton.translatesAutoresizingMaskIntoConstraints = false;
  NSLayoutConstraint *trailing = [_skipBackwardButton.trailingAnchor
                                  constraintEqualToAnchor:self.playButton.leadingAnchor
                                  constant:-16];
  NSLayoutConstraint *centerY = [_skipBackwardButton.centerYAnchor
                                 constraintEqualToAnchor:self.playButton.centerYAnchor];
  NSLayoutConstraint *width = [_skipBackwardButton.widthAnchor
                               constraintEqualToConstant:24];
  NSLayoutConstraint *height = [_skipBackwardButton.heightAnchor
                                constraintEqualToConstant:24];
  [NSLayoutConstraint activateConstraints: @[trailing, centerY, width, height]];
}

- (void)setupProgressView {
  [self.view addSubview:_progressView];
  _progressView.progress = _player.progress;
  _progressView.translatesAutoresizingMaskIntoConstraints = false;
  NSLayoutConstraint *leading = [_progressView.leadingAnchor
                                 constraintEqualToAnchor:self.view.leadingAnchor
                                 constant:16];
  NSLayoutConstraint *bottom = [_progressView.bottomAnchor
                                constraintEqualToAnchor:self.view.bottomAnchor
                                constant:-40];
  [NSLayoutConstraint activateConstraints:@[leading, bottom]];
}

- (void)setupMuteButton {
  [self.view addSubview:_muteButton];
  [_muteButton addTarget:self
                  action:@selector(toggleMute)
        forControlEvents:UIControlEventTouchUpInside];
  [self updateMuteIcon];
  _muteButton.translatesAutoresizingMaskIntoConstraints = false;
  NSLayoutConstraint *trailing = [_muteButton.trailingAnchor
                                  constraintEqualToAnchor:self.view.trailingAnchor
                                  constant:-16];
  NSLayoutConstraint *centerY = [_muteButton.centerYAnchor
                                constraintEqualToAnchor:_progressView.centerYAnchor
                                constant:-40];
  NSLayoutConstraint *leading = [_muteButton.leadingAnchor
                                 constraintEqualToAnchor:_progressView.trailingAnchor
                                 constant:-16];
  NSLayoutConstraint *width = [_muteButton.widthAnchor constraintEqualToConstant:24];
  NSLayoutConstraint *height = [_muteButton.heightAnchor constraintEqualToConstant:24];
  [NSLayoutConstraint activateConstraints:@[leading, trailing, centerY, width, height]];
}

- (void)updateMuteIcon {
  UIImage *icon = [UIImage imageNamed:_player.isMuted ? @"muted" : @"mute"];
  [_muteButton setImage:icon forState:UIControlStateNormal];
}

- (void)addTapGesture {
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(toggleControlsVisibility)];
  [self.view addGestureRecognizer:tapGesture];
}

- (void)addSwipeGesture {
  UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(close)];
  swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
  [self.view addGestureRecognizer:swipeGesture];
}

#pragma mark - Actions

- (void)playOrPause {
  [_player playOrPause];
};

- (void)skipForward {
  [_player skipForward];
}

- (void)skipBackward {
  [_player skipBackward];
}

- (void)toggleMute {
  [_player toggleMute];
  [self updateMuteIcon];
}

- (void)toggleControlsVisibility {
  _isControlsHidden = !_isControlsHidden;
  CGFloat alpha = _isControlsHidden ? 0 : 1;
  [UIView animateWithDuration:0.3 animations:^{
    self.playButton.alpha = alpha;
    self.skipBackwardButton.alpha = alpha;
    self.skipForwardButton.alpha = alpha;
    self.progressView.alpha = alpha;
    self.muteButton.alpha = alpha;
  }];
  if (!_isControlsHidden) {
    [self hideControlsOnAppear];
  } else {
    [_throttler cancel];
  }
}

- (void)close {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PlayerDelegate
- (void)player:(Player *)player didUpdateCurrentTime:(NSTimeInterval)currentTime withProgress:(float)progress {
  [_progressView setProgress:progress animated:true];
}

- (void)player:(Player *)player didUpdatePlayingState:(BOOL)isPlaying {
  [self updatePlayIcon];
}

@end
