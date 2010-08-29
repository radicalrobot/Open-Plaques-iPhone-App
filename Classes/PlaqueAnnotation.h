//
//  PlaqueAnnotation.h
//  PlaqueLocation
//
//  Created by Emily Toop on 18/07/2010.
//  Copyright 2010 BuildBrighton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "PlaqueVO.h"


@interface PlaqueAnnotation : NSObject <MKAnnotation> {
	
	NSString *title;
	NSString *subtitle;
	CLLocationCoordinate2D coordinate;
	NSString *plaqueId;
	NSString *pinImg;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *plaqueId;
@property (nonatomic, retain) NSString *pinImg;

@end
