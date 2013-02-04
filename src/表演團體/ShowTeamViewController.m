//
//  HospitalViewController.m
//  m-Order
//
//  Created by HSU CHIH YUAN on 12/8/3.
//  Copyright (c) 2012年 HSU CHIH YUAN. All rights reserved.
//

#import "ShowTeamViewController.h"

@interface ShowTeamViewController ()

@end

@implementation ShowTeamViewController

@synthesize dataset;
@synthesize tableView;
@synthesize delegate;

- (void)dealloc
{
    
    if (isInit) {
        [tableView release];
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
    [super viewDidLoad];
    
    isInit = NO;
    if (!isInit) {
        //加入tableView
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-navigationbarheight) style:UITableViewStylePlain];
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
        
        // 解析資料
        dataset = [[NSMutableArray alloc] init];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"showteam" ofType:@"json"];
        if (filePath) {
            NSString *myjsondata = [NSString stringWithContentsOfFile:filePath
                                                             encoding:NSUTF8StringEncoding
                                                                error:nil];
            if (myjsondata) {
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                NSDictionary *json = [parser objectWithString:myjsondata];
                NSDictionary *_items = [json objectForKey:@"items"];
                for (NSMutableDictionary *obj in _items) {
                    [dataset addObject:obj];
                }
                NSLog(@"dataset=%d",[dataset count]);
                [parser release];
            }
        }
        
        isInit = YES;
    }
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
    [self.delegate showSelfViewer:obj];
    
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
    //UILabel *distanceLabel;
    
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
                 - indicatorImage.size.width-55,
                 LABEL_HEIGHT*4)]
     autorelease];
    [cell.contentView addSubview:topLabel];
    
    //
    // Configure the properties for the text that are the same on every row
    //
    topLabel.numberOfLines = 4;
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
    /*distanceLabel =
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
    [cell.contentView addSubview:distanceLabel];*/
    
    //
    // Configure the properties for the text that are the same on every row
    //
    /*distanceLabel.backgroundColor = [UIColor clearColor];
    distanceLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    distanceLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
    distanceLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 2];
    distanceLabel.numberOfLines = 1;
    [distanceLabel setTextAlignment:UITextAlignmentRight];*/
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
	
    //badgeString 非營業時將0取代為x
    cell.badgeString = [[dataset objectAtIndex:row] objectForKey:@"type"];
    
	//
	// Here I set an image based on the row. This is just to have something
	// colorful to show on each row.
	//
    UIImage *image = [UIImage imageNamed:[[dataset objectAtIndex:row] objectForKey:@"image"]];
    float scale = image.size.width/image_HEIGHT;
    image = [self imageByScalingToSize:CGSizeMake(image_HEIGHT, image.size.height/scale) sourceImage:image];
	cell.imageView.image = image;
    
    // Get the Layer of any view
    CALayer * l = [cell.imageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:8.0];
    
    // You can even add a border
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    cell.badgeColor = [UIColor colorWithRed:0.197 green:0.592 blue:0.219 alpha:1.000];
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
