//
//  HospitalViewController.h
//  m-Order
//
//  Created by HSU CHIH YUAN on 12/8/3.
//  Copyright (c) 2012年 HSU CHIH YUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBJsonParser.h"
#import "TDBadgedCell.h"
#import "YRDropdownView.h"
#import "MBProgressHUD.h"
#import "MyAnnotation.h"
#import "ShowTeamDetailViewController.h"

#import "ASIFormDataRequest.h"
#import "EmbedReaderViewController.h"
#pragma Host
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "AuthenticationViewController.h"

@protocol ShowTeamViewControllerDelegate
- (void)showSelfViewer:(NSMutableDictionary*)obj;
@end

@interface ShowTeamViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    BOOL isInit;
    NSMutableArray * dataset;
    UITableView *tableView;
}

@property (nonatomic, assign) NSObject<ShowTeamViewControllerDelegate> *delegate;

//- (void) dynamicCenter;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray * dataset;

@end
