//
//  AppDelegate.m
//  m-Order
//
//  Created by HSU CHIH YUAN on 12/8/1.
//  Copyright (c) 2012年 HSU CHIH YUAN. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

-(void) getNetworkStatus{
# pragma 取得網路狀態
    //Create zero addy
    struct sockaddr_in Addr;
    bzero(&Addr, sizeof(Addr));
    Addr.sin_len = sizeof(Addr);
    Addr.sin_family = AF_INET;
    
    //結果存至旗標中
    SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &Addr);
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(target, &flags);
    
    //將取得結果與狀態旗標位元做AND的運算並輸出
    if (flags & kSCNetworkFlagsReachable)
    {
        NSLog(@"無線網路狀態ok");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"wifi"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"wifi"];
    }
    
    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
        NSLog(@"電信網路狀態ok");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"gprs"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"gprs"];
    }
}

//建議不要再使用DeviceID
- (NSString *) uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [NSString stringWithString:(NSString *)
                      uuidStringRef];
    CFRelease(uuidStringRef);
    return uuid;
}

//Best way to serialize a NSData into an hexadeximal string
-(NSString*) serializeDeviceToken:(NSData*) deviceToken
{
    NSMutableString *str = [NSMutableString stringWithCapacity:64];
    int length = [deviceToken length];
    char *bytes = malloc(sizeof(char) * length);
    
    [deviceToken getBytes:bytes length:length];
    
    for (int i = 0; i < length; i++)
    {
        [str appendFormat:@"%02.2hhX", bytes[i]];
    }
    free(bytes);
    
    return str;
}

#pragma 客制化警示視窗
- (void)AlertMessageBox : (NSString*)msg title:(NSString*)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil];
    
    // read "m-Order-Info.plist" from application bundle
    NSDictionary *dictionary = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIcons"];
    NSArray *icons = [[dictionary objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"];

    //image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 45, 57, 57)];
    if([icons count]>0) imageView.image = [UIImage imageNamed:[icons objectAtIndex:0]];
    [alert addSubview:imageView];
    
    // title
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(69.0, 45.0, 203.0, 25.0)];
    [myLabel setText:msg];
    // 動態設定Label高度
    CGRect currentFrame = myLabel.frame;
    CGSize max = CGSizeMake(myLabel.frame.size.width, 500);
    CGSize expected = [myLabel.text sizeWithFont:myLabel.font constrainedToSize:max lineBreakMode:myLabel.lineBreakMode];
    // 行數
    int lines = ceil(expected.height/currentFrame.size.height);
    // 設定alert.message
    NSMutableString *myNSMutableString = [[NSMutableString alloc] init];
    for(int i=0;i<lines+1;i++){
        [myNSMutableString appendString:@"\n"];
    }
    alert.message = myNSMutableString;
    [myNSMutableString release];
    // 重新設定UILabel大小
    currentFrame.size.height = (expected.height/lines)*(lines+1);
    myLabel.frame = currentFrame;
    //重新設定imageView位置
    [imageView setFrame:CGRectMake(imageView.frame.origin.x, myLabel.frame.origin.y+(myLabel.frame.size.height-imageView.frame.size.width)/2, imageView.frame.size.width, imageView.frame.size.height)];
    [imageView release];
    // 背景透明
    [myLabel setBackgroundColor:[UIColor clearColor]];
    // 置中對齊
    [myLabel setTextAlignment:UITextAlignmentCenter];
    myLabel.lineBreakMode=UILineBreakModeWordWrap;
    // 最多行數
    myLabel.numberOfLines=20;
    // 白色字體
    [myLabel setTextColor:[UIColor whiteColor]];
    // 字體大小
    [myLabel setFont:[UIFont systemFontOfSize:18]];
    [alert addSubview:myLabel];
    [myLabel release];
    
    [alert show];
    
    // do something u wanna
    AudioServicesPlaySystemSound(1106);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [alert release];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    _myMainPage = [[HospitalUnitViewController alloc] init];
    [_myMainPage.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    _myMainPage.title = @"民謠踩點趴趴GO";
    // do something u wanna
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
    _myMainPage.title = prodName;
    [_myMainPage setViewDidLoad];
    self.navController = [[[UINavigationController alloc] initWithRootViewController:_myMainPage] autorelease];
    self.navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    //客制化標頭文字
    CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 55);
    UIView *myheader = [[UIView alloc] init];
    [myheader setBackgroundColor:[UIColor clearColor]];
    [myheader setFrame:frame];
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_bar"]];
    [imageview setFrame:CGRectMake(-5, 0, [[UIScreen mainScreen] bounds].size.width, 55)];
    [myheader addSubview:imageview];
    [imageview release];
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.textAlignment = UITextAlignmentCenter;
    [myheader addSubview:label];
    self.navController.navigationItem.titleView = myheader;
    label.text = prodName;
    [label release];
    [myheader release];
    
    [[self window] setRootViewController:self.navController];
    
    UIImage *image = [UIImage imageNamed:@"BackgroundNoLogos.png"];
    UIImageView*imageView=[[UIImageView alloc]initWithImage:image];
    [imageView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [[self.navController view] addSubview:imageView];
    [[self.navController view] bringSubviewToFront:imageView];
    
    // as usual
    [self.window makeKeyAndVisible];
    
    //now fade out splash image
    [UIView transitionWithView:self.window duration:5.0f options:UIViewAnimationOptionTransitionNone animations:^(void){imageView.alpha=0.0f;} completion:^(BOOL finished){[imageView removeFromSuperview];}];
    
    return YES;
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:( NSDictionary *)userInfo {
#if !TARGET_IPHONE_SIMULATOR
    NSLog(@"remote notification: %@",[userInfo description]);
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    if (apsInfo) {
        if ([apsInfo objectForKey:@"alert"]) {
            // do something u wanna
            NSBundle *bundle = [NSBundle mainBundle];
            NSDictionary *info = [bundle infoDictionary];
            NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
            [self AlertMessageBox:[apsInfo objectForKey:@"alert"] title:prodName];
        }
    }
#endif
}

//休眠后委托事件
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //防止 Device 自動進入待機狀態
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground...");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground...");
}

//程序喚醒後要執行的事件
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //防止 Device 自動進入待機狀態
    NSLog(@"applicationDidBecomeActive...");
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self getNetworkStatus];
} 

// 在这里完成程序將要關閉的事情 
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // 在AppDelegate的applicationWillTerminate中發送自定義的Notification
    // post willterminate notification to allow views to save current status
    NSLog(@"applicationWillTerminate...");
}

@end
