//
//  FullScreenPlayerViewController.h
//  VKVideoTest
//
//  Created by Виктор Семенов on 13.11.2021.
//

@import UIKit;
#import "Player.h"

@interface FullScreenPlayerViewController: UIViewController<PlayerDelegate>

- (instancetype)initWithPlayer:(Player *)player;

@end
