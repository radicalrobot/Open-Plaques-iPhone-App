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


- (void)dealloc {
	[mapView release];
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"viewDidLoad");
	[self setTitle:@"Plaques Near You"];	
	
	mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
	
	[mapView setDelegate:self];
	
	[[self view] addSubview:mapView];
	
	
	// add annotations
	OpenPlaquesAppDelegate *appDelegate = (OpenPlaquesAppDelegate *) [[UIApplication sharedApplication] delegate];	
	if([appDelegate locationAllowed])
	{
		locationManager = [appDelegate locationManager];

		//NSLog(@"Location manager exists");
		CLLocation *currentLocation = [locationManager location];		
		[mapView setShowsUserLocation:YES];
		
		MKCoordinateSpan span;
		span.latitudeDelta = 0.02;
		span.longitudeDelta = 0.02;
		
		MKCoordinateRegion region;
		region.center = [currentLocation coordinate];
		region.span = span;
		[mapView setRegion:region];
		
		[self addAnnotations];
	}
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
			UIImage * image = [UIImage imageNamed:@"blue_pin.png"];
			UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
			[pin addSubview:imageView];
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

#pragma mark -
#pragma mark Custom methods

-(void)refresh
{
	NSLog(@"refresh");
	NSArray *ants = [mapView annotations];
	[mapView removeAnnotations:ants];
	
	[self addAnnotations];
	NSLog(@"::END:: refresh");	
}

-(void) addAnnotations
{
	NSLog(@"addAnnotations");		
	OpenPlaquesAppDelegate *appDelegate = (OpenPlaquesAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSDictionary *list = [[NSDictionary alloc] initWithDictionary:[appDelegate plaqueList]];
	//NSLog(@"There are %d plaques to add to the map", [list count]);
	
	if(list != nil)
	{
		for (NSString *key in [list allKeys]) 
		{
			PlaqueVO *plaque = [list objectForKey: key];
			[self addAnnotation:plaque];
		}
		[list release];
	}
	NSLog(@"::END:: addAnnotations");	
}

-(void) addAnnotation:(PlaqueVO *)plaque
{
	PlaqueAnnotation *ann = [[PlaqueAnnotation alloc] init];
	[ann setTitle:[plaque inscription]];
	[ann setSubtitle:[plaque location]];
	[ann setCoordinate:[plaque locationCoords]];
	[ann setPlaqueId:[plaque plaqueId]];		
	[mapView addAnnotation:ann];	
	[ann release];
}
				 

@end
