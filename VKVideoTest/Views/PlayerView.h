//
//  PlayerView.h
//  VKVideoTest
//
//  Created by Виктор Семенов on 13.11.2021.
//

#import <UIKit/UIKit.h>
@import AVFoundation;

@interface PlayerView : UIView

@property (readwrite) AVPlayer *player;
@property (nonatomic, readwrite) AVLayerVideoGravity videoGravity;

@end
