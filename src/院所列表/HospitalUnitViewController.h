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
#import "UnitDetailViewController.h"

#import "ASIFormDataRequest.h"
#import "EmbedReaderViewController.h"
#pragma Host
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "AuthenticationViewController.h"
#import "ShowTeamViewController.h"

@interface HospitalUnitViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MBProgressHUDDelegate, MKMapViewDelegate, NSXMLParserDelegate, EmbedReaderViewControllerDelegate, AuthenticationViewControllerDelegate, ShowTeamViewControllerDelegate, UIAlertViewDelegate>
{
    BOOL isInit;
    NSMutableArray * dataset;
    NSMutableArray * activitydataset;
    UITableView *tableView;
    UIView *tabBar;
    UIButton *btnList;
    UIButton *btnMap;
    UIButton *btnQRCode;
    UIButton *btnShow;
    CLLocationManager *locmanager;
    MBProgressHUD *HUD;
    BOOL isLocating;
    CLLocationCoordinate2D coor;
    CLLocationCoordinate2D objloc;
    //Map
    MKMapView *mapView;
    BOOL semaphoreMap;
    // QRCode
    EmbedReaderViewController *myEmbedReaderViewController;
    ShowTeamViewController *myShowTeamViewController;
    // Function Class
    int functionIndex;
    //http
    ASIFormDataRequest *requestObj;
    BOOL httpSemaphore;
    MBProgressHUD *httpHUD;
    NSMutableString *jsonContent;
    BOOL returnFlag;
    UnitDetailViewController *myUnitDetailViewController;
    AuthenticationViewController *myAuthenticationViewController;
    UIView *myheader;
    MarqueeLabel *rateLabel;
    NSString *strName;
}

@property (nonatomic, retain) NSString *strName;
-(void) reloadMap;
-(void) initWorking;
- (void) setViewDidLoad;
- (MKMapRect) getMapRectUsingAnnotations : (NSMutableArray *)data;
@property (nonatomic, retain) CLLocationManager *locmanager;
@property (nonatomic, retain) UIView *tabBar;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray * dataset;
@property (nonatomic, retain) NSMutableArray * activitydataset;
#pragma Host Function
- (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address;
- (NSString *) getIPAddressForHost: (NSString *) theHost;
- (BOOL) hostAvailable: (NSString *) theHost;
- (void)pushDataToWS:(NSString*)qrcode;
//建議不要再使用DeviceID
- (NSString *) uuid;

@end
