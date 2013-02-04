//
//  HospitalViewController.m
//  m-Order
//
//  Created by HSU CHIH YUAN on 12/8/3.
//  Copyright (c) 2012年 HSU CHIH YUAN. All rights reserved.
//

#import "HospitalUnitViewController.h"

@interface HospitalUnitViewController ()

@end

@implementation HospitalUnitViewController

@synthesize dataset;
@synthesize tableView;
@synthesize tabBar;
@synthesize locmanager;
@synthesize activitydataset;
@synthesize strName;

#pragma Host Checked
- (NSString *) getIPAddressForHost: (NSString *) theHost
{
	struct hostent *host = gethostbyname([theHost UTF8String]);
	
    if (host == NULL) {
        herror("resolv");
		return NULL;
	}
	
	struct in_addr **list = (struct in_addr **)host->h_addr_list;
	NSString *addressString = [NSString stringWithUTF8String:inet_ntoa(*list[0])];
	return addressString;
}

// Direct from Apple. Thank you Apple
- (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address
{
	if (!IPAddress || ![IPAddress length]) {
		return NO;
	}
	
	memset((char *) address, sizeof(struct sockaddr_in), 0);
	address->sin_family = AF_INET;
	address->sin_len = sizeof(struct sockaddr_in);
	
	int conversionResult = inet_aton([IPAddress UTF8String], &address->sin_addr);
	if (conversionResult == 0) {
		NSAssert1(conversionResult != 1, @"Failed to convert the IP address string into a sockaddr_in: %@", IPAddress);
		return NO;
	}
	
	return YES;
}

- (BOOL) hostAvailable: (NSString *) theHost
{
    
	NSString *addressString = [self getIPAddressForHost:theHost];
	if (!addressString)
	{
		printf("Error recovering IP address from host name\n");
		return NO;
	}
	
	struct sockaddr_in address;
	BOOL gotAddress = [self addressFromString:addressString address:&address];
	
	if (!gotAddress)
	{
		printf("Error recovering sockaddr address from %s\n", [addressString UTF8String]);
		return NO;
	}
	
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&address);
	SCNetworkReachabilityFlags flags;
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	
	if (!didRetrieveFlags)
	{
		printf("Error. Could not recover network reachability flags\n");
		return NO;
	}
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	return isReachable ? YES : NO;;
}

#pragma 非同步載入壓縮圖片檔案，並進行解壓縮 Function
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

#pragma HTTP Function
- (void)pushDataToWS:(NSString*)qrcode {
    
    if ([self hostAvailable:weburi]){
        if (httpSemaphore) {
            httpSemaphore = NO;
            //資料載入
            requestObj = nil;
            NSString *percentEscapedString = [[NSString stringWithFormat:@"http://%@/%@/NavigationService.asmx?op=CollectedQRCode", weburi, webservicename] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"percentEscapedString=%@",percentEscapedString);
            
            requestObj = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:percentEscapedString]];
            
            // add http content type - to your request
            [requestObj addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
            // add  SOAPAction - webMethod that is going to be called
            [requestObj addRequestHeader:@"SOAPAction" value:@"http://tempuri.org/CollectedQRCode"];
            NSString *soapMessage=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                   "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                   "<soap:Body>\n"
                                   "<CollectedQRCode xmlns=\"http://tempuri.org/\">\n"
                                   "<did>%@</did>\n"
                                   "<qrcode>%@</qrcode>\n"
                                   "</CollectedQRCode>\n"
                                   "</soap:Body>\n"
                                   "</soap:Envelope>", [self uuid], qrcode];
            // count your soap message lenght - which is required to be added in your request
            NSString *msgLength=[NSString stringWithFormat:@"%i",[soapMessage length]];
            // add content length
            [requestObj addRequestHeader:@"Content-Length" value:msgLength];
            // set http request - body
            NSMutableData *soapdata = [[[NSMutableData alloc] initWithData:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
            [requestObj setPostBody:soapdata];
            
            [requestObj setRequestMethod:@"POST"];
            [requestObj setTimeOutSeconds:httptimeout];
            [requestObj setDelegate:self];
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"wifi"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"gprs"]) {
                //do smth
                httpHUD = [[MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES] retain];
                httpHUD.delegate = self;
                httpHUD.labelText = @"";
                httpHUD.detailsLabelText = @"更新資料...";
                httpHUD.square = YES;
                httpHUD.mode = MBProgressHUDModeIndeterminate;
                httpHUD.dimBackground = YES;
                // http service
                [requestObj startAsynchronous];
            }
            else
            {
                [YRDropdownView showDropdownInView:self.view
                                             title:@"警示訊息"
                                            detail:@"設備網路服務異常。"
                                             image:nil
                                          animated:NO
                                         hideAfter:1.5];
            }
        }
    }
    else{
        [YRDropdownView showDropdownInView:self.view
                                     title:@"警示訊息"
                                    detail:@"Host服務回應異常。"
                                     image:nil
                                  animated:NO
                                 hideAfter:1.5];
    }
}

#pragma mark - 解析JSON
- (void)parseJson:(NSString *)data{
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *json = [parser objectWithString:data];
    NSDictionary *_items = [json objectForKey:@"items"];
    NSMutableArray *tempAry = [[NSMutableArray alloc] init];
    for (NSMutableDictionary *obj in _items) {
        [tempAry addObject:obj];
    }
    
    if ([tempAry count]>0) {
        NSString *temp = [[tempAry objectAtIndex:0] objectForKey:@"result"];
        if ([temp isEqualToString:@"1"]) {
            NSLog(@"YES...");
            [YRDropdownView showDropdownInView:self.navigationController.view
                                         title:@"活動訊息"
                                        detail:@"QRCode搜集成功，點數加1點。"
                                         image:nil
                                      animated:NO
                                     hideAfter:1.5];
        }
        else{
            NSLog(@"NO...");
        }
    }
    [parser release];
    [tempAry release];
    // 取消警告視窗
    httpSemaphore = YES;
}

