//
//  PlaqueVO.m
//  PlaqueLocation
//
//  Created by Emily Toop on 07/08/2010.
//  Copyright 2010 BuildBrighton. All rights reserved.
//

#import "PlaqueVO.h"


@implementation PlaqueVO

@synthesize inscription,location,plaqueId,dtErected,imgUrl,colour,locationCoords,ownerName,organization, dtLastModified;

-(void)dealloc
{
	[dtLastModified release];
	[plaqueId release];
	[inscription release];
	[location release];
	[imgUrl release];
	[ownerName release];
	[colour release];
	[dtErected release];
	[organization release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone *) zone
{
	PlaqueVO *plaque = [[PlaqueVO allocWithZone: zone]init];
	[plaque setPlaqueId:[self plaqueId]];
	[plaque setInscription:[self inscription]];
	[plaque setLocation:[self location]];
	[plaque setImgUrl:[self imgUrl]];
	[plaque setOwnerName:[self ownerName]];
	[plaque setColour:[self colour]];
	[plaque setDtErected:[self dtErected]];
	[plaque setLocationCoords:[self locationCoords]];
	[plaque setOrganization:[self organization]];
	[plaque setDtLastModified:[self dtLastModified]];
	
	return plaque;
}



-(BOOL) isInDisplayableLocation:(CLLocation *) currentLocation
{
	
	if(plaqueLocation == nil)
	{
		plaqueLocation = [[CLLocation alloc] initWithCoordinate:[self locationCoords] altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:nil];	
	}
	//NSLog(@"isInDisplayableLocation");
	BOOL isWithinBounds = NO;
	if(plaqueLocation != nil)
	{
		int distanceFromLocation = 0;
		
		if([[[UIDevice currentDevice] systemVersion] isEqualToString:@"3.2"]
		   || [[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.0"]
		   || [[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.0.2"])
			distanceFromLocation = [plaqueLocation distanceFromLocation:currentLocation];
		else
			distanceFromLocation = [plaqueLocation getDistanceFrom:currentLocation];
		
		
		if(distanceFromLocation <= (50 * 1000))
		{
			isWithinBounds = YES;
		}
		
		[plaqueLocation release];
	}
	
	return isWithinBounds;
}


@end
