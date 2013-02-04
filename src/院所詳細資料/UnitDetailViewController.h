//
//  HospitalDetailViewController.h
//  m-Order
//
//  Created by HSU CHIH YUAN on 12/8/8.
//  Copyright (c) 2012年 HSU CHIH YUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBJsonParser.h"
#import "TDBadgedCell.h"
#import "MarqueeLabel.h"
#import "YRDropdownView.h"
#import "DirectionsMap.h"
#import "SWSnapshotStackView.h"

@interface UnitDetailViewController : UIViewController<UIScrollViewDelegate, MBProgressHUDDelegate>
{
    BOOL isInit;
    NSMutableDictionary *dataElement;
    UIScrollView* mainView;
    UIView *myheader;
    
    UILabel *lblTitle;
    UILabel *lblAddrName;
    UILabel *lblAddr;
    UILabel *lblDateName;
    UILabel *lblDate;
    UILabel *lblTeamName;
    UILabel *lblTeam;
    UILabel *lblTimeName;
    UILabel *lblTime;
}

- (void)reloadObjectData:(NSString*)qrcode;
@property (nonatomic, retain) NSMutableDictionary *dataElement;

@end