// 以下三個method為我們最常使用的NSXMLParserDelegate method
// 遇到XML tag開頭時被呼叫，可取得tag的名稱以及tag裡的attribute
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"elementName %@", elementName);
    if ([elementName isEqualToString:@"CollectedQRCodeResult"]) {
        jsonContent = [[NSMutableString alloc] init];
        returnFlag = YES;
    }
}

// 找到XML tag所包含的內容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"foundCharacters %@", string);
    if (returnFlag) {
        [jsonContent appendString:string];
    }
}

// 遇到XML tag結尾時被呼叫
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //NSLog(@"elementName %@", elementName);
    if ([elementName isEqualToString:@"CollectedQRCodeResult"]) {
        returnFlag = NO;
        //NSLog(@"jsonContent %@", jsonContent);
        
        if ([jsonContent isEqualToString:@"{\"items\":[]}"]||[jsonContent isEqualToString:@"{}"]) {
            httpSemaphore = YES;
            [YRDropdownView showDropdownInView:self.view
                                         title:@"警示訊息"
                                        detail:@"Network服務異常。"
                                         image:nil
                                      animated:NO
                                     hideAfter:1.5];
        }
        else {
            [self parseJson:jsonContent];
        }
    }
}

-(void)parseJsonString:(NSString*)xmldoc{
    //NSLog(@"xmldoc=%@", xmldoc);
    
    if (!(xmldoc.length>0)) {
        httpSemaphore = YES;
        return;
    }
    //先檢查soap service是否葛屁
    NSRange isbug = [xmldoc rangeOfString:@"soapenv:Reason"];
    if (isbug.length!=0) {
        httpSemaphore = YES;
    }
    else {
        NSData *data = [xmldoc dataUsingEncoding:NSUTF8StringEncoding];
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
        //設定delegate，如此才能於NSXMLParserDelegate的method被呼叫時做處理
        [xmlParser setDelegate:self];
        
        //呼叫NSXMLParser物件的parse method開始進行parse
        //parse method is a block call，做完才return
        [xmlParser parse];
        [xmlParser release];
        
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    //Example to download google's source and print out the urls of all the images
    //NSLog(@"Content will be %@ bytes in size",[request responseString]);
    [httpHUD hide:YES afterDelay:0.5];
    
    if ([request responseString]) {
        [self parseJsonString:[request responseString]];
    }
}

- (void)requestStarted:(ASIHTTPRequest *)request{
    NSLog(@"requestStarted...");
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    [httpHUD hide:YES afterDelay:0.5];
    //取消警告視窗
    httpSemaphore = YES;
    [YRDropdownView showDropdownInView:self.view
                                 title:@"警示訊息"
                                detail:@"Network服務異常。"
                                 image:nil
                              animated:NO
                             hideAfter:1.5];
}

- (void)dealloc
{
    
    if (isInit) {
        if (mapView) {
            mapView.delegate = nil;
            [mapView release];
        }
        [locmanager stopUpdatingLocation];
        locmanager.delegate = nil;
        [locmanager release];
        [tableView release];
        [tabBar release];
        [dataset release];
        
    }
	
    [super dealloc];
}

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    // run the reader when the view is visible
    if (functionIndex==2) {
        [myEmbedReaderViewController startReaderView];
    }
    NSLog(@"viewWillAppear");
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
    httpSemaphore = YES;
    [super viewDidLoad];
}

