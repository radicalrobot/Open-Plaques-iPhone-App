//
//  PlaqueViewController.m
//  OpenPlaques
//
//  Created by Emily Toop on 17/08/2010.
//  Copyright 2010 BuildBrighton. All rights reserved.
//

#import "PlaqueDetailViewController.h"
#import "OpenPlaquesAppDelegate.h"

#import "TouchXML.h"

#define kFlickrApiKey @"01f3517b09e677ea91498d72f79e1cb9"


@implementation PlaqueDetailViewController

@synthesize plaqueImageView, plaqueTranscriptionLabel, plaqueLocationLabel, plaqueErectedDateLabel, plaquePhotoOwnerLabel, plaque, plaqueId, erectedLabel, locationLabel, scrollView1;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self setTitle:@"Plaque Detail"];
		
	[[self view] setBackgroundColor:[UIColor whiteColor]];
	
	OpenPlaquesAppDelegate *appDelegate = (OpenPlaquesAppDelegate *) [[UIApplication sharedApplication] delegate];
	NSDictionary *list = [appDelegate plaqueList];
	PlaqueVO *savedPlaque = [list objectForKey:plaqueId];
	//	NSLog(@"Viewing details of plaque %@ with inscription %@, location %@", [savedPlaque plaqueId], [savedPlaque inscription], [savedPlaque location]);
	plaque = [savedPlaque copy];	

	//NSLog(@"Copied saved plaque %@ with inscription %@, location %@", [plaque plaqueId], [plaque inscription], [plaque location]);
	
	plaquePhotoOwnerLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 220, 260, 21)];
	[plaquePhotoOwnerLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	[plaquePhotoOwnerLabel setTextColor:[UIColor blackColor]];
	[plaquePhotoOwnerLabel setBackgroundColor:[UIColor clearColor]];	
	[plaquePhotoOwnerLabel setNumberOfLines:3];
	[plaquePhotoOwnerLabel setTextAlignment:UITextAlignmentRight];
	[[self view] addSubview:plaquePhotoOwnerLabel];	
	
	// create the scroll view onto which we're going to put the plaque detail text
	scrollView1 = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 242, 284, 300)];
	[scrollView1 setBackgroundColor:[UIColor whiteColor]];
	[scrollView1 setCanCancelContentTouches:NO];
	scrollView1.indicatorStyle = UIScrollViewIndicatorStyleBlack;
	scrollView1.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
	scrollView1.scrollEnabled = YES;
	
	// pagingEnabled property default is NO, if set the scroller will stop or snap at each photo
	// if you want free-flowing scroll, don't set this property.
	scrollView1.pagingEnabled = YES;
	
	
	[[self view] addSubview:scrollView1];
	
	
	// add the photo by name label
	
	// add the inscription
	UIFont *inscriptionFont = [UIFont fontWithName:@"Helvetica" size:14];
	
	//[plaque setInscription:@"This is a \nreally long bit of text\r\nthat splits over\r\nseveral lines.\r\nI want to\r\ndisplay it all"];
	NSString *inscriptionStr = [[plaque inscription] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
	inscriptionStr = [inscriptionStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	//NSLog(@"Inscription text is %@", inscriptionStr);
	//plaqueTranscriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 243, 280, 65)];
	plaqueTranscriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, 280, 100)];
	[plaqueTranscriptionLabel setFont:inscriptionFont];
	[plaqueTranscriptionLabel setTextColor:[UIColor blackColor]];
	[plaqueTranscriptionLabel setText:inscriptionStr];
	[plaqueTranscriptionLabel setBackgroundColor:[UIColor clearColor]];	
	// wrap our lines 
	[plaqueTranscriptionLabel setNumberOfLines:0];
	[plaqueTranscriptionLabel setLineBreakMode:UILineBreakModeWordWrap];
	[scrollView1 addSubview:plaqueTranscriptionLabel];
	
	// calculate height of description text box
	CGSize size = [inscriptionStr 
				   sizeWithFont:inscriptionFont
				   constrainedToSize:[plaqueTranscriptionLabel frame].size
				   lineBreakMode:UILineBreakModeWordWrap];	
	CGRect newFrame = CGRectMake([plaqueTranscriptionLabel frame].origin.x, 
								 [plaqueTranscriptionLabel frame].origin.y, 
								 [plaqueTranscriptionLabel frame].size.width, 
								 size.height);
	
	[plaqueTranscriptionLabel setFrame:newFrame];
	
	
	int nextY = (newFrame.origin.y + newFrame.size.height) + 10;
	
	// add the location label
	locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, nextY, 65, 21)];
	[locationLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
	[locationLabel setTextColor:[UIColor lightGrayColor]];
	[locationLabel setText:@"Location: "];
	[locationLabel setBackgroundColor:[UIColor clearColor]];	
	[scrollView1 addSubview:locationLabel];
	
	// add the location
	
	UIFont *locationFont = [UIFont fontWithName:@"Helvetica-Bold" size:14];
	plaqueLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, nextY, 201, 42)];
	[plaqueLocationLabel setFont:locationFont];
	[plaqueLocationLabel setTextColor:[UIColor blackColor]];
	[plaqueLocationLabel setText:[plaque location]];
	[plaqueLocationLabel setBackgroundColor:[UIColor clearColor]];	
	// wrap our lines 
	[plaqueLocationLabel setNumberOfLines:0];
	[plaqueLocationLabel setLineBreakMode:UILineBreakModeWordWrap];
	[scrollView1 addSubview:plaqueLocationLabel];
	
	// calculate height of description text box
	CGSize locationSize = [[plaque location] 
				   sizeWithFont:locationFont
				   constrainedToSize:[plaqueLocationLabel frame].size
				   lineBreakMode:UILineBreakModeWordWrap];	
	CGRect locationFrame = CGRectMake([plaqueLocationLabel frame].origin.x, 
								 [plaqueLocationLabel frame].origin.y, 
								 [plaqueLocationLabel frame].size.width, 
									  locationSize.height);
	[plaqueLocationLabel setFrame:locationFrame];
	
	 nextY = (locationFrame.origin.y + locationFrame.size.height) + 10;
	 
	 // add the erected label
	 erectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, nextY, 60, 21)];
	 [erectedLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
	 [erectedLabel setTextColor:[UIColor lightGrayColor]];
	 [erectedLabel setText:@"Erected: "];
	 [erectedLabel setBackgroundColor:[UIColor clearColor]];	
	 [scrollView1 addSubview:erectedLabel];
	
	
	NSString *erectedDateStr = [plaque dtErected];
	//NSLog(@"DtErected %@", erectedDateStr);
	NSString *erectedStr = nil;
	 if([plaque organization] != nil
	 && erectedDateStr != nil)
	 {		erectedStr = [NSString stringWithFormat:@"By %@ on %@", [plaque organization], erectedDateStr];
	 }
	 else if([plaque organization] != nil)
	 {
		 erectedStr = [NSString stringWithFormat:@"By %@", [plaque organization]];
	 }
	 else if(erectedDateStr != nil)
	 {
		 erectedStr = [NSString stringWithFormat:@"On %@", erectedDateStr];
	 }
	 else 
	 {
		 erectedStr = @"Unknown";
	 }
	
	//NSLog(@"Erected String %@", erectedStr);
	// add the erected text
	
	
	UIFont *erectedFont = [UIFont fontWithName:@"Helvetica-Bold" size:14];
	plaqueErectedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, nextY, 201, 42)];
	[plaqueErectedDateLabel setFont:erectedFont];
	[plaqueErectedDateLabel setTextColor:[UIColor blackColor]];
	[plaqueErectedDateLabel setText:erectedStr];
	[plaqueErectedDateLabel setBackgroundColor:[UIColor clearColor]];	
	// wrap our lines 
	[plaqueErectedDateLabel setNumberOfLines:0];
	[plaqueErectedDateLabel setLineBreakMode:UILineBreakModeWordWrap];
	[scrollView1 addSubview:plaqueErectedDateLabel];
	
	// calculate height of description text box
	CGSize erectedSize = [erectedStr 
						  sizeWithFont:erectedFont
						  constrainedToSize:[plaqueErectedDateLabel frame].size
						  lineBreakMode:UILineBreakModeWordWrap];	
	CGRect erectedFrame = CGRectMake([plaqueErectedDateLabel frame].origin.x, 
									 [plaqueErectedDateLabel frame].origin.y, 
									 [plaqueErectedDateLabel frame].size.width, 
									 erectedSize.height);
	[plaqueErectedDateLabel setFrame:erectedFrame];
	
	
	if([plaque imgUrl] != nil
	   && [plaque ownerName] != nil)
	{
		plaquePhotoOwnerLabel.text = [NSString stringWithFormat:@"Photo By: %@", ([plaque ownerName] == nil) ? @"Unknown" : [plaque ownerName]];
		CGRect frame;
		frame.size.width=280; frame.size.height=215;
		frame.origin.x=20; frame.origin.y=10;
		
		plaqueImageView = [[[AsyncImageView alloc]initWithFrame:frame] autorelease];
		plaqueImageView.tag = 999;
		NSURL* url = [NSURL URLWithString:[plaque imgUrl]];
		[plaqueImageView loadImageFromURL:url];
		[[self view] addSubview:plaqueImageView];	
	}
	else 
	{
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		NSString *urlStr = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&machine_tags=openplaques:id=%@&extras=url_s,url_t,owner_name", kFlickrApiKey, [plaque plaqueId]];
		//	NSLog(@"Requesting data from %@", urlStr);
		NSURL *url = [NSURL URLWithString: urlStr];
		NSURLRequest *request = [[NSURLRequest alloc] 
								 initWithURL:url];
		
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		
		receivedData  =[[NSMutableData data] retain];
		
		[request release];
	}
	
	
    [super viewDidLoad];
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
	self.plaqueLocationLabel = nil;
	self.plaqueTranscriptionLabel = nil;
	self.plaqueErectedDateLabel = nil;
	self.plaquePhotoOwnerLabel = nil;
	self.plaqueImageView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[plaqueId release];
	[plaque release];
	[plaqueLocationLabel release];
	[plaqueTranscriptionLabel release];
	[plaqueErectedDateLabel release];
	[plaquePhotoOwnerLabel release];
	[connection release];
	[receivedData release];
	[scrollView1 release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom methods

-(void)parseFlickrResult
{
	//NSLog(@"Parsing retrieved data as plaques %@", receivedData);	// intialise xml parser
	CXMLDocument *parser = [[[CXMLDocument alloc] initWithData:receivedData options:0 error:nil] autorelease];
	
	NSArray *nodes = [parser nodesForXPath:@"//photo" error:nil];
	//	NSLog(@"there are %d nodes", [nodes count]);
	NSString *imgUrl = @"take-a-photo.png";
	//loop through nodes
	if([nodes count] > 0) 
	{
		CXMLElement *node = [nodes objectAtIndex:0];
		//	NSLog(@"current node is %@ ", node); 
		
		//	NSLog(@"node attributes is %@ ", [node attributes]);
		
		// loop through elements
		for( CXMLNode *attribute in [node attributes])
		{
			//	NSLog(@"Attribite name %@:%@", [attribute name],[attribute stringValue]);
			if([@"url_s" isEqualToString:[attribute name]])
			{
				imgUrl = [attribute stringValue];				
				[plaque setImgUrl:imgUrl];	
			}
			else if([@"ownername" isEqualToString:[attribute name]])
			{
				//	NSLog(@"Photo owner name is %@", [attribute stringValue]);
				[plaque setOwnerName:[attribute stringValue]];
				plaquePhotoOwnerLabel.text = [NSString stringWithFormat:@"Photo By: %@", [plaque ownerName]];
			}
		}
		[self savePlaque];
	}
		
		
	CGRect frame;
	frame.size.width=280; frame.size.height=215;
	frame.origin.x=20; frame.origin.y=10;
	
	plaqueImageView = [[[AsyncImageView alloc]initWithFrame:frame] autorelease];
	plaqueImageView.tag = 999;
	if([imgUrl hasPrefix:@"http"])
	{
		NSURL* url = [NSURL URLWithString:imgUrl];
		[plaqueImageView loadImageFromURL:url];
	}
	else {
		[plaqueImageView setImage:imgUrl];
	}

	[[self view] addSubview:plaqueImageView];
	

}

-(void)savePlaque
{	
	OpenPlaquesAppDelegate *appDelegate = (OpenPlaquesAppDelegate *) [[UIApplication sharedApplication] delegate];
	[appDelegate storeData:plaque];
	
}

-(void)refresh
{
	// do nothing here
}


#pragma mark -
#pragma mark NSURLConnection delegate methods

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	[receivedData setLength:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[receivedData appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[self parseFlickrResult];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	//NSLog(@"Error Loading");
}



@end
