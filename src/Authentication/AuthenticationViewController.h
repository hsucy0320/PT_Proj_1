//
//  FVEViewController.h
//  FlipNumberViewExample
//
//  Created by Markus Emrich on 07.08.12.
//  Copyright (c) 2012 markusemrich. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#pragma Host
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "YRDropdownView.h"

#import "SBJsonParser.h"

@protocol AuthenticationViewControllerDelegate
- (void)removeSelfViewer;
@end

@interface AuthenticationViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MBProgressHUDDelegate, NSXMLParserDelegate>
{
    UITableView *tableView;
    UITextField *nameTextView;
    //UITextField *telTextView;
    //UITextField *addrTextView;
    //UITextField *emailTextView;
    UITextField *didTextView;
    //http
    ASIFormDataRequest *requestObj;
    BOOL httpSemaphore;
    MBProgressHUD *httpHUD;
    NSMutableString *jsonContent;
    BOOL returnFlag;
}

-(void)setViewDidLoad;
@property (nonatomic, assign) NSObject<AuthenticationViewControllerDelegate> *delegate;
#pragma Host Function
- (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address;
- (NSString *) getIPAddressForHost: (NSString *) theHost;
- (BOOL) hostAvailable: (NSString *) theHost;
- (void)pushProfileToWS:(NSString*)did name:(NSString*)name tel:(NSString*)tel addr:(NSString*)addr email:(NSString*)email;
-(void) setHeaderView;
- (NSString *) uuid;
@property (nonatomic, retain) UITextField *nameTextView;
//@property (nonatomic, retain) UITextField *telTextView;
//@property (nonatomic, retain) UITextField *addrTextView;
//@property (nonatomic, retain) UITextField *emailTextView;
@property (nonatomic, retain) UITextField *didTextView;

@end
