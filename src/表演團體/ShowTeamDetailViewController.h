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

@interface ShowTeamDetailViewController : UIViewController<UIScrollViewDelegate, UIWebViewDelegate>
{
    BOOL isInit;
    NSMutableDictionary *dataElement;
    SWSnapshotStackView *unitimage;
    UIScrollView* mainView;
    UIWebView *webView;
    
    UIView *myheader;
    UILabel *label;
}

- (void)reloadObjectData:(NSString*)qrcode;
@property (nonatomic, retain) NSMutableDictionary *dataElement;

@end
