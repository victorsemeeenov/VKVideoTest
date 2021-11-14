//
//  PlayerViewController.h
//  VKVideoTest
//
//  Created by Виктор Семенов on 11.11.2021.
//

@import UIKit;
#import "Player.h"

@interface PlayerViewController : UIViewController<PlayerDelegate>

- (instancetype)initWithPlayer:(Player *)player;

@end
