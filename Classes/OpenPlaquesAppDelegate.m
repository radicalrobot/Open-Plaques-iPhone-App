//
//  OpenPlaquesAppDelegate.m
//  OpenPlaques
//
//  Created by Emily Toop on 07/08/2010.
//  Copyright BuildBrighton 2010. All rights reserved.
//

#import "OpenPlaquesAppDelegate.h"
#import "JSON.h"
#import <MapKit/MapKit.h> 
#import "PlaqueVO.h"
#import "MapViewController.h"
#import "SplashViewController.h"


#define kFileName @"data.plist"


@implementation OpenPlaquesAppDelegate

@synthesize window,plaqueList,navController, svc,locationManager;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	//NSLog(@"didFinishLaunchingWithOptions");
	// Override point for customization after application launch.
    [window makeKeyAndVisible];
	
	
	
	svc = [[SplashViewController alloc]init];
	[[svc view] setFrame:[[UIScreen mainScreen] applicationFrame]];	
	[window addSubview:[svc view]];
	
	spinner = [[UIActivityIndicatorView alloc] 
			   initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];	
	[spinner startAnimating];

	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];	
	[window setBackgroundColor:[UIColor darkGrayColor]];	
	[window addSubview:spinner];
	
	CGRect appFrame = [[UIScreen mainScreen]applicationFrame];
	int x = (appFrame.size.width/2) - 16;
	int y = (appFrame.size.height/2) - 16;
	[spinner setFrame:CGRectMake( x, y, 32, 32)];
	
	
	plaqueList = [[NSMutableDictionary alloc] init];	
	
	locationManager = [[CLLocationManager alloc] init];
	
	[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[locationManager setDelegate:self];
	[locationManager startUpdatingLocation];
/* [self retrieveData];*/
	
	return YES;
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application 
{
	//NSLog(@"applicationWillTerminate");
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) 
	{
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) 
		{
            UIAlertView *alert = [[UIAlertView alloc] 
								  initWithTitle:@"Flickr API Error" 
								  message:[NSString stringWithFormat:@"Unable to save app data changes. %@", [error description]]  
								  delegate:nil 
								  cancelButtonTitle:@"OK" 
								  otherButtonTitles:nil];
			
			[alert show];
			[alert release];        
		} 
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"OpenPlaques" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"OpenPlaques.sqlite"]];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Flickr API Error" 
							  message:[NSString stringWithFormat:@"Unable to access stored data, retrieving from Open Plaques %@", [error description]]  
							  delegate:nil 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles:nil];
		
		[alert show];
		[alert release];
		[self makeAPIRequest];
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
	
	//NSLog(@"applicationDidReceiveMemoryWarning");
}


- (void)dealloc {
    [locationManager release];
	[maxUploadDate release];
	[plaqueList release];
	[navController release];
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [window release];
    [super dealloc];
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
	
	[self parsePlaques];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Flickr API Error" 
						  message:[NSString stringWithFormat:@"No new data could be retrieved from Open Plaques at this time %@", [error description]]  
						  delegate:nil 
						  cancelButtonTitle:@"OK" 
						  otherButtonTitles:nil];
	
	[alert show];
	[alert release];
}

# pragma mark -
# pragma mark Custom methods

