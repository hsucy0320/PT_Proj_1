//
//  HospitalDetailViewController.m
//  m-Order
//
//  Created by HSU CHIH YUAN on 12/8/8.
//  Copyright (c) 2012年 HSU CHIH YUAN. All rights reserved.
//

#import "UnitDetailViewController.h"

@interface UnitDetailViewController ()

@end

@implementation UnitDetailViewController

@synthesize dataElement;

- (void)dealloc
{
    // 對特定的訊息事件取消訂閱
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"checkedCollectionQRCode" object:nil];
    if (isInit) {
        self.navigationItem.rightBarButtonItem = nil;
        [dataElement release];
    }
	
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)mapPathDirection:(id)sender
{
    NSLog(@"XDXD");
    DirectionsMap *myDirectionsMap = [[DirectionsMap alloc] init];
    
    [myDirectionsMap.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-navigationbarheight)];
    
    MKPointAnnotation* target = [[MKPointAnnotation alloc] init];
    target.title = [NSString stringWithFormat:@"%@", [dataElement objectForKey:@"title"]?[dataElement objectForKey:@"title"]:[dataElement objectForKey:@"name"]];
    target.coordinate = CLLocationCoordinate2DMake([[dataElement objectForKey:@"latitude"] floatValue], [[dataElement objectForKey:@"longitude"] floatValue]);
    
    [myDirectionsMap setPathDirection:target];
    [target release];
    
    [self.navigationController pushViewController:myDirectionsMap animated:YES];
    [myDirectionsMap release];
}

- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

