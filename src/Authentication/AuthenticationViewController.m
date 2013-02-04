//
//  FVEViewController.m
//  FlipNumberViewExample
//
//  Created by Markus Emrich on 07.08.12.
//  Copyright (c) 2012 markusemrich. All rights reserved.
//

#import "AuthenticationViewController.h"

@interface AuthenticationViewController ()

@end

@implementation AuthenticationViewController

@synthesize didTextView;
@synthesize nameTextView;
//@synthesize telTextView;
//@synthesize addrTextView;
//@synthesize emailTextView;
@synthesize delegate;

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

- (void)viewDidLoad
{
    self.navigationController.navigationBarHidden = YES;
    
    httpSemaphore = YES;
    [super viewDidLoad];
    
    //加入tableView
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStyleGrouped];
    [tableView setAutoresizesSubviews:YES];
    [tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
    //取消分隔線
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:tableView];
    [self.view bringSubviewToFront:tableView];
    
    //Time
    UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(10, 125, [[UIScreen mainScreen] bounds].size.width-20, 30)];
    [lblTime setText:@""];
    [lblTime setNumberOfLines:20];
    [lblTime setLineBreakMode:lblTime.lineBreakMode];
    [lblTime setFont:[UIFont fontWithName:@"Arial-BoldMT" size:15]];
    [lblTime setTextColor:[UIColor blackColor]];
    [lblTime setBackgroundColor:[UIColor clearColor]];
    [tableView addSubview:lblTime];
    
    lblTime.text = @"於2012恆春國際民謠節期間，請自行前往以下設有QR-CODE民謠踩點機制之景點及活動場次，詳細活動場次請至網站參閱：http://www.cultural.pthg.gov.tw/folkmusic2012/default1.asp。\n共計有17枚踩點QR-CODE，集滿5點即可獲得ㄚ財海灘拖鞋乙雙(數量有限，贈完為止)；集滿8點即可獲得光地方之華尋地方之寶手繪明信片乙套(數量有限，贈完為止)。\n以智慧型手機掃描QR-CODE條碼，輸入手機號碼後即算集點完成，民眾可至網站查詢累積點數。\n兌換地點：恆春民謠館(屏東縣恆春鎮恆南路168號)屏東縣政府文化處(屏東市大連路69號)\n兌換方式：方式１：民眾可自行上網列印集點成果書面證明，至兌換地點兌獎。方式２：民眾至兌換地點直接秀出手機集點畫面，即可兌獎。";
    //Calculate the expected size based on the font and linebreak mode of your label
    CGSize maximumLabelSize = CGSizeMake(lblTime.frame.size.width,9999);
    CGSize expectedLabelSize = [lblTime.text sizeWithFont:lblTime.font constrainedToSize:maximumLabelSize lineBreakMode:lblTime.lineBreakMode];
    //adjust the label the the new height.
    CGRect newFrame = lblTime.frame;
    newFrame.size.height = expectedLabelSize.height;
    lblTime.frame = newFrame;
    [lblTime release];
}

-(void) setHeaderView{
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
    self.navigationItem.titleView = myheader;
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
    label.text = prodName;
    [label release];
    [myheader release];
}

-(void)setViewDidLoad{
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
- (void)pushProfileToWS:(NSString*)did name:(NSString*)name tel:(NSString*)tel addr:(NSString*)addr email:(NSString*)email {
    
    if ([self hostAvailable:weburi]){
        if (httpSemaphore) {
            httpSemaphore = NO;
            //資料載入
            requestObj = nil;
            NSString *percentEscapedString = [[NSString stringWithFormat:@"http://%@/%@/NavigationService.asmx?op=SaveProfile", weburi, webservicename] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"percentEscapedString=%@",percentEscapedString);
            
            requestObj = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:percentEscapedString]];
            
            // add http content type - to your request
            [requestObj addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
            // add  SOAPAction - webMethod that is going to be called
            [requestObj addRequestHeader:@"SOAPAction" value:@"http://tempuri.org/SaveProfile"];
            NSString *soapMessage=[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                                   "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                                   "<soap:Body>\n"
                                   "<SaveProfile xmlns=\"http://tempuri.org/\">\n"
                                   "<did>%@</did>"
                                   "<name>%@</name>"
                                   "<tel>%@</tel>"
                                   "<addr>%@</addr>"
                                   "<email>%@</email>"
                                   "</SaveProfile>\n"
                                   "</soap:Body>\n"
                                   "</soap:Envelope>", did, name, tel, addr,email];
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
                httpHUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
                httpHUD.delegate = self;
                httpHUD.labelText = @"";
                httpHUD.detailsLabelText = @"註冊資料...";
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
    [YRDropdownView showDropdownInView:self.view
                                 title:@"HTTP訊息"
                                detail:data
                                 image:nil
                              animated:NO
                             hideAfter:1.5];
    
    // 取消警告視窗
    httpSemaphore = YES;
    
    NSLog(@"data authentication %@",data);
    
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
            //儲存id, pwd
            [savedStock setObject:didTextView.text forKey:@"did"];
            [savedStock setObject:nameTextView.text forKey:@"name"];
            [savedStock setObject:@"" forKey:@"tel"];
            [savedStock setObject:@"" forKey:@"addr"];
            [savedStock setObject:@"" forKey:@"email"];
            [savedStock writeToFile:path atomically: YES];
            [savedStock release];
            NSLog(@"註冊成功...");
            // 返回上一頁
            [self.delegate removeSelfViewer];
        }
        else{
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"活動訊息"
                                                              message:@"帳號註冊失敗，請洽活動單位。"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            [message release];
        }
    }
    [parser release];
    [tempAry release];
}

