//
//  EmbedReaderViewController.m
//  EmbedReader
//
//  Created by spadix on 5/2/11.
//

#import "EmbedReaderViewController.h"

@implementation EmbedReaderViewController

@synthesize delegate;
@synthesize readerView=_readerView;

- (void) cleanup
{
    [cameraSim release];
    cameraSim = nil;
    _readerView.readerDelegate = nil;
    [_readerView release];
    _readerView = nil;
}

- (void) dealloc
{
    [self cleanup];
    [super dealloc];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

#pragma 設定物件
- (void) setViewDidLoad
{
    // create our own scanner to store configuration,
    // independent of whether view is loaded
    ZBarImageScanner *scanner = [ZBarImageScanner new];
    [scanner setSymbology: 0
                   config: ZBAR_CFG_X_DENSITY
                       to: 3];
    [scanner setSymbology: 0
                   config: ZBAR_CFG_Y_DENSITY
                       to: 3];
    
    _readerView = [[ZBarReaderView alloc] initWithImageScanner: scanner];
    [scanner release];
    [_readerView setFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    _readerView.readerDelegate = (id<ZBarReaderViewDelegate>)self;
    _readerView.scanCrop = CGRectMake(0, 0, 1, 1);
    _readerView.previewTransform = CGAffineTransformIdentity;
    [self.view addSubview: _readerView];

    // you can use this to support the simulator
    if(TARGET_IPHONE_SIMULATOR) {
        cameraSim = [[ZBarCameraSimulator alloc]
                        initWithViewController: self];
        cameraSim.readerView = _readerView;
    }
}

- (void) viewDidUnload
{
    [self cleanup];
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orient
{
    // auto-rotation is supported
    return(YES);
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) orient
                                 duration: (NSTimeInterval) duration
{
    // compensate for view rotation so camera preview is not rotated
    [_readerView willRotateToInterfaceOrientation: orient
                                        duration: duration];
}

- (void) viewDidAppear: (BOOL) animated
{
    // run the reader when the view is visible
    [_readerView start];
    NSLog(@"viewDidAppear");
}

#pragma 啟動鏡頭
- (void) startReaderView
{
    // run the reader when the view is visible
    [_readerView start];
    NSLog(@"viewWillAppear");
}

- (void) viewWillDisappear: (BOOL) animated
{
    [_readerView stop];
}

- (void) readerView: (ZBarReaderView*) view didReadSymbols: (ZBarSymbolSet*) syms fromImage: (UIImage*) img
{
    // do something useful with results
    for(ZBarSymbol *sym in syms) {
        NSString *temp = sym.data;
        NSArray *firstSplit = [temp componentsSeparatedByString:@","];
        if ([firstSplit count]==2) {
            if ([[firstSplit objectAtIndex:1] isEqualToString:@"cultural.pthg"]) {
                [_readerView stop];
                [self.delegate openPOIViewer:sym.data Exchange:NO];
            }
            else if ([[firstSplit objectAtIndex:0] isEqualToString:@"cultural.pthg"]) {
                [_readerView stop];
                [self.delegate openPOIViewer:sym.data Exchange:YES];
            }
        }
        break;
    }
}

@end