#define lblfontsize 16
#define lblheight 20

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
    
	// Do any additional setup after loading the view.
    isInit = NO;
    if (!isInit) {
        
        //加入tableView
        mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, navigationbarheight, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-navigationbarheight)];
        mainView.backgroundColor = [UIColor clearColor];
        mainView.userInteractionEnabled=YES;
        mainView.showsVerticalScrollIndicator = NO;
        mainView.showsHorizontalScrollIndicator = NO;
        mainView.delegate = self;
        
        //lblTitle
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake((mainView.frame.size.width-300)/2, 30.0f, 300.0f, 80.0f)];
        [lblTitle setText:@""];
        [lblTitle setNumberOfLines:10];
        [lblTitle setLineBreakMode:lblTitle.lineBreakMode];
        [lblTitle setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20]];
        [lblTitle setTextColor:[UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1]];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:lblTitle];
        
        //lblAddr
        lblAddrName = [[UILabel alloc] initWithFrame:CGRectMake(10, 125.0f, 80.0f, lblheight)];
        [lblAddrName setText:@"地   址："];
        [lblAddrName setNumberOfLines:10];
        [lblAddrName setLineBreakMode:lblAddrName.lineBreakMode];
        [lblAddrName setFont:[UIFont fontWithName:@"Arial-BoldMT" size:lblfontsize]];
        [lblAddrName setTextColor:[UIColor blackColor]];
        [lblAddrName setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:lblAddrName];
        
        //lblAddr
        lblAddr = [[UILabel alloc] initWithFrame:CGRectMake(95, 125.0f, 200.0f, lblheight)];
        [lblAddr setText:@""];
        [lblAddr setNumberOfLines:10];
        [lblAddr setLineBreakMode:lblAddr.lineBreakMode];
        [lblAddr setFont:[UIFont fontWithName:@"Arial-BoldMT" size:lblfontsize]];
        [lblAddr setTextColor:[UIColor blackColor]];
        [lblAddr setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:lblAddr];
        
        //DateName
        lblDateName = [[UILabel alloc] initWithFrame:CGRectMake(10, 170.0f, 80.0f, lblheight)];
        [lblDateName setText:@"表演日期："];
        [lblDateName setNumberOfLines:10];
        [lblDateName setLineBreakMode:lblDateName.lineBreakMode];
        [lblDateName setFont:[UIFont fontWithName:@"Arial-BoldMT" size:lblfontsize]];
        [lblDateName setTextColor:[UIColor blackColor]];
        [lblDateName setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:lblDateName];
        
        //Date
        lblDate = [[UILabel alloc] initWithFrame:CGRectMake(95, 170.0f, 200.0f, lblheight)];
        [lblDate setText:@""];
        [lblDate setNumberOfLines:10];
        [lblDate setLineBreakMode:lblDate.lineBreakMode];
        [lblDate setFont:[UIFont fontWithName:@"Arial-BoldMT" size:lblfontsize]];
        [lblDate setTextColor:[UIColor blackColor]];
        [lblDate setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:lblDate];
        
        //TimeName
        lblTimeName = [[UILabel alloc] initWithFrame:CGRectMake(10, 225.0f, 80.0f, lblheight)];
        [lblTimeName setText:@"表演時間："];
        [lblTimeName setNumberOfLines:10];
        [lblTimeName setLineBreakMode:lblDateName.lineBreakMode];
        [lblTimeName setFont:[UIFont fontWithName:@"Arial-BoldMT" size:lblfontsize]];
        [lblTimeName setTextColor:[UIColor blackColor]];
        [lblTimeName setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:lblTimeName];
        
        //Time
        lblTime = [[UILabel alloc] initWithFrame:CGRectMake(95, 225.0f, 200.0f, lblheight)];
        [lblTime setText:@""];
        [lblTime setNumberOfLines:10];
        [lblTime setLineBreakMode:lblDate.lineBreakMode];
        [lblTime setFont:[UIFont fontWithName:@"Arial-BoldMT" size:lblfontsize]];
        [lblTime setTextColor:[UIColor blackColor]];
        [lblTime setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:lblTime];
        
        //TeamName
        lblTeamName = [[UILabel alloc] initWithFrame:CGRectMake(10, 280.0f, 80.0f, lblheight)];
        [lblTeamName setText:@"表演團體："];
        [lblTeamName setNumberOfLines:10];
        [lblTeamName setLineBreakMode:lblTeamName.lineBreakMode];
        [lblTeamName setFont:[UIFont fontWithName:@"Arial-BoldMT" size:lblfontsize]];
        [lblTeamName setTextColor:[UIColor blackColor]];
        [lblTeamName setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:lblTeamName];
        
        //Team
        lblTeam = [[UILabel alloc] initWithFrame:CGRectMake(95, 280.0f, 200.0f, lblheight)];
        [lblTeam setText:@""];
        [lblTeam setNumberOfLines:10];
        [lblTeam setLineBreakMode:lblDate.lineBreakMode];
        [lblTeam setFont:[UIFont fontWithName:@"Arial-BoldMT" size:lblfontsize]];
        [lblTeam setTextColor:[UIColor blackColor]];
        [lblTeam setBackgroundColor:[UIColor clearColor]];
        [mainView addSubview:lblTeam];
        
        [self.view addSubview:mainView]; // Add it as a subview of our main view
        
        //客制化標頭文字
        CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 55);
        myheader = [[UIView alloc] init];
        [myheader setBackgroundColor:[UIColor clearColor]];
        [myheader setFrame:frame];
        UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_bar"]];
        [imageview setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 55)];
        [myheader addSubview:imageview];
        [imageview release];
        
        UIButton *dButton=[UIButton buttonWithType:0];
        dButton.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-97-5),4,97,36);
        
        [dButton addTarget:self  action:@selector(mapPathDirection:)
          forControlEvents:UIControlEventTouchUpInside];
        [dButton setImage:[UIImage imageNamed:@"path"]
                 forState:UIControlStateNormal];
        dButton.adjustsImageWhenHighlighted = NO; // 默認情況下，按鈕按下時圖像顏色變淡，要禁用則設為NO
        dButton.adjustsImageWhenDisabled = NO; // 默認情況下，按鈕被禁用時圖像顏色變深，禁用則設為NO
        dButton.showsTouchWhenHighlighted = YES; // 可令按鈕在按下時發光。可用於信息按鈕或重要的按鈕
        dButton.tag = 0;
        dButton.backgroundColor=[UIColor clearColor];
        [myheader addSubview:dButton];
        
        UIButton *btnBack=[UIButton buttonWithType:0];
        btnBack.frame=CGRectMake(5,7,49,29);
        
        [btnBack addTarget:self  action:@selector(btnBackEvent:)
          forControlEvents:UIControlEventTouchUpInside];
        [btnBack setImage:[UIImage imageNamed:@"btn_home"]
                 forState:UIControlStateNormal];
        btnBack.adjustsImageWhenHighlighted = NO; // 默認情況下，按鈕按下時圖像顏色變淡，要禁用則設為NO
        btnBack.adjustsImageWhenDisabled = NO; // 默認情況下，按鈕被禁用時圖像顏色變深，禁用則設為NO
        btnBack.showsTouchWhenHighlighted = YES; // 可令按鈕在按下時發光。可用於信息按鈕或重要的按鈕
        btnBack.tag = 0;
        btnBack.backgroundColor=[UIColor clearColor];
        [myheader addSubview:btnBack];
        
        [self.view addSubview:myheader];
        
        isInit = YES;
    }
}