#pragma 設定元件
- (void)setViewDidLoad
{
    [self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
        
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    self.strName = [savedStock objectForKey:@"name"];
    [savedStock release];
    NSLog(@"strName=%@",self.strName);
    if (![self.strName isEqualToString:@""]) {
        // 註冊繼續往下
        [self initWorking];
    }
    else{
        // 開啓註冊清單
        myAuthenticationViewController = [[AuthenticationViewController alloc] init];
        [myAuthenticationViewController.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
        myAuthenticationViewController.delegate = self;
        [myAuthenticationViewController setHeaderView];
        [self.view addSubview:myAuthenticationViewController.view];
    }
}

#pragma 移除註冊視窗
-(void)removeSelfViewer{
    NSLog(@"移除註冊視窗");
    [myAuthenticationViewController.view removeFromSuperview];
    // 註冊繼續往下
    [self initWorking];
}

- (void)showSelfViewer:(NSMutableDictionary*)obj{
    ShowTeamDetailViewController *myShowTeamDetailViewController = [[ShowTeamDetailViewController alloc] init];
    [myShowTeamDetailViewController.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    myShowTeamDetailViewController.dataElement = obj;
    [myShowTeamDetailViewController reloadObjectData:@""];
    [self.navigationController pushViewController:myShowTeamDetailViewController animated:YES];
    [myShowTeamDetailViewController release];
}

#pragma 啟始作業
-(void)initWorking{
    
	// Do any additional setup after loading the view.
    semaphoreMap = YES;
    isInit = NO;
    if (!isInit) {
        myShowTeamViewController = [[ShowTeamViewController alloc] init];
        [myShowTeamViewController.view setFrame:CGRectMake(0, navigationbarheight, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-navigationbarheight)];
        myShowTeamViewController.delegate = self;
        // add myEmbedReaderViewController
        myEmbedReaderViewController = [[EmbedReaderViewController alloc] init];
        [myEmbedReaderViewController.view setFrame:CGRectMake(0, navigationbarheight, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-navigationbarheight)];
        myEmbedReaderViewController.delegate = self;
        [myEmbedReaderViewController setViewDidLoad];
        //加入tableView
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navigationbarheight, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-navigationbarheight*2) style:UITableViewStylePlain];
        [tableView setAutoresizesSubviews:YES];
        [tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [tableView setDataSource:self];
        [tableView setDelegate:self];
        [tableView setBackgroundColor:[UIColor clearColor]];
        //取消分隔線
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //設定欄位高度
        self.tableView.rowHeight = 100;
        [self.view addSubview:tableView];
        [self.view bringSubviewToFront:tableView];
        
        // Tab bar
        float gap = ([[UIScreen mainScreen] bounds].size.width-navigationbarheight*4)/8.0f;
        tabBar = [[UIView alloc] init];
        [tabBar setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-navigationbarheight, [[UIScreen mainScreen] bounds].size.width, navigationbarheight)];
        [tabBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"footer"]]];
        
        //List
        btnList = [[UIButton alloc] initWithFrame:CGRectMake(gap, 0, navigationbarheight, navigationbarheight)];
        [btnList setBackgroundImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
        [btnList setTitle:@"List" forState:UIControlStateHighlighted];
        btnList.tintColor = [UIColor blueColor];
        [btnList.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
        [btnList setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [btnList addTarget:self action:@selector(function_clicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnList setShowsTouchWhenHighlighted:YES];
        [btnList setTag:0];
        // Round corners using CALayer property
        [[btnList layer] setCornerRadius:10];
        [btnList setClipsToBounds:YES];
        
        // Create colored border using CALayer property
        [[btnList layer] setBorderColor:
         [[UIColor colorWithRed:0.52 green:0.59 blue:0.57 alpha:0.5] CGColor]];
        [[btnList layer] setBorderWidth:0];
        [tabBar addSubview:btnList];
        
        //Map
        btnMap = [[UIButton alloc] initWithFrame:CGRectMake(gap*5+navigationbarheight*2, 0, navigationbarheight, navigationbarheight)];
        [btnMap setBackgroundImage:[UIImage imageNamed:@"map.png"] forState:UIControlStateNormal];
        [btnMap setTitle:@"Map" forState:UIControlStateHighlighted];
        btnMap.tintColor = [UIColor blackColor];
        [btnMap.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
        [btnMap setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [btnMap addTarget:self action:@selector(function_clicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnMap setShowsTouchWhenHighlighted:YES];
        [btnMap setTag:1];
        // Round corners using CALayer property
        [[btnMap layer] setCornerRadius:10];
        [btnMap setClipsToBounds:YES];
        
        // Create colored border using CALayer property
        [[btnMap layer] setBorderColor:
         [[UIColor colorWithRed:0.52 green:0.59 blue:0.57 alpha:0.5] CGColor]];
        [[btnMap layer] setBorderWidth:0];
        
        [tabBar addSubview:btnMap];
        
        //AR
        btnQRCode = [[UIButton alloc] initWithFrame:CGRectMake(gap*7+navigationbarheight*3, 0, navigationbarheight, navigationbarheight)];
        [btnQRCode setBackgroundImage:[UIImage imageNamed:@"QRcode"] forState:UIControlStateNormal];
        [btnQRCode setTitle:@"QRCode" forState:UIControlStateHighlighted];
        btnQRCode.tintColor = [UIColor blackColor];
        [btnQRCode.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
        [btnQRCode setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [btnQRCode addTarget:self action:@selector(function_clicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnQRCode setShowsTouchWhenHighlighted:YES];
        [btnQRCode setTag:2];
        // Round corners using CALayer property
        [[btnQRCode layer] setCornerRadius:10];
        [btnQRCode setClipsToBounds:YES];
        
        // Create colored border using CALayer property
        [[btnQRCode layer] setBorderColor:
         [[UIColor colorWithRed:0.52 green:0.59 blue:0.57 alpha:0.5] CGColor]];
        [[btnQRCode layer] setBorderWidth:0];
        [tabBar addSubview:btnQRCode];
        
        //Show
        btnQRCode = [[UIButton alloc] initWithFrame:CGRectMake(gap*3+navigationbarheight, 0, navigationbarheight, navigationbarheight)];
        [btnQRCode setBackgroundImage:[UIImage imageNamed:@"show"] forState:UIControlStateNormal];
        [btnQRCode setTitle:@"show" forState:UIControlStateHighlighted];
        btnQRCode.tintColor = [UIColor blackColor];
        [btnQRCode.titleLabel setFont:[UIFont boldSystemFontOfSize:15.f]];
        [btnQRCode setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [btnQRCode addTarget:self action:@selector(function_clicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnQRCode setShowsTouchWhenHighlighted:YES];
        [btnQRCode setTag:3];
        // Round corners using CALayer property
        [[btnQRCode layer] setCornerRadius:10];
        [btnQRCode setClipsToBounds:YES];
        
        // Create colored border using CALayer property
        [[btnQRCode layer] setBorderColor:
         [[UIColor colorWithRed:0.52 green:0.59 blue:0.57 alpha:0.5] CGColor]];
        [[btnQRCode layer] setBorderWidth:0];
        [tabBar addSubview:btnQRCode];
        
        [self.view addSubview:tabBar];
        [self.view bringSubviewToFront:tabBar];
        
        rateLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, navigationbarheight) rate:100.0f andFadeLength:10.0f];
        rateLabel.numberOfLines = 1;
        rateLabel.opaque = NO;
        rateLabel.enabled = YES;
        rateLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        rateLabel.textAlignment = UITextAlignmentLeft;
        rateLabel.textColor = [UIColor whiteColor];
        rateLabel.backgroundColor = [UIColor clearColor];
        rateLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.000];
        rateLabel.marqueeType = MLContinuous;
        rateLabel.text =@"";
        
        locmanager = [[CLLocationManager alloc] init];
        [locmanager setDelegate:self];
        //設定需要重新定位的距離差距(0.01km)
        locmanager.distanceFilter = 10;
        //設定定位時的精準度
        locmanager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, navigationbarheight, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-navigationbarheight*2)];
        [mapView setMapType:MKMapTypeStandard];//MKMapTypeStandard];
        //設置為可以顯示用戶位置
        //[mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:NO];
        mapView.delegate = self;
        
        // 解析活動日期資料
        activitydataset = [[NSMutableArray alloc] init];
        NSString *_filePath = [[NSBundle mainBundle] pathForResource:@"activity" ofType:@"json"];
        if (_filePath) {
            NSString *myjsondata = [NSString stringWithContentsOfFile:_filePath
                                                             encoding:NSUTF8StringEncoding
                                                                error:nil];
            if (myjsondata) {
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                NSDictionary *json = [parser objectWithString:myjsondata];
                NSDictionary *_items = [json objectForKey:@"items"];
                for (NSMutableDictionary *obj in _items) {
                    [activitydataset addObject:obj];
                }
                NSLog(@"activitydataset=%d",[activitydataset count]);
                [parser release];
            }
        }
        
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(onTick:)
                                       userInfo:nil
                                        repeats:NO];
        
        
        // 解析資料
        dataset = [[NSMutableArray alloc] init];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mappoi" ofType:@"json"];
        if (filePath) {
            NSString *myjsondata = [NSString stringWithContentsOfFile:filePath
                                                             encoding:NSUTF8StringEncoding
                                                                error:nil];
            if (myjsondata) {
                NSError *error;
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
                NSString *documentsDirectory = [paths objectAtIndex:0]; //2
                NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                if (![fileManager fileExistsAtPath: path]) //4
                {
                    NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
                    
                    [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
                }
                NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
                
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                //NSLog(@"myjsondata=%@",myjsondata);
                NSDictionary *json = [parser objectWithString:myjsondata];
                NSDictionary *_items = [json objectForKey:@"items"];
                for (NSMutableDictionary *obj in _items) {
                    NSString *strPOIContent = [savedStock objectForKey:[NSString stringWithFormat:@"poi%@",[obj objectForKey:@"serialno"]]];
                    [obj setObject : [strPOIContent isEqualToString:@""]?strPOIContent : @"0" forKey:@"qrcode"];
                    [dataset addObject:obj];
                }
                NSLog(@"dataset count=%d",[dataset count]);
                [parser release];
                [savedStock release];
                // 創建POI點
                [mapView removeAnnotations:mapView.annotations];
                //把POI資料點加入MAP內
                NSMutableArray * mapdataset = [[NSMutableArray alloc] init];
                for (int i=0; i<[dataset count]; i++) {
                    MyAnnotation *annotation = [[MyAnnotation alloc] init];
                    annotation.content = [dataset objectAtIndex:i];
                    annotation.title = [annotation.content objectForKey:@"title"];
                    CLLocationCoordinate2D coordinate;
                    coordinate.latitude = [[annotation.content objectForKey:@"latitude"] floatValue];
                    coordinate.longitude = [[annotation.content objectForKey:@"longitude"] floatValue];
                    annotation.myCoordinate = coordinate;
                    [mapdataset addObject:annotation];
                    [annotation release];
                }
                [mapView addAnnotations:mapdataset];
                // 動態中心點
                //[self dynamicCenter];
                if ([mapdataset count]>0)
                {
                    MKCoordinateRegion region = MKCoordinateRegionForMapRect([self getMapRectUsingAnnotations:mapdataset]);
                    [mapView setRegion:region];
                }
                [mapdataset release];
            }
        }
        
        if (![CLLocationManager locationServicesEnabled])
        {
            [YRDropdownView showDropdownInView:self.view
                                         title:@"警示訊息"
                                        detail:@"設備端並沒有啓動GPS服務"
                                         image:nil
                                      animated:NO
                                     hideAfter:2.0];
            return;
        }
        else{
            
            //do smth
            HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
            HUD.delegate = self;
            HUD.labelText = @"";
            HUD.detailsLabelText = @"更新資料...";
            HUD.square = YES;
            HUD.mode = MBProgressHUDModeIndeterminate;
            HUD.dimBackground = YES;
            // http service
            isLocating = YES;
            [locmanager startUpdatingLocation];
            
        }
        
        //客制化標頭文字
        CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 55);
        myheader = [[UIView alloc] init];
        [myheader setBackgroundColor:[UIColor clearColor]];
        [myheader setFrame:frame];
        UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black_bar"]];
        [imageview setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 55)];
        [myheader addSubview:imageview];
        [imageview release];
        [myheader addSubview:rateLabel];
        [self.view addSubview:myheader];
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
        rateLabel.text = prodName;
        
        isInit = YES;
    }
}

-(void)onTick:(NSTimer *)timer {
    //do smth
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    NSLog(@"strDate=%@ %@",strDate,[[activitydataset objectAtIndex:0] objectForKey:strDate]);
    if ([[activitydataset objectAtIndex:0] objectForKey:strDate]) {
        rateLabel.text = [NSString stringWithFormat:@"最近活動：%@",[[activitydataset objectAtIndex:0] objectForKey:strDate]?[[activitydataset objectAtIndex:0] objectForKey:strDate]:@""];
    }
    else{
        rateLabel.text = @"本日無相關活動";
    }
}

#pragma 動態範圍
/* This returns a rectangle bounding all of the pins within the supplied
 array */
- (MKMapRect) getMapRectUsingAnnotations : (NSMutableArray *)data {
    MKMapPoint points[[data count]];
    
    for (int i = 0; i < [data count]; i++) {
        MyAnnotation *annotation = [data objectAtIndex:i];
        points[i] = MKMapPointForCoordinate(annotation.coordinate);
    }
    MKPolygon *poly = [MKPolygon polygonWithPoints:points count:[data count]];
    
    return [poly boundingMapRect];
}

#pragma 計算距離
- (CLLocationDistance)distanceBetweenCoordinate:(CLLocationCoordinate2D)originCoordinate andCoordinate:(CLLocationCoordinate2D)destinationCoordinate {
    
    CLLocation *originLocation = [[CLLocation alloc] initWithLatitude:originCoordinate.latitude longitude:originCoordinate.longitude];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:destinationCoordinate.latitude longitude:destinationCoordinate.longitude];
    CLLocationDistance distance = [originLocation distanceFromLocation:destinationLocation];
    [originLocation release];
    [destinationLocation release];
    
    return distance;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (semaphoreMap) {
        semaphoreMap = NO;
        
        if (isLocating) {
            isLocating = NO;
            [HUD hide:YES afterDelay:1];
        }
        
        // Location has been found. Create GMap URL
        coor.latitude = newLocation.coordinate.latitude;
        coor.longitude = newLocation.coordinate.longitude;
        
        //更新距離
        for (int i=0; i<[dataset count]; i++) {
            NSMutableDictionary *obj = [dataset objectAtIndex:i];
            objloc.latitude = [[obj objectForKey:@"latitude"] floatValue];
            objloc.longitude = [[obj objectForKey:@"longitude"] floatValue];
            double dis = [self distanceBetweenCoordinate:coor andCoordinate:objloc];
            dis = dis/1000.0f;
            //NSLog(@"%f",dis);
            [obj setObject:[NSString stringWithFormat:@"%f",dis] forKey:@"distance"];
            [dataset replaceObjectAtIndex:i withObject:obj];
        }
        
        // 更新表單
        [tableView reloadData];
        
        semaphoreMap = YES;
    }
}

#pragma Map Events
//AnnotationView's UIControl 被點擊後的動作反應
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    
    NSMutableDictionary *obj = ((MyAnnotation*)view.annotation).content;
    //NSLog(@"%@", [obj objectForKey:@"title"]);
    //設定院所詳細資料
    myUnitDetailViewController = [[UnitDetailViewController alloc] init];
    [myUnitDetailViewController.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [myUnitDetailViewController.view setFrame:self.view.bounds];
    myUnitDetailViewController.dataElement = obj;
    [myUnitDetailViewController reloadObjectData:@""];
    [self.navigationController pushViewController:myUnitDetailViewController animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if (annotation == mapView.userLocation) return nil;
    
    static NSString *AnnotationViewID = @"annotationViewID";
    MKPinAnnotationView* pinView;
    pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
    pinView.pinColor = MKPinAnnotationColorPurple;
    //pinView.animatesDrop = YES;
    pinView.canShowCallout =YES;
    pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //Here's where the magic happens
    //pinView.image = [[annotation subtitle] isEqualToString:@"未搜集"]?[UIImage imageNamed:@"blackpoi"]:[UIImage imageNamed:@"lightpoi"];
    
    return pinView;
}

#pragma GPS Events
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorMessage = @"";
    
    if([error code]==kCLErrorDenied){
        errorMessage=@"你的訪問被拒絕，點選確定關閉GPS。";
    }
    
    if([error code]==kCLErrorLocationUnknown){
        errorMessage=@"無法定位到你的位置!點選確定關閉GPS。";
    }
    
    [YRDropdownView showDropdownInView:self.view
                                 title:@"警示訊息"
                                detail:errorMessage
                                 image:nil
                              animated:NO
                             hideAfter:2.0];
    
    [locmanager stopUpdatingHeading];
    [locmanager stopUpdatingLocation];
    
    if (isLocating) {
        isLocating = NO;
        [HUD hide:YES afterDelay:1];
    }
}

- (void)function_clicked:(id)sender{
    functionIndex = ((UIButton*)sender).tag;
    switch (((UIButton*)sender).tag) {
        case 0://List
            if (myEmbedReaderViewController) {
                [myEmbedReaderViewController.view removeFromSuperview];
            }
            if (myShowTeamViewController) {
                [myShowTeamViewController.view removeFromSuperview];
            }
            if (mapView) {
                [mapView removeFromSuperview];
            }
            if (![tableView superview])
            {
                [self.view addSubview:tableView];
                [self.view bringSubviewToFront:tableView];
            }
            [self.view bringSubviewToFront:tabBar];
            [self.view bringSubviewToFront:myheader];
            
            break;
        case 1://Map
            //QRCode
            if (myEmbedReaderViewController) {
                [myEmbedReaderViewController.view removeFromSuperview];
            }
            if (tableView) {
                [tableView removeFromSuperview];
            }
            if (myShowTeamViewController) {
                [myShowTeamViewController.view removeFromSuperview];
            }
            //地圖
            if (![mapView superview]) {
                [self.view addSubview:mapView];
                [self.view bringSubviewToFront:mapView];
            }
            [self.view bringSubviewToFront:tabBar];
            [self.view bringSubviewToFront:myheader];
            break;
        case 2://QRCode
            if (tableView) {
                [tableView removeFromSuperview];
            }
            if (myShowTeamViewController) {
                [myShowTeamViewController.view removeFromSuperview];
            }
            //地圖
            if (mapView) {
                [mapView removeFromSuperview];
            }
            //QRCode
            if (![myEmbedReaderViewController.view superview]) {
                [self.view addSubview:myEmbedReaderViewController.view];
                [self.view bringSubviewToFront:myEmbedReaderViewController.view];
            }
            
            [self.view bringSubviewToFront:tabBar];
            [self.view bringSubviewToFront:myheader];
            break;
        case 3://Show
            //QRCode
            if (myEmbedReaderViewController) {
                [myEmbedReaderViewController.view removeFromSuperview];
            }
            if (tableView) {
                [tableView removeFromSuperview];
            }
            //地圖
            if (mapView) {
                [mapView removeFromSuperview];
            }
            if (![myShowTeamViewController.view superview]) {
                [self.view addSubview:myShowTeamViewController.view];
                [self.view bringSubviewToFront:myShowTeamViewController.view];
            }
            [self.view bringSubviewToFront:tabBar];
            [self.view bringSubviewToFront:myheader];
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	if([title isEqualToString:@"確定兌換"])
	{
        // 開啟data.plist
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
        NSString *documentsDirectory = [paths objectAtIndex:0]; //2
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath: path]) //4
        {
            NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
            
            [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
        }
        NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        int collectNum = 0;
        for (int i=0; i<[dataset count]; i++) {
            NSString *strindex = [[dataset objectAtIndex:i] objectForKey:@"serialno"];
            NSString *qrcodecontent = [savedStock objectForKey:[NSString stringWithFormat:@"poi%@",strindex]];
            if ([qrcodecontent isEqualToString:@"cultural.pthg"]) {
                if (collectNum<alertView.tag) {
                    [savedStock setObject:@"exchange" forKey:[NSString stringWithFormat:@"poi%@",strindex]];
                    
                    // 更新Annotation
                    NSMutableDictionary *obj = [dataset objectAtIndex:i];
                    [obj setObject:@"exchange" forKey:@"qrcode"];
                    [dataset replaceObjectAtIndex:i withObject:obj];
                    
                    collectNum++;
                }
                else{
                    break;
                }
                
            }
        }
        // 複寫資料
        [savedStock writeToFile:path atomically: YES];
        [savedStock release];
                
        // 更新tableview
        [tableView reloadData];
        // 更新mapview
        [self reloadMap];
        
        // 視窗移到List
        if (myEmbedReaderViewController) {
            [myEmbedReaderViewController.view removeFromSuperview];
        }
        if (myShowTeamViewController) {
            [myShowTeamViewController.view removeFromSuperview];
        }
        if (mapView) {
            [mapView removeFromSuperview];
        }
        if (![tableView superview])
        {
            [self.view addSubview:tableView];
            [self.view bringSubviewToFront:tableView];
        }
        [self.view bringSubviewToFront:tabBar];
        [self.view bringSubviewToFront:myheader];
	}
	else if([title isEqualToString:@"取消"] || [title isEqualToString:@"OK"])
	{
		NSLog(@"取消兌換.");
        // 重新載入QRCode
        [myEmbedReaderViewController startReaderView];
	}
    
}

#pragma POI QRCode檢測
- (void)openPOIViewer:(NSString*)pageIndex Exchange:(BOOL)bExchange{
    if (bExchange) {
        // 兌換獎品
        NSArray *firstSplit = [pageIndex componentsSeparatedByString:@","];
        if ([firstSplit count]==2) {
            // 取出需要兌換點數
            int number = [[firstSplit objectAtIndex:1] integerValue];
            // 開啟data.plist
            NSError *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
            NSString *documentsDirectory = [paths objectAtIndex:0]; //2
            NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath: path]) //4
            {
                NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
                
                [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
            }
            NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
            int collectNum = 0;
            for (int i=0; i<[dataset count]; i++) {
                NSString *strindex = [[dataset objectAtIndex:i] objectForKey:@"serialno"];
                NSString *qrcodecontent = [savedStock objectForKey:[NSString stringWithFormat:@"poi%@",strindex]];
                if ([qrcodecontent isEqualToString:@"cultural.pthg"]) {
                    collectNum++;
                }
            }
            [savedStock release];
            
            if (collectNum>=number) {
                // 顯示UIAlertView
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"活動訊息"
                                                                  message:@"您目前累積點數可以兌換該獎品。"
                                                                 delegate:self
                                                        cancelButtonTitle:@"確定兌換"
                                                        otherButtonTitles:@"取消", nil];
                message.tag = number;
                [message show];
                [message release];
            }
            else{
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"活動訊息"
                                                                  message:[NSString stringWithFormat:@"您目前累積點數不夠，尚缺%d點。",(number-collectNum)]
                                                                 delegate:self
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
                [message release];
            }
        }
    }
    else{
        // 收集QRcode
        
        // 送出資料
        [self pushDataToWS:pageIndex];
        
        //儲存qrcode
        NSArray *firstSplit = [pageIndex componentsSeparatedByString:@","];
        if ([firstSplit count]==2) {
            NSError *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
            NSString *documentsDirectory = [paths objectAtIndex:0]; //2
            NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath: path]) //4
            {
                NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
                
                [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
            }
            NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
            [savedStock setObject:[firstSplit objectAtIndex:1] forKey:[NSString stringWithFormat:@"poi%@",[firstSplit objectAtIndex:0]]];
            [savedStock writeToFile:path atomically: YES];
            [savedStock release];
            // 更新Annotation
            int obj_index=[[firstSplit objectAtIndex:0] integerValue]-1;
            NSMutableDictionary *obj = [dataset objectAtIndex:obj_index];
            [obj setObject:[firstSplit objectAtIndex:1] forKey:@"qrcode"];
            [dataset replaceObjectAtIndex:obj_index withObject:obj];
            
            // 更新tableview
            [tableView reloadData];
            // 更新mapview
            [self reloadMap];
            // 開啟poi
            myUnitDetailViewController = [[UnitDetailViewController alloc] init];
            [myUnitDetailViewController.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
            myUnitDetailViewController.dataElement = obj;
            [myUnitDetailViewController reloadObjectData:pageIndex];
            NSLog(@"XDXD");
            [self.navigationController pushViewController:myUnitDetailViewController animated:YES];
            
        }
    }
    
}

//create function
-(void) reloadMap
{
    // 創建POI點
    [mapView removeAnnotations:mapView.annotations];
    //把POI資料點加入MAP內
    NSMutableArray * mapdataset = [[NSMutableArray alloc] init];
    for (int i=0; i<[dataset count]; i++) {
        MyAnnotation *annotation = [[MyAnnotation alloc] init];
        annotation.content = [dataset objectAtIndex:i];
        annotation.title = [annotation.content objectForKey:@"title"];
        // 由plist取得qrcode搜集
        annotation.subtitle = [annotation.content objectForKey:@"addr"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [[annotation.content objectForKey:@"latitude"] floatValue];
        coordinate.longitude = [[annotation.content objectForKey:@"longitude"] floatValue];
        annotation.myCoordinate = coordinate;
        [mapdataset addObject:annotation];
        [annotation release];
    }
    [mapView addAnnotations:mapdataset];
    [mapdataset release];
}

#pragma mark Table view creation (UITableViewDataSource)
/*
// This recipe adds a title for each section
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [Area_ARRAY objectAtIndex:section];
}*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// customize the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataset count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //取消背景
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //get Item
    NSInteger row = [indexPath row];
    NSMutableDictionary *obj = [dataset objectAtIndex:row];
    //設定院所詳細資料
    myUnitDetailViewController = [[UnitDetailViewController alloc] init];
    [myUnitDetailViewController.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    myUnitDetailViewController.dataElement = obj;
    [myUnitDetailViewController reloadObjectData:@""];
    [self.navigationController pushViewController:myUnitDetailViewController animated:YES];
}

//圖片縮小
-(UIImage*) imageByScalingToSize:(CGSize) targetSize sourceImage:(UIImage*)sourceImage
{
    UIGraphicsBeginImageContext(targetSize);
    [sourceImage drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}

- (UITableViewCell *)tableView:(UITableView *)tableViewObj cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UILabel *topLabel;
	//UILabel *bottomLabel;
    //UILabel *detailLabel;
    UILabel *distanceLabel;
    
	// customize the appearance of table view cells
	//
	static NSString *CellIdentifier = @"LazyTableCell";
	TDBadgedCell *cell;// = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell = [[[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //get Item
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    //HospitalClass *item = [[dataset objectAtIndex:section] objectAtIndex:row];
    
    UIImage *indicatorImage = [UIImage imageNamed:@"indicator.png"];
    cell.accessoryView =
    [[[UIImageView alloc]
      initWithImage:indicatorImage]
     autorelease];
    
    const CGFloat LABEL_HEIGHT = 20;
    const CGFloat image_HEIGHT = 64;
    
    //
    // Create the label for the top row of text
    //
    topLabel =
    [[[UILabel alloc]
      initWithFrame:
      CGRectMake(
                 image_HEIGHT + 2.0 * cell.indentationWidth,
                 0.5 * (tableViewObj.rowHeight - 4 * LABEL_HEIGHT),
                 tableViewObj.bounds.size.width -
                 image_HEIGHT - 4.0 * cell.indentationWidth
                 - indicatorImage.size.width-45,
                 LABEL_HEIGHT*3)]
     autorelease];
    [cell.contentView addSubview:topLabel];
    
    //
    // Configure the properties for the text that are the same on every row
    //
    topLabel.numberOfLines = 3;
    topLabel.backgroundColor = [UIColor clearColor];
    topLabel.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
    topLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
    topLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    
    //
    // Create the label for the top row of text
    /*
    bottomLabel =
    [[[UILabel alloc]
      initWithFrame:
      CGRectMake(
                 image_HEIGHT + 2.0 * cell.indentationWidth,
                 0.5 * (tableViewObj.rowHeight - 4 * LABEL_HEIGHT) + LABEL_HEIGHT,
                 tableViewObj.bounds.size.width -
                 image_HEIGHT - 4.0 * cell.indentationWidth
                 - indicatorImage.size.width,
                 LABEL_HEIGHT)]
     autorelease];
    [cell.contentView addSubview:bottomLabel];*/
    
    //
    // Configure the properties for the text that are the same on every row
    /*
    bottomLabel.backgroundColor = [UIColor clearColor];
    bottomLabel.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.55 alpha:1.0];
    bottomLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
    bottomLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 2];
    bottomLabel.numberOfLines = 1;
    [bottomLabel setTextAlignment:UITextAlignmentRight];
    //
    // Create the label for the top row of text
    //
    detailLabel =
    [[[UILabel alloc]
      initWithFrame:
      CGRectMake(
                 image_HEIGHT + 2.0 * cell.indentationWidth,
                 0.5 * (tableViewObj.rowHeight - 4 * LABEL_HEIGHT) + 2*LABEL_HEIGHT,
                 tableViewObj.bounds.size.width -
                 image_HEIGHT - 4.0 * cell.indentationWidth
                 - indicatorImage.size.width,
                 LABEL_HEIGHT)]
     autorelease];
    [cell.contentView addSubview:detailLabel];
    
    //
    // Configure the properties for the text that are the same on every row
    //
    detailLabel.backgroundColor = [UIColor clearColor];
    detailLabel.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0];
    detailLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
    detailLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 2];
    detailLabel.numberOfLines = 1;*/
    //
    // Create the label for the top row of text
    //
    distanceLabel =
    [[[UILabel alloc]
      initWithFrame:
      CGRectMake(
                 image_HEIGHT + 2.0 * cell.indentationWidth,
                 0.5 * (tableViewObj.rowHeight - 4 * LABEL_HEIGHT) + 3*LABEL_HEIGHT,
                 tableViewObj.bounds.size.width -
                 image_HEIGHT - 4.0 * cell.indentationWidth
                 - indicatorImage.size.width,
                 LABEL_HEIGHT)]
     autorelease];
    [cell.contentView addSubview:distanceLabel];
    
    //
    // Configure the properties for the text that are the same on every row
    //
    distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    distanceLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
    distanceLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 2];
    distanceLabel.numberOfLines = 1;
    [distanceLabel setTextAlignment:UITextAlignmentRight];
    //
    // Create a background image view.
    //
    cell.backgroundView =
    [[[UIImageView alloc] init] autorelease];
    cell.selectedBackgroundView =
    [[[UIImageView alloc] init] autorelease];
    
    topLabel.text = [[dataset objectAtIndex:row] objectForKey:@"title"];
	//bottomLabel.text = [NSString stringWithFormat:@"%@ : ", @"等待人數"];
    //detailLabel.text = [[dataset objectAtIndex:row] objectForKey:@"addr"];//[NSString stringWithFormat:@"%@", item.openinghours];
    //To display a text within UILabel use:
    float distance = [[[dataset objectAtIndex:row] objectForKey:@"distance"] floatValue];
    if (distance>=1 && distance<100) {
        distanceLabel.text = [NSString stringWithFormat:@"距離 : %.1fkm",distance];
    }
    else if (distance>=100) {
        distanceLabel.text = [NSString stringWithFormat:@"距離 : %.0fkm",distance];
    }
    else if (distance<1){
        distanceLabel.text = [NSString stringWithFormat:@"距離 : %.0fm",(distance*100)];
    }
	
	//
	// Set the background and selected background images for the text.
	// Since we will round the corners at the top and bottom of sections, we
	// need to conditionally choose the images based on the row index and the
	// number of rows in the section.
	//
	UIImage *rowBackground;
	UIImage *selectionBackground;
	NSInteger sectionRows = [tableView numberOfRowsInSection:section];
	row = [indexPath row];
	if (row == 0 && row == sectionRows - 1)
	{
		rowBackground = [UIImage imageNamed:@"topAndBottomRow.png"];
		selectionBackground = [UIImage imageNamed:@"topAndBottomRowSelected.png"];
	}
	else if (row == 0)
	{
		rowBackground = [UIImage imageNamed:@"topRow.png"];
		selectionBackground = [UIImage imageNamed:@"topRowSelected.png"];
	}
	else if (row == sectionRows - 1)
	{
		rowBackground = [UIImage imageNamed:@"bottomRow.png"];
		selectionBackground = [UIImage imageNamed:@"bottomRowSelected.png"];
	}
	else
	{
		rowBackground = [UIImage imageNamed:@"middleRow.png"];
		selectionBackground = [UIImage imageNamed:@"middleRowSelected.png"];
	}
	((UIImageView *)cell.backgroundView).image = rowBackground;
	((UIImageView *)cell.selectedBackgroundView).image = selectionBackground;
	
    //badgeString
    cell.badgeString = [[[dataset objectAtIndex:row] objectForKey:@"qrcode"] isEqualToString:@"cultural.pthg"]?@"已收集":@"未收集";
    if ([[[dataset objectAtIndex:row] objectForKey:@"qrcode"] isEqualToString:@"exchange"]) {
        cell.badgeString = @"已兌換";
    }
	//
	// Here I set an image based on the row. This is just to have something
	// colorful to show on each row.
	//
    UIImage *image = [[[dataset objectAtIndex:row] objectForKey:@"qrcode"] isEqualToString:@"cultural.pthg"]?[UIImage imageNamed:@"active"]:[UIImage imageNamed:@"unactive"];
    float scale = image.size.width/image_HEIGHT;
    image = [self imageByScalingToSize:CGSizeMake(image_HEIGHT, image.size.height/scale) sourceImage:image];
	cell.imageView.image = image;
    
    cell.badgeColor = [[[dataset objectAtIndex:row] objectForKey:@"qrcode"] isEqualToString:@"cultural.pthg"]?[UIColor colorWithRed:0.197 green:0.592 blue:0.219 alpha:1.000]:[UIColor colorWithRed:0.592 green:0.592 blue:0.592 alpha:1.000];
    
    if ([[[dataset objectAtIndex:row] objectForKey:@"qrcode"] isEqualToString:@"exchange"]) {
        cell.badgeColor = [UIColor colorWithRed:0.892 green:0.092 blue:0.092 alpha:1.000];
    }
    
    cell.badge.radius = 9;
    cell.showShadow = YES;
    
    return cell;
}

#pragma implement delegate function

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //系統默認不支持旋轉功能
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
