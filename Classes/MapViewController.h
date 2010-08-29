//
//  MapViewController.h
//  PlaqueLocation
//
//  Created by Emily Toop on 18/07/2010.
//  Copyright 2010 BuildBrighton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PlaqueVO.h"


@interface MapViewController : UIViewController <MKMapViewDelegate>{
	MKMapView *mapView;
	NSDictionary *colourList;
	CLLocationManager *locationManager;
}

@property (nonatomic, retain) NSDictionary *colourList;


-(void) refresh;
-(void) addAnnotations:(CLLocation *)newLocation;


@end
