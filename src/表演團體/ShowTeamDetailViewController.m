//
//  HospitalDetailViewController.m
//  m-Order
//
//  Created by HSU CHIH YUAN on 12/8/8.
//  Copyright (c) 2012年 HSU CHIH YUAN. All rights reserved.
//

#import "ShowTeamDetailViewController.h"

@interface ShowTeamDetailViewController ()

@end

@implementation ShowTeamDetailViewController

@synthesize dataElement;

- (void)dealloc
{
    if (isInit) {
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
        //imageview
        unitimage = [[SWSnapshotStackView alloc] initWithFrame:CGRectMake(20, 5, [[UIScreen mainScreen] bounds].size.width-40, 250)];
        unitimage.displayAsStack = YES;
        
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, unitimage.frame.size.height+10, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-unitimage.frame.size.height-self.navigationController.navigationBar.frame.size.height-20)];
        [webView setScalesPageToFit:YES];
        webView.delegate = self;
        [webView setBackgroundColor:[UIColor whiteColor]];
        // Round corners using CALayer property
        [[webView layer] setCornerRadius:10];
        [webView setClipsToBounds:YES];
        
        // Create colored border using CALayer property
        [[webView layer] setBorderColor:
         [[UIColor colorWithRed:0.52 green:0.59 blue:0.57 alpha:0.5] CGColor]];
        [[webView layer] setBorderWidth:2.75];
        [mainView addSubview:unitimage];
        //內容背景
        [mainView addSubview:webView];
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
        label = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 260, 55)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.textAlignment = UITextAlignmentRight;
        [myheader addSubview:label];
        
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

- (void) webViewDidFinishLoad : (UIWebView *) aWebView
{
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    aWebView.frame = frame;
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    aWebView.frame = frame;
    
    NSLog(@"size: %f, %f", fittingSize.width, fittingSize.height);
    
    [mainView setContentSize:CGSizeMake(self.view.frame.size.width,  webView.frame.origin.y+webView.frame.size.height)];
}

#pragma 重新載入資料
- (void)reloadObjectData:(NSString*)qrcode{
    
    if (![[dataElement objectForKey:@"image"] isEqualToString:@""]) {
        unitimage.image = [UIImage imageNamed:[dataElement objectForKey:@"image"]];
    }
    else{
        [unitimage removeFromSuperview];
        [webView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-self.navigationController.navigationBar.frame.size.height-20)];
    }
    
    // HTML-based Presentation-only
    NSString *content=[NSString stringWithFormat:@"<html><body><table><tr><td><font size='40' color='666633'><b>%@</b></font></td></tr><tr><td><font size='30' color='006633'>%@</font></td></tr></table></body></html>", [dataElement objectForKey:@"title"], [dataElement objectForKey:@"description"]];
    [webView loadHTMLString:content baseURL:nil];
    
    label.text = [dataElement objectForKey:@"title"];
    
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