-(void) parsePlaques
{
//	NSLog(@"parsePlaques");
	//(@"Parsing retrieved data as plaques");
	SBJSON *jsonParser = [[SBJSON alloc] init];
	
	NSString *jsonString = [[NSString alloc] 
							initWithData:receivedData 
							encoding:NSUTF8StringEncoding];
	NSError *jsonError = nil;
	NSArray *results = [jsonParser 
						objectWithString:jsonString
						error:&jsonError];
	[jsonString release];
	[jsonParser release];
	
	if(jsonError) {
		NSLog(@"Json has problems");
		[jsonError release];
		[self createMap];
	}
	[jsonError release];
	//NSLog(@"Json parsed OK with %d plaques", [results count]);
	
	int newPlaqueCount = 0;
	
	plaquesToSave = [[NSMutableArray alloc] init];
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	for(int i = 0; i< [results count]; ++i)
	{
		NSDictionary *plaqueJson = [results objectAtIndex:i];
		NSDictionary *plaqueDetails = [plaqueJson objectForKey:@"plaque"];
		
		
		PlaqueVO *plaque = [[PlaqueVO alloc]init];
		
		
		// plaque photo url
		/*NSArray *photos = [plaqueDetails objectForKey:@"photos"];
		if([photos count] > 0)
		{
			NSDictionary *photo = [photos objectAtIndex:0];
			[plaque setImgUrl:[photo objectForKey:@"url"]];
		}*/
		
		// plaque colour
		NSDictionary *colour = [plaqueDetails objectForKey:@"colour"];
		[plaque setColour:[colour objectForKey:@"name"]];
		
		// plaque organisation
		NSDictionary *org = [plaqueDetails objectForKey:@"organisation"];
		[plaque setOrganization:[org objectForKey:@"name"]];
		
		// plaque location
		NSDictionary *location = [plaqueDetails objectForKey:@"location"];
		[plaque setLocation:[location objectForKey:@"name"]];		
		
		if(![[plaqueDetails objectForKey:@"erected_at"] isKindOfClass:[NSNull class]])
		{
			[plaque setDtErected:[plaqueDetails objectForKey:@"erected_at"]];
		}
		
		NSString *lastModifiedStr = [plaqueDetails objectForKey:@"created_at"];
		[plaque setDtLastModified:[df dateFromString:lastModifiedStr]];
		
		[plaque setInscription:[plaqueDetails objectForKey:@"inscription"]];
		
		// if there is a long and lat then save this too, otherwise we will use reverse geocoding later to find the location
		NSString *lat = [plaqueDetails objectForKey:@"latitude"];
		NSString *lon = [plaqueDetails objectForKey:@"longitude"];		
		if(!([lat isKindOfClass:[NSNull class]]
			 && [lon isKindOfClass:[NSNull class]]))
		{	
			CLLocationCoordinate2D coordinate;
			
			coordinate.latitude = [lat doubleValue];
			coordinate.longitude = [lon doubleValue];
			[plaque setLocationCoords:coordinate];
		}
		
		//NSLog(@"received plaque %@", plaque);

		
		[plaque setPlaqueId:[plaqueDetails objectForKey:@"id"]];
		
		[plaquesToSave addObject:plaque];
		if([plaque isInDisplayableLocation:[locationManager location]])
			[plaqueList setObject:plaque forKey:[plaque plaqueId]];
		[plaque release];	
		++newPlaqueCount;
	}
	[df release];
	
	[self createMap];
	if(newPlaqueCount > 0)
	{
		[self storeData];
	}
}

-(void) createMap
{
	
	if([navController visibleViewController] != nil)
	{
		//NSLog(@"Refreshing Map View");
		MapViewController *mvc = (MapViewController *)[navController visibleViewController];
		[mvc refresh];
		//NSLog(@"MapView Refreshed");
	}
	else 
	{
		//NSLog(@"createMap");
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		[spinner stopAnimating];
		[spinner removeFromSuperview];
		[spinner release];		
		
		MapViewController *mvc = [[MapViewController alloc]init];
		[[mvc view] setFrame:[[UIScreen mainScreen] applicationFrame]];	
		// Override point for customization after app launch  
		navController = [[UINavigationController alloc] initWithRootViewController:mvc];
		//[window 
		[window addSubview:[navController view]];
		[mvc release];
		
	}	
}

/*-(BOOL) isInDisplayableLocation:(CLLocation *) plaqueLocation
{
	//NSLog(@"isInDisplayableLocation");
	BOOL isWithinBounds = NO;
	if(plaqueLocation != nil)
	{
		int distanceFromLocation = 0;
		
		if([[[UIDevice currentDevice] systemVersion] isEqualToString:@"3.2"]
		   || [[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.0"]
		   || [[[UIDevice currentDevice] systemVersion] isEqualToString:@"4.0.2"])
			distanceFromLocation = [plaqueLocation distanceFromLocation:[locationManager location]];
		else
			distanceFromLocation = [plaqueLocation getDistanceFrom:[locationManager location]];
		
		
		if(distanceFromLocation <= (50 * 1000))
		{
			//NSLog(@"%d <= 50,000", distanceFromLocation);
			isWithinBounds = YES;
		}
		//else {
			
			//NSLog(@"%d > 50,000", distanceFromLocation);
			//}

		[plaqueLocation release];
	}
	
	return isWithinBounds;
}*/

