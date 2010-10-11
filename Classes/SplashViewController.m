//
//  SplashViewController.m
//  OpenPlaques
//
//  Created by Emily Toop on 25/08/2010.
//  Copyright 2010 BuildBrighton. All rights reserved.
//

#import "SplashViewController.h"


@implementation SplashViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] 
			   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];	
	[spinner startAnimating];
	
	
	[[self view] addSubview:spinner];
	
	
	CGRect appFrame = [[UIScreen mainScreen]applicationFrame];
	int x = (appFrame.size.width/2) - 16;
	int y = (appFrame.size.height/2) - 16;
	[spinner setFrame:CGRectMake( x, y, 32, 32)];
	
	[spinner release];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

-(void) showLocationAlert
{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Location Manager" 
						  message:@"This app requires location services that your device does not support. I'm really sorry." 
						  delegate:nil 
						  cancelButtonTitle:@"Understood" 
						  otherButtonTitles:nil];
	
	[alert show];
	[alert release]; 	
}



-(void) showLocationSwitchedOffAlert:(NSString *) message
{
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Location Manager" 
						  message:message
						  delegate:nil 
						  cancelButtonTitle:@"Understood" 
						  otherButtonTitles:nil];
	
	[alert show];
	[alert release]; 	
}

-(void) showDataRetreivalFailureAlert
{
	
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Open Plaques data connection Error" 
						  message:@"No new data could be retrieved from Open Plaques at this time." 
						  delegate:nil 
						  cancelButtonTitle:@"OK" 
						  otherButtonTitles:nil];
	
	[alert show];
	[alert release];
}


@end
