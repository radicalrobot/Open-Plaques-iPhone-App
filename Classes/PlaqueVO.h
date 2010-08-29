//
//  PlaqueVO.h
//  PlaqueLocation
//
//  Created by Emily Toop on 07/08/2010.
//  Copyright 2010 BuildBrighton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>



@interface PlaqueVO : NSObject<NSCopying>
{

	NSString *inscription;
	NSString *location;
	NSString *plaqueId;
	NSString *dtErected;
	NSDate *dtLastModified;
	CLLocationCoordinate2D locationCoords;
	NSString *imgUrl;
	NSString *colour;
	NSString *ownerName;
	NSString *organization;
	CLLocation *plaqueLocation;
}

@property (nonatomic, retain) NSString *inscription;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *plaqueId;
@property (nonatomic, retain) NSString *dtErected;
@property (nonatomic, retain) NSString *imgUrl;
@property (nonatomic, retain) NSString *colour;
@property (nonatomic, retain) NSString *ownerName;
@property (nonatomic, retain) NSString *organization;
@property (nonatomic, retain) NSDate *dtLastModified;
@property (nonatomic) CLLocationCoordinate2D locationCoords;

-(BOOL) isInDisplayableLocation:(CLLocation *) location;

@end
