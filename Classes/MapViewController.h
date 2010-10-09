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
	MKMapView *mapView;	CLLocationManager *locationManager;
}



-(void) refresh;
-(void) addAnnotations;
-(void) addAnnotation:(PlaqueVO *) plaque;


@end
