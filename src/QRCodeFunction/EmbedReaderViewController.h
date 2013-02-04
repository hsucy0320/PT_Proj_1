//
//  EmbedReaderViewController.h
//  EmbedReader
//
//  Created by spadix on 5/2/11.
//

#import <UIKit/UIKit.h>
#import "ZBarReaderView.h"
#import "ZBarCameraSimulator.h"

@protocol EmbedReaderViewControllerDelegate
- (void)openPOIViewer:(NSString*)pageIndex Exchange:(BOOL)bExchange;
@end

@interface EmbedReaderViewController : UIViewController < ZBarReaderViewDelegate >
{
    ZBarReaderView *_readerView;
    ZBarCameraSimulator *cameraSim;
}

@property (nonatomic, assign) ZBarReaderView *readerView;
- (void) startReaderView;
@property (nonatomic, assign) NSObject<EmbedReaderViewControllerDelegate> *delegate;
- (void) setViewDidLoad;

@end