// 以下三個method為我們最常使用的NSXMLParserDelegate method
// 遇到XML tag開頭時被呼叫，可取得tag的名稱以及tag裡的attribute
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"elementName %@", elementName);
    if ([elementName isEqualToString:@"SaveProfileResult"]) {
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
    if ([elementName isEqualToString:@"SaveProfileResult"]) {
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
    //NSLog(@"Content %@",[request responseString]);
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
    // 返回上一頁
    [self.delegate removeSelfViewer];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 10;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 30)] autorelease];
    view.backgroundColor = [UIColor clearColor];
    UILabel* label = [[UILabel alloc] initWithFrame: CGRectMake(10, 0, 300, 30)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0,-1);
    label.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
    label.font = [UIFont boldSystemFontOfSize: 16];
    [view addSubview: label];
    
    if (section==0) {
        label.text = @"";
    } else {
        label.text = @"";
    }
    
    [label release];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section==0) ? 2 : 1;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString* identifier = @"identifier";
    UITableViewCell* cell = cell = [[[UITableViewCell alloc] init] autorelease];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.font = [UIFont boldSystemFontOfSize: 15];
    cell.detailTextLabel.font = [UIFont systemFontOfSize: 13];
    
    // 帳號登入
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            
            didTextView = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 290, 40.0f)];  //初始化大小
            // 唯獨
            didTextView.userInteractionEnabled = NO;
            didTextView.textColor = [UIColor blackColor]; //設置textview裡面的字體顏色
            didTextView.font = [UIFont fontWithName:@"Arial-BoldMT" size:18]; //設置字體名字和字體大小
            didTextView.delegate = self; //設置它的委託方法
            didTextView.backgroundColor = [UIColor clearColor]; //設置它的背景顏色
            didTextView.text = [self uuid] ; //設置它顯示的內容
            didTextView.returnKeyType = UIReturnKeyDefault; //返回鍵的類型
            didTextView.keyboardType = UIKeyboardTypeDefault; //鍵盤類型
            didTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight; //自適應高度
            // When the user starts typing, show the clear button in the text field.
            didTextView.clearButtonMode = UITextFieldViewModeWhileEditing;
            // When the view first loads, display the placeholder text that's in the
            // text field in the label.
            didTextView.placeholder = @"請輸入設備號碼";
            didTextView.textAlignment = UITextAlignmentCenter;
            didTextView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            didTextView.borderStyle = UITextBorderStyleNone;
            didTextView.layer.cornerRadius = 8.0f;
            didTextView.layer.masksToBounds = YES;
            didTextView.layer.borderWidth = 0;
            didTextView.layer.borderColor = [UIColor grayColor].CGColor;
            [cell.contentView addSubview:didTextView]; //加入到整個頁面中
        }
        else if(indexPath.row == 1) {
            nameTextView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 300, 40.0f)];  //初始化大小
            nameTextView.textColor = [UIColor blackColor]; //設置textview裡面的字體顏色
            nameTextView.font = [UIFont fontWithName:@ "Arial"  size:18.0]; //設置字體名字和字體大小
            nameTextView.delegate = self; //設置它的委託方法
            nameTextView.backgroundColor = [UIColor clearColor]; //設置它的背景顏色
            nameTextView.text = @"" ; //設置它顯示的內容
            nameTextView.returnKeyType = UIReturnKeyDefault; //返回鍵的類型
            nameTextView.keyboardType = UIKeyboardTypeDefault; //鍵盤類型
            nameTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight; //自適應高度
            // When the user starts typing, show the clear button in the text field.
            nameTextView.clearButtonMode = UITextFieldViewModeWhileEditing;
            // When the view first loads, display the placeholder text that's in the
            // text field in the label.
            nameTextView.placeholder = @"請輸入姓名";
            nameTextView.textAlignment = UITextAlignmentCenter;
            nameTextView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            nameTextView.borderStyle = UITextBorderStyleNone;
            nameTextView.layer.cornerRadius = 8.0f;
            nameTextView.layer.masksToBounds = YES;
            nameTextView.layer.borderWidth = 0;
            nameTextView.layer.borderColor = [UIColor grayColor].CGColor;
            [cell.contentView addSubview:nameTextView]; //加入到整個頁面中
        }
    }
    // 軟體更新
    else {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        
        UIButton *btnList = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300.0f, 30.0f)];
        //[btnList setBackgroundImage:image forState:UIControlStateNormal];
        //[btnList useBlackLabel: YES];
        [btnList setTitle:@"註冊基本資料" forState:UIControlStateNormal];
        btnList.tintColor = [UIColor clearColor];
        btnList.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [btnList.titleLabel setFont:[UIFont boldSystemFontOfSize:18.f]];
        [btnList setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btnList addTarget:self action:@selector(authentication_clicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnList setShowsTouchWhenHighlighted:YES];
        [btnList setTag:0];
        //設定轉角
        [[btnList layer] setCornerRadius:8.0f];
        [btnList.layer setMasksToBounds:YES];
        [btnList.layer setBorderWidth:0.0f];
        [btnList.layer setBorderColor:[UIColor grayColor].CGColor];
        
        [cell.contentView addSubview:btnList];
        [btnList release];
    }
    //cell.backgroundColor=[UIColor clearColor];
    return cell;
}

-(void) authentication_clicked:(id)sender{
    // 儲存認證資料
    httpSemaphore = YES;
    [self pushProfileToWS:didTextView.text name:nameTextView.text tel:@"" addr:@"" email:@""];
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
