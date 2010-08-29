//
//  PlaqueAnnotation.m
//  PlaqueLocation
//
//  Created by Emily Toop on 18/07/2010.
//  Copyright 2010 BuildBrighton. All rights reserved.
//

#import "PlaqueAnnotation.h"


@implementation PlaqueAnnotation
@synthesize title, subtitle, coordinate, plaqueId, pinImg;


- (void) dealloc{
	[title release];
	[subtitle release];
	[plaqueId release];
	[pinImg release];
	[super dealloc];
}


@end
