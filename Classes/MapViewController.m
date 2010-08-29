    //
//  MapViewController.m
//  PlaqueLocation
//
//  Created by Emily Toop on 18/07/2010.
//  Copyright 2010 BuildBrighton. All rights reserved.
//

#import "MapViewController.h"
#import "OpenPlaquesAppDelegate.h"
#import "PlaqueAnnotation.h"
#import "PlaqueDetailViewController.h"


@implementation MapViewController

@synthesize colourList;


- (void)dealloc {
	[colourList release];
	[mapView release];
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//NSLog(@"viewDidLoad");
	[self setTitle:@"Plaques Near You"];	
	
	colourList = [[NSDictionary dictionaryWithObjectsAndKeys:
				   @"red_pin.jpg", @"red", 
				   @"blue_pin.png", @"blue", 
				   @"black_pin.jpg", @"black", 
				   @"brown_pin.jpg", @"brown", 
				   @"purple_pin.jpg", @"purple", 
				   @"gray_pin.png", @"grey", 
				   @"green_pin.png", @"green",
				   @"white_pin4.jpg", @"white", 
				   @"claret_pin.jpg", @"claret",
				   @"bronze_pin.jpg", @"bronze", 
				   @"gold_pin.jpg", @"gold", 
				   @"film_pin.jpg", @"film cell", 
				   @"stone_pin.jpg", @"stone", 
				   @"purple_mix.jpg", @"purple, white and green", 
				   @"orange_pin.png", @"brass",
				   @"yellow_pin.png", @"yellow",
				   nil] retain];
	
	mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
	
	[mapView setDelegate:self];
	
	[[self view] addSubview:mapView];
	
	
	// add annotations
	OpenPlaquesAppDelegate *appDelegate = (OpenPlaquesAppDelegate *) [[UIApplication sharedApplication] delegate];
	locationManager = [appDelegate locationManager];
	
	CLLocation *currentLocation = [locationManager location];
	//NSLog(@"Current location is %@", currentLocation);
	
	[mapView setShowsUserLocation:YES];
	
	MKCoordinateSpan span;
	span.latitudeDelta = 0.02;
	span.longitudeDelta = 0.02;
	
	MKCoordinateRegion region;
	region.center = [currentLocation coordinate];
	region.span = span;
	[mapView setRegion:region];
	
	[self addAnnotations:currentLocation ];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
   // NSLog(@"Did receieve memory warning");
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	
}

# pragma mark -
# pragma mark MapViewController methods

-(MKAnnotationView *) mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{

	if([annotation isKindOfClass:[PlaqueAnnotation class]])
	{
		NSString *identifier = @"pinView";
		PlaqueAnnotation *ann = (PlaqueAnnotation *)annotation;
		
		MKPinAnnotationView *pin = (MKPinAnnotationView *)[mv dequeueReusableAnnotationViewWithIdentifier:identifier];		
		if(pin == nil)
		{
			pin = [[[MKPinAnnotationView alloc] initWithAnnotation:ann reuseIdentifier:identifier] autorelease];		}
		else 
		{
			[pin setAnnotation:ann];
		}
		
		NSString *pinImg = [ann pinImg];
		if(pinImg != nil)
		{
			UIImage * image = [UIImage imageNamed:pinImg];
			UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
			[pin addSubview:imageView];
		}
		else {
			[pin setPinColor:MKPinAnnotationColorGreen];
		}

		[pin setCanShowCallout:YES];
		[pin setAnimatesDrop:NO];
		[pin setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];		
		return pin;
	}
	
	return nil;
} 

-(void) mapView:(MKMapView *)mv annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	PlaqueAnnotation *ann = (PlaqueAnnotation *)[view annotation];
	
	PlaqueDetailViewController *pvc = [[PlaqueDetailViewController alloc] init];
	[pvc setPlaqueId:[ann plaqueId]];	
	[[self navigationController] pushViewController:pvc animated:YES];
	
	// we have to release this cos we allocated it some memory
	[pvc release];
	
}


# pragma mark -
# pragma mark CLLocationManager methods

/*-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	//NSLog(@"MapViewController didUpdateToLocation");
	[locationManager stopUpdatingLocation];
	[mapView setShowsUserLocation:YES];
	
	MKCoordinateSpan span;
	span.latitudeDelta = 0.02;
	span.longitudeDelta = 0.02;
	
	MKCoordinateRegion region;
	region.center = [newLocation coordinate];
	region.span = span;
	[mapView setRegion:region];
	
	[self addAnnotations:newLocation ];
}*/

#pragma mark -
#pragma mark Custom methods

-(void)refresh
{
	//NSLog(@"refresh");
	NSArray *ants = [mapView annotations];
	[mapView removeAnnotations:ants];
	
	[self addAnnotations:[locationManager location]];
}

-(void) addAnnotations:(CLLocation *)newLocation
{
	//NSLog(@"addAnnotation");		
	OpenPlaquesAppDelegate *appDelegate = (OpenPlaquesAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSDictionary *list = [appDelegate plaqueList];
	//NSLog(@"There are %d plaques to add to the map", [list count]);
	for (NSString *key in [list allKeys]) 
	{
		PlaqueVO *plaque = [list objectForKey: key];
		
		PlaqueAnnotation *ann = [[PlaqueAnnotation alloc] init];
		[ann setTitle:[plaque inscription]];
		[ann setSubtitle:[plaque location]];
		[ann setCoordinate:[plaque locationCoords]];
		[ann setPlaqueId:[plaque plaqueId]];
		NSString *colourId = [plaque colour];
		if(colourId != nil)
		{
			if([colourList objectForKey:colourId] != nil)
			{
				[ann setPinImg:[colourList objectForKey:colourId]];
			}
		}
		
		[mapView addAnnotation:ann];	
		[ann release];
	}
}
				 

@end
