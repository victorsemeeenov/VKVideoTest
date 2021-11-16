//
//  PlayerViewController.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 11.11.2021.
//

@import AVFoundation;
@import UIKit;
#import "PlayerViewController.h"
#import "FullScreenPlayerViewController.h"
#import "PlayerView.h"

@interface PlayerViewController ()

@property (nonatomic) PlayerView *playerView;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UIButton *playButton;
@property (nonatomic) Player *player;
@property (nonatomic) UIButton *muteButton;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) UIButton *downloadButton;
@property (nonatomic) UILabel *progressLabel;
@property (nonatomic) FilesLoader *filesLoader;

@end

@implementation PlayerViewController

#pragma mark - Init

- (instancetype)initWithPlayer:(Player *)player {
  self = [super init];
  if (self) {
    _player = player;
    [_player.delegates addDelegate:self];
    _playerView = [[PlayerView alloc] init];
    _textField = [[UITextField alloc] init];
    _playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _muteButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _activityIndicator = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    _downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _progressLabel = [UILabel new];
    _filesLoader = [FilesLoader new];
    _filesLoader.delegate = self;
  }
  return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setup];
}

#pragma mark - Setup

- (void)setup {
  self.view.backgroundColor = UIColor.whiteColor;
  [self setupPlayerView];
  [self setupActivityIndicator];
  [self setupMuteButton];
  [self setupTextField];
  [self setupPlayButton];
  [self setupDownloadButton];
  [self setupProgressLabel];
  [self setupGestureRecognizer];
}

- (void)setupPlayerView {
  [self.view addSubview:_playerView];
  _playerView.backgroundColor = UIColor.blackColor;
  _playerView.translatesAutoresizingMaskIntoConstraints = NO;
  NSLayoutConstraint *top = [_playerView.topAnchor
                             constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor];
  NSLayoutConstraint *leading = [_playerView.leadingAnchor
                                 constraintEqualToAnchor:self.view.leadingAnchor];
  NSLayoutConstraint *trailing = [_playerView.trailingAnchor
                                  constraintEqualToAnchor:self.view.trailingAnchor];
  NSLayoutConstraint *height = [_playerView.heightAnchor
                                constraintEqualToAnchor:_playerView.widthAnchor
                                multiplier:9.0 / 16];
  [NSLayoutConstraint activateConstraints:@[top, leading, trailing, height]];
}

- (void)setupActivityIndicator {
  [self.view addSubview:_activityIndicator];
  _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
  NSLayoutConstraint *centerY = [_activityIndicator.centerYAnchor
                                 constraintEqualToAnchor:_playerView.centerYAnchor];
  NSLayoutConstraint *centerX = [_activityIndicator.centerXAnchor
                                 constraintEqualToAnchor:_playerView.centerXAnchor];
  [NSLayoutConstraint activateConstraints:@[centerY, centerX]];
  _activityIndicator.hidesWhenStopped = true;
  _activityIndicator.hidden = true;
}

- (void)setupMuteButton {
  [self.view addSubview:_muteButton];
  [self updateMuteIcon];
  [_muteButton addTarget:self
                  action:@selector(toggleMute)
        forControlEvents:UIControlEventTouchUpInside];
  _muteButton.translatesAutoresizingMaskIntoConstraints = NO;
  NSLayoutConstraint *trailing = [_muteButton.trailingAnchor
                                  constraintEqualToAnchor:_playerView.trailingAnchor
                                  constant:-16];
  NSLayoutConstraint *bottom = [_muteButton.bottomAnchor
                                constraintEqualToAnchor:_playerView.bottomAnchor
                                constant:-16];
  NSLayoutConstraint *height = [_muteButton.heightAnchor constraintEqualToConstant:16];
  NSLayoutConstraint *width = [_muteButton.widthAnchor constraintEqualToConstant:16];
  [NSLayoutConstraint activateConstraints: @[trailing, bottom, height, width]];
}

- (void)updateMuteIcon {
  UIImage *icon = [UIImage imageNamed:_player.isMuted ? @"muted" : @"mute"];
  [_muteButton setImage:icon forState:UIControlStateNormal];
}

- (void)setupTextField {
  [self.view addSubview:_textField];
  _textField.borderStyle = UITextBorderStyleRoundedRect;
  _textField.translatesAutoresizingMaskIntoConstraints = NO;
  NSLayoutConstraint *top = [_textField.topAnchor
                             constraintEqualToAnchor:_playerView.bottomAnchor
                             constant:16];
  NSLayoutConstraint *leading = [_textField.leadingAnchor
                                 constraintEqualToAnchor:self.view.leadingAnchor
                                 constant:16];
  [NSLayoutConstraint activateConstraints: @[top, leading]];
}