-(void)btnBackEvent:(id)sender{
    [[self navigationController] popViewControllerAnimated:NO];
}

#pragma 重新載入資料
- (void)reloadObjectData:(NSString*)qrcode{
    lblTitle.text = [dataElement objectForKey:@"title"];
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(lblTitle.frame.size.width,9999);
    CGSize expectedLabelSize = [lblTitle.text sizeWithFont:lblTitle.font constrainedToSize:maximumLabelSize lineBreakMode:lblTitle.lineBreakMode];
    //adjust the label the the new height.
    CGRect newFrame = lblTitle.frame;
    newFrame.size.height = expectedLabelSize.height;
    lblTitle.frame = newFrame;
    
    [lblAddrName setFrame:CGRectMake(lblAddrName.frame.origin.x, lblTitle.frame.origin.y+lblTitle.frame.size.height+35, lblAddrName.frame.size.width, lblAddrName.frame.size.height)];
    
    lblAddr.text = [dataElement objectForKey:@"addr"];
    //Calculate the expected size based on the font and linebreak mode of your label
    maximumLabelSize = CGSizeMake(lblAddr.frame.size.width,9999);
    expectedLabelSize = [lblAddr.text sizeWithFont:lblAddr.font constrainedToSize:maximumLabelSize lineBreakMode:lblAddr.lineBreakMode];
    //adjust the label the the new height.
    newFrame = lblAddr.frame;
    newFrame.origin.y = lblAddrName.frame.origin.y;
    newFrame.size.height = expectedLabelSize.height;
    lblAddr.frame = newFrame;
    
    [lblDateName setFrame:CGRectMake(lblDateName.frame.origin.x, lblAddr.frame.origin.y+lblAddr.frame.size.height+35, lblDateName.frame.size.width, lblDateName.frame.size.height)];
    
    lblDate.text = [dataElement objectForKey:@"date"];
    //Calculate the expected size based on the font and linebreak mode of your label
    maximumLabelSize = CGSizeMake(lblDate.frame.size.width,9999);
    expectedLabelSize = [lblDate.text sizeWithFont:lblDate.font constrainedToSize:maximumLabelSize lineBreakMode:lblDate.lineBreakMode];
    //adjust the label the the new height.
    newFrame = lblDate.frame;
    newFrame.origin.y = lblDateName.frame.origin.y;
    newFrame.size.height = expectedLabelSize.height;
    lblDate.frame = newFrame;
    
    [lblTimeName setFrame:CGRectMake(lblTimeName.frame.origin.x, lblDate.frame.origin.y+lblDate.frame.size.height+35, lblTimeName.frame.size.width, lblTimeName.frame.size.height)];
    
    lblTime.text = [dataElement objectForKey:@"time"]?[dataElement objectForKey:@"time"]:@" ";
    //Calculate the expected size based on the font and linebreak mode of your label
    maximumLabelSize = CGSizeMake(lblTime.frame.size.width,9999);
    expectedLabelSize = [lblTime.text sizeWithFont:lblDate.font constrainedToSize:maximumLabelSize lineBreakMode:lblTime.lineBreakMode];
    //adjust the label the the new height.
    newFrame = lblTime.frame;
    newFrame.origin.y = lblTimeName.frame.origin.y;
    newFrame.size.height = expectedLabelSize.height;
    lblTime.frame = newFrame;
    
    [lblTeamName setFrame:CGRectMake(lblTeamName.frame.origin.x, lblTime.frame.origin.y+lblTime.frame.size.height+35, lblTeamName.frame.size.width, lblTeamName.frame.size.height)];
    
    lblTeam.text = [dataElement objectForKey:@"team"];
    //Calculate the expected size based on the font and linebreak mode of your label
    maximumLabelSize = CGSizeMake(lblTeam.frame.size.width,9999);
    expectedLabelSize = [lblTeam.text sizeWithFont:lblTeam.font constrainedToSize:maximumLabelSize lineBreakMode:lblTeam.lineBreakMode];
    //adjust the label the the new height.
    newFrame = lblTeam.frame;
    newFrame.origin.y = lblTeamName.frame.origin.y;
    newFrame.size.height = expectedLabelSize.height;
    lblTeam.frame = newFrame;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
