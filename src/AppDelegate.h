//
//  AppDelegate.h
//  m-Order
//
//  Created by HSU CHIH YUAN on 12/8/1.
//  Copyright (c) 2012年 HSU CHIH YUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <AudioToolbox/AudioToolbox.h>
#import "HospitalUnitViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    HospitalUnitViewController *_myMainPage;
}

@property (nonatomic, retain) UINavigationController *navController;
@property (strong, nonatomic) UIWindow *window;
- (void)AlertMessageBox : (NSString*)msg title:(NSString*)title;

@end
