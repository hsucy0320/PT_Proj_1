//
//  MyAnnotation.h
//  Map
//
//  Created by Lawrence on 16/07/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D myCoordinate;
    NSMutableDictionary *content;
    UIImageView * icon;
    NSString *subtitle;
    NSString *title;
}

@property (nonatomic,retain) NSString *subtitle;
@property (nonatomic,retain) NSString *title;
@property(retain, nonatomic) NSMutableDictionary *content;
@property(assign, nonatomic) CLLocationCoordinate2D myCoordinate;

- (CLLocationCoordinate2D)coordinate;

@end