- (void)setupPlayButton {
  [self.view addSubview:_playButton];
  [_playButton setTitle:@"Play" forState:UIControlStateNormal];
  [_playButton addTarget:self
                  action:@selector(play)
        forControlEvents:UIControlEventTouchUpInside];
  _playButton.translatesAutoresizingMaskIntoConstraints = NO;
  NSLayoutConstraint *leading = [_playButton.leadingAnchor
                                 constraintEqualToAnchor:_textField.trailingAnchor
                                 constant:16];
  NSLayoutConstraint *trailing = [_playButton.trailingAnchor
                                  constraintEqualToAnchor:self.view.trailingAnchor
                                  constant:-16];
  NSLayoutConstraint *centerY = [_playButton.centerYAnchor
                                 constraintEqualToAnchor:_textField.centerYAnchor];
  NSLayoutConstraint *width = [_playButton.widthAnchor constraintEqualToConstant:40];
  [NSLayoutConstraint activateConstraints: @[leading, trailing, centerY, width]];
}

- (void)setupDownloadButton {
  [self.view addSubview:_downloadButton];
  [_downloadButton setTitle:@"Download" forState:UIControlStateNormal];
  [_downloadButton addTarget:self
                      action:@selector(download)
            forControlEvents:UIControlEventTouchUpInside];
  _downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
  NSLayoutConstraint *leading = [_downloadButton.leadingAnchor
                                 constraintEqualToAnchor:self.view.leadingAnchor
                                 constant:16];
  NSLayoutConstraint *top = [_downloadButton.topAnchor
                             constraintEqualToAnchor:_textField.bottomAnchor
                             constant:16];
  [NSLayoutConstraint activateConstraints:@[leading, top]];
}

- (void)setupProgressLabel {
  [self.view addSubview:_progressLabel];
  _progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
  NSLayoutConstraint *top = [_progressLabel.topAnchor
                             constraintEqualToAnchor:_downloadButton.bottomAnchor
                             constant:16];
  NSLayoutConstraint *leading = [_progressLabel.leadingAnchor
                                 constraintEqualToAnchor:self.view.leadingAnchor
                                 constant:16];
  [NSLayoutConstraint activateConstraints:@[top, leading]];
}

- (void)setupGestureRecognizer {
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self
                                        action:@selector(showFullScreen)];
  [self.playerView addGestureRecognizer:tapGesture];
}

- (void)handleError:(NSError *)error {
  NSString *message = [NSString stringWithFormat:@"%@",
                       [error localizedDescription]];
  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
  [alertController addAction:okAction];
  [self presentViewController:alertController animated:true completion:nil];
}

#pragma mark - Actions

- (void)play {
  NSURL *url = [NSURL URLWithString: _textField.text];
  [_player play:url];
  _activityIndicator.hidden = NO;
  [_activityIndicator startAnimating];
}

- (void)showFullScreen {
  if (!_player.isPlaying) {
    return;
  }
  FullScreenPlayerViewController *viewController = [[FullScreenPlayerViewController alloc]
                                                    initWithPlayer:_player];
  viewController.modalPresentationStyle = UIModalPresentationFullScreen;
  [self presentViewController:viewController
                     animated:true
                   completion:nil];
}

- (void)toggleMute {
  [_player toggleMute];
  [self updateMuteIcon];
}

- (void)download {
  NSURL *url = [NSURL URLWithString: _textField.text];
  [_filesLoader downloadFileForURL:url];
}

#pragma mark - PlayerDelegate
- (void)player:(Player *)player didUpdatePlayingState:(BOOL)isPlaying {
  _playerView.player = player.player;
  if (isPlaying) {
    [_activityIndicator stopAnimating];
  }
}

- (void)player:(Player *)player didReceiveError:(NSError *)error {
  [self handleError:error];
}

- (void)loader:(FilesLoader *)loader didReceiveError:(NSError *)error {
  [self handleError:error];
}

#pragma mark - FilesLoaderDelegate

- (void)loader:(FilesLoader *)loader didUpdateProgress:(float)progress forURL:(NSURL *)url {
  if (![_textField.text isEqualToString:url.absoluteString]) {
    return;
  }
  NSString *progressTitle = [NSString stringWithFormat: @"Progress: %.2f", 100 * progress];
  _progressLabel.text = progressTitle;
}

- (void)loader:(FilesLoader *)loader didDownloadData:(NSData *)data forURL:(NSURL *)url {
  _progressLabel.text = @"Loaded";
}

@end
