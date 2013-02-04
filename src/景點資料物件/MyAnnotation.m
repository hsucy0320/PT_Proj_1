//
//  MyAnnotation.m
//  Map
//
//  Created by Lawrence on 16/07/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

@synthesize myCoordinate, content, title, subtitle;

- (CLLocationCoordinate2D)coordinate
{
    return self.myCoordinate;
}

@end