- (void) retrieveData
{
	//NSLog(@"retrieveData");
	//	NSLog(@"Retrieving data");
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Plaque" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	NSError *error;
	
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&error];
	
	
	NSString *filePath = [self dataFilePath];
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		maxUploadDate = [[NSString alloc] initWithContentsOfFile:filePath];
	}
	
	// if we cannot retrieve our data or there is no data stored then make an API request
	if(objects == nil
	   || [objects count] == 0)
	{
		[request release];
		
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Data Load in Progress" 
							  message:@"We are in the process of downloading the Open Plaques data. This may take several minutes. Please do not close the app until you are alerted that the loaded data has been saved." 
							  delegate:nil 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles:nil];
		
		[alert show];
		[alert release];
		
		[self performSelectorOnMainThread:@selector(makeAPIRequest) withObject:nil waitUntilDone:false]; 
	}
	else
	{
		//NSLog(@"Data found in storage, no API calls will be made");
		for(NSManagedObject *storedPlaque in objects)
		{
			PlaqueVO *transformedObj = [self transformManagedObjectToPlaqueVO:storedPlaque];
			
			
			// only load up the plaques that are within 50kms of our current location
			if([transformedObj isInDisplayableLocation:[locationManager location]])
			{
				[plaqueList setObject: transformedObj forKey:[transformedObj plaqueId]];
			}
		}
		
		[request release];	
		//NSLog(@"retrieved %d plaques from storage", [plaqueList count]);
		
		[self performSelectorOnMainThread:@selector(makeAPIRequest) withObject:nil waitUntilDone:false]; 
		
		if(maxUploadDate != nil)
		{
			//NSLog(@"Max upload date is %@", maxUploadDate);
			
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss'Z'"];
			
			NSString *today = [df stringFromDate:[NSDate date]];
			[df release];
			//NSLog(@"Setting last upload date to be %@", today);
			
			[today writeToFile:[self dataFilePath] atomically:YES encoding:NSUnicodeStringEncoding error:&error];
			
			[self performSelectorOnMainThread:@selector(createMap) withObject:nil waitUntilDone:false]; 
		}
		else {
			
			UIAlertView *alert = [[UIAlertView alloc] 
								  initWithTitle:@"Data Load in Progress" 
								  message:@"Open Plaques was quit before initial data load completed. We are now loading the initial data. This may take several minutes. Please do not close the app until you are alerted that the loaded data has been saved." 
								  delegate:nil 
								  cancelButtonTitle:@"OK" 
								  otherButtonTitles:nil];
			
			[alert show];
			[alert release];
		}

	}
	
}
							  
							  
- (NSString *)dataFilePath
{
	//NSLog(@"dataFilePath");
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFileName];
}

-(id) retrievePlaque:(int) plaqueId	
{	
	//NSLog(@"retrievePlaque");
	//NSLog(@"retrievePlaque %d", plaqueId);
	
	NSError *error;
	NSFetchRequest *request = [[NSFetchRequest alloc]init];
		
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Plaque" inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entityDescription];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(id = %d)", plaqueId];
	[request setPredicate:pred];
	
	NSManagedObject *storedPlaque = nil;
	
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&error];
	
	[request release];
	
	if(objects == nil)
	{
		NSLog(@"Got an error");
	}
	
	PlaqueVO *plaque = nil;
	if([objects count] > 0)
	{
		storedPlaque = [objects objectAtIndex:0];
	
		plaque = [self transformManagedObjectToPlaqueVO:storedPlaque];
	}	
	//NSLog(@"Plaque %d retrieved", plaqueId);
	return plaque;
		
}

-(id) transformManagedObjectToPlaqueVO:(NSManagedObject *) storedPlaque
{
	PlaqueVO *plaque = [[[PlaqueVO alloc] init] autorelease];
	[plaque setColour:[storedPlaque valueForKey:@"colour"]];
	[plaque setInscription:[storedPlaque valueForKey:@"inscription"]];
	[plaque setLocation:[storedPlaque valueForKey:@"location"]];
	[plaque setPlaqueId:[storedPlaque valueForKey:@"id"]];
	[plaque setDtErected:[storedPlaque valueForKey:@"erected_date"]];
	[plaque setOrganization:[storedPlaque valueForKey:@"organisation"]];
	
	//NSLog(@"Image url is %@", [storedPlaque valueForKey:@"image_url"]);
	[plaque setImgUrl:[storedPlaque valueForKey:@"image_url"]];

	// only set the location coords if they exist in the item
	CLLocationCoordinate2D coordinate;
	if ([storedPlaque valueForKey:@"latitude"] != nil
		&& [storedPlaque valueForKey:@"longitude"] != nil) 
	{
		double lat = [[storedPlaque valueForKey:@"latitude"] doubleValue];
		double lon = [[storedPlaque valueForKey:@"longitude"] doubleValue];
		//NSLog(@"Plaque %@ is at coordinates (%d,%d)", [plaque plaqueId], lat, lon);
		coordinate.latitude = lat;
		coordinate.longitude = lon;
		[plaque setLocationCoords:coordinate];
	}
	
	
	return plaque;
}

