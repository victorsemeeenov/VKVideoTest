//
//  AppDelegate.m
//  VKVideoTest
//
//  Created by Виктор Семенов on 11.11.2021.
//

#import "AppDelegate.h"
#import "PlayerViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self showPlayerScreen];
  return YES;
}

- (void)showPlayerScreen {
  self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
  Player *player = [Player new];
  self.window.rootViewController = [[PlayerViewController alloc] initWithPlayer:player];
  [self.window makeKeyAndVisible];
}

@end
