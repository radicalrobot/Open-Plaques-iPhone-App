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
	BOOL isWithinBounds = NO;
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 100000.0, 100000.0);
	CLLocationCoordinate2D northWestCorner, southEastCorner;
	northWestCorner.latitude  = currentLocation.coordinate.latitude  - (region.span.latitudeDelta  / 2.0);
	northWestCorner.longitude = currentLocation.coordinate.longitude + (region.span.longitudeDelta / 2.0);
	southEastCorner.latitude  = currentLocation.coordinate.latitude  + (region.span.latitudeDelta  / 2.0);
	southEastCorner.longitude = currentLocation.coordinate.longitude - (region.span.longitudeDelta / 2.0);
	
	if((locationCoords.latitude >= northWestCorner.latitude && locationCoords.latitude <= southEastCorner.latitude)
		&& (locationCoords.longitude >= southEastCorner.longitude && locationCoords.longitude <= northWestCorner.longitude))
	{
		isWithinBounds = YES;
	}
	
	return isWithinBounds;
}


@end