- (void) storeData
{	
	NSOperationQueue *queue = [NSOperationQueue new];
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(saveDataWithOperation)
																			  object:nil];
	
    /* Add the operation to the queue */
    [queue addOperation:operation];
    [operation release];	
	[queue release];
}

-(void)saveDataWithOperation{
//	NSLog(@"saveDataWithOperation");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];	NSError *error;
	int storedItems = 0;
//	NSLog(@"storing %d plaques from list", [plaqueList count]);	
	for(PlaqueVO *plaque in plaquesToSave)
	{
		[self storeData:plaque];
		storedItems++;
	}
	
	[[self managedObjectContext] save:&error];
	[plaquesToSave release];
	//NSLog(@"%d plaques stored", storedItems);	//NSLog(@"Setting last upload date to be %@", today);
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if(maxUploadDate == nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Data Load complete" 
							  message:@"We have successfully loaded and saved the open plaques data. You may now close the app." 
							  delegate:nil 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles:nil];
		
		[alert show];
		[alert release];
		
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss'Z'"];
		
		NSString *today = [df stringFromDate:[NSDate date]];
		[df release];
		[today writeToFile:[self dataFilePath] atomically:YES encoding:NSUnicodeStringEncoding error:&error];
	}
	
}

-(void) storeData:(PlaqueVO *)plaque
{
	//NSLog(@"Storing plaque %@", plaque);
	NSError *error;
		
	int plaqueId = [[plaque plaqueId] intValue];
	NSFetchRequest *request = [[NSFetchRequest alloc]init];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Plaque" inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entityDescription];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(id = %d)", plaqueId];
	[request setPredicate:pred];
	
	NSManagedObject *thePlaque = nil;
	
	NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&error];
	
	if(objects == nil)
	{
		NSLog(@"Got an error storing plaque %@", [plaque plaqueId]);
	}
	
	if([objects count] > 0)
		thePlaque	= [objects objectAtIndex:0];
	else
		thePlaque = [NSEntityDescription insertNewObjectForEntityForName:@"Plaque" inManagedObjectContext:[self managedObjectContext]];
	
	[thePlaque setValue:[NSNumber numberWithInt:plaqueId] forKey:@"id"];
	[thePlaque setValue:[NSString stringWithFormat:@"%@", [plaque colour]] forKey:@"colour"];
	[thePlaque setValue:[plaque inscription] forKey:@"inscription"];
	
	if([plaque organization] != nil)
		[thePlaque setValue:[plaque organization] forKey:@"organisation"];
	
	if([plaque location] != nil
	    && ![[plaque location] isKindOfClass:[NSNull class]])
	{
		[thePlaque setValue:[plaque location] forKey:@"location"];
	}

	
	if([plaque imgUrl] != nil)
		[thePlaque setValue:[plaque imgUrl] forKey:@"image_url"];
	if([plaque ownerName] != nil)
		[thePlaque setValue:[plaque ownerName] forKey:@"owner_name"];
	
	[thePlaque setValue:[NSNumber numberWithDouble:[plaque locationCoords].latitude] forKey:@"latitude"];
	[thePlaque setValue:[NSNumber numberWithDouble:[plaque locationCoords].longitude] forKey:@"longitude"];
	
	[request release];
	
	//NSLog(@"Plaques Stored %@", thePlaque);
	[[self managedObjectContext] save:&error];
}

-(void) makeAPIRequest
{
	//NSLog(@"makeAPIRequest");
	NSString *urlStr = kDataURL;
	if(maxUploadDate != nil)
		urlStr = [NSString stringWithFormat:@"%@?since=%@", kDataURL, maxUploadDate];
	//NSLog(@"Requesting data from the API with url %@", urlStr);
	
	NSURL *url = [NSURL URLWithString:urlStr];
	NSURLRequest *request = [[NSURLRequest alloc] 
							 initWithURL:url];
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	receivedData  =[[NSMutableData data] retain];
	
	[request release];
	
}

# pragma mark -
# pragma mark CLLocationManager methods

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
//	NSLog(@"didUpdateToLocation");
	//NSLog(@"MapViewController didUpdateToLocation");
	[locationManager stopUpdatingLocation];
	currentLocation = newLocation;
	
	
	NSOperationQueue *queue = [NSOperationQueue new];
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(retrieveData)
																			  object:nil];
	
    [queue addOperation:operation];
    [operation release];	
	[queue release];
}

@end
