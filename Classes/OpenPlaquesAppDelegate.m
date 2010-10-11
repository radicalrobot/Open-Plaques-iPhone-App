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

@synthesize window,plaqueList,navController, svc,locationManager, locationAllowed;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	NSLog(@"didFinishLaunchingWithOptions");
	// Override point for customization after application launch.
    [window makeKeyAndVisible];
	
	
	
	svc = [[SplashViewController alloc]init];
	[[svc view] setFrame:[[UIScreen mainScreen] applicationFrame]];	
	[window addSubview:[svc view]];
	
	
	plaqueList = [[NSMutableDictionary alloc] init];	
	plaquesToSave = [[[NSMutableArray alloc] init] retain];
	
	locationManager = [[CLLocationManager alloc] init];
	
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	if(version < 4.0f)
		locationAllowed = locationManager.locationServicesEnabled;
	else
		locationAllowed = [CLLocationManager locationServicesEnabled];
	
	if(locationAllowed)
	{
		//NSLog(@"location manager location services enabled");
		
		
		//NSLog(@"location manager created");
		
		[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[locationManager setDelegate:self];
		
		[locationManager startUpdatingLocation];
	}
	else 
	{
		NSLog(@"location manager location services NOT enabled");
		[svc showLocationAlert];
		[self createMap];
	}

	
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
								  initWithTitle:@"Data Save Error" 
								  message:[NSString stringWithFormat:@"Unable to save app data changes"]  
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
	[plaquesToSave release];
    [locationManager release];
	[maxUploadDate release];
	[plaqueList release];
	[navController release];
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
	[svc release];
    
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
	
	[self parsePlaques:receivedData];
	
	if([plaquesToSave count] > 0)
	{
		[self storeData];
	}
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	if(plaqueList == nil
	   || [plaqueList count] == 0)
	{
		[svc showDataRetreivalFailureAlert];
	}
	NSLog(@"connectionDidFailWithError");
	[self createMap];
}

# pragma mark -
# pragma mark Custom methods



-(void) getPlaquesFromStorage
{	
	NSLog(@"getPlaquesFromStorage");
	NSString* path = [[NSBundle mainBundle] pathForResource:@"plaques" 
													 ofType:@"json"];
	
	NSMutableData *plaqueData = [[[NSMutableData alloc] initWithContentsOfFile:path] retain];	
	
	[self parsePlaques:plaqueData];
	
	NSError *error;
	/// save the file date so we know when to fetch the plaques since from openplaques.org		
	maxUploadDate = @"2010-10-09'T'12:20:00'Z'";
	[maxUploadDate writeToFile:[self dataFilePath] atomically:YES encoding:NSUnicodeStringEncoding error:&error];
	
	// now go and fetch everything that happened since last time
	[self makeAPIRequest];
	
}

-(void) parsePlaques:(NSData *)plaqueData
{
	NSLog(@"parsePlaques");
//(@"Parsing retrieved data as plaques");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	SBJSON *jsonParser = [[SBJSON alloc] init];
	
	NSString *jsonString = [[NSString alloc] 
							initWithData:plaqueData 
							encoding:NSUTF8StringEncoding];
	//NSLog(@"Json String %@", jsonString);
	NSError *jsonError = nil;
	NSArray *results = [jsonParser 
						objectWithString:jsonString
						error:&jsonError];
	[jsonString release];
	[jsonParser release];
	
	if(jsonError) {
		NSLog(@"Json has problems %@", jsonError);
		[jsonError release];
		[self createMap];
		return;
	}
	[jsonError release];
	
	//NSLog(@"Json parsed OK with %d plaques", [results count]);
	
	int newPlaqueCount = 0;
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	for(int i = 0; i< [results count]; ++i)
	{
		NSDictionary *plaqueJson = [results objectAtIndex:i];
		NSDictionary *plaqueDetails = [plaqueJson objectForKey:@"plaque"];
		
		
		PlaqueVO *plaque = [[PlaqueVO alloc]init];
		
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
			//NSLog(@"Erected at %@",[plaque dtErected]);
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
		if(locationAllowed
		   && [plaque isInDisplayableLocation:[locationManager location]])
		{
			[plaqueList setObject:plaque forKey:[plaque plaqueId]];
		}
		[plaque release];	
		++newPlaqueCount;
	}
	[df release];
	
	if(newPlaqueCount > 0)
	{
		NSLog(@"New plaque count = %d", newPlaqueCount);
		[self createMap];
	}
	[plaqueData release];
}

-(void) createMap
{
	NSLog(@"createMap");
	
	if([navController visibleViewController] != nil)
	{
		NSLog(@"Refreshing Map View");
		MapViewController *mvc = (MapViewController *)[navController visibleViewController];
		[mvc refresh];
		NSLog(@"MapView Refreshed");
	}
	else 
	{
		//NSLog(@"createMap");
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];		
		MapViewController *mvc = [[MapViewController alloc]init];
		[[mvc view] setFrame:[[UIScreen mainScreen] applicationFrame]];	
		// Override point for customization after app launch  
		navController = [[UINavigationController alloc] initWithRootViewController:mvc];
		//[window 
		[window addSubview:[navController view]];
		[mvc release];
		
	}	
}

- (void) retrieveData
{
	//NSLog(@"retrieveData");
	currentLocation = [locationManager location];	
	//MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 100000.0, 100000.0);
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 10000.0, 10000.0);
	CLLocationCoordinate2D northWestCorner, southEastCorner;
	northWestCorner.latitude  = currentLocation.coordinate.latitude  - (region.span.latitudeDelta  / 2.0);
	northWestCorner.longitude = currentLocation.coordinate.longitude + (region.span.longitudeDelta / 2.0);
	southEastCorner.latitude  = currentLocation.coordinate.latitude  + (region.span.latitudeDelta  / 2.0);
	southEastCorner.longitude = currentLocation.coordinate.longitude - (region.span.longitudeDelta / 2.0);
	
	//NSLog(@"retrieveData");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];	
	//	NSLog(@"Retrieving data");
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Plaque" inManagedObjectContext:[self managedObjectContext]];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	
	NSError *error;
	
	int numRecords = [[self managedObjectContext] countForFetchRequest:request error:&error];	
	NSLog(@"The number of record are %d", numRecords);
	NSString *filePath = [self dataFilePath];
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		maxUploadDate = [[NSString alloc] initWithContentsOfFile:filePath];
	}
	
	// if we cannot retrieve our data or there is no data stored then make an API request
	if(numRecords < 3000)
	{
		[request release];
		
		[self performSelectorOnMainThread:@selector(getPlaquesFromStorage) withObject:nil waitUntilDone:false]; 
	}
	else
	{
		error = nil;
		// only load up the plaques that are within 50kms of our current location
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"(latitude >= %Lf AND latitude <= %Lf) AND (longitude >= %Lf AND longitude <= %Lf)", northWestCorner.latitude, southEastCorner.latitude, southEastCorner.longitude, northWestCorner.longitude];
		[request setPredicate:pred];
		
		
		NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&error];
		
		//NSLog(@"Data found in storage, no API calls will be made");
		for(NSManagedObject *storedPlaque in objects)
		{
			PlaqueVO *transformedObj = [self transformManagedObjectToPlaqueVO:storedPlaque];
			
			[plaqueList setObject: transformedObj forKey:[transformedObj plaqueId]];
		}
		
		[request release];	
		NSLog(@"retrieved %d plaques from storage", [plaqueList count]);
		
		[self performSelectorOnMainThread:@selector(makeAPIRequest) withObject:nil waitUntilDone:false]; 
		
		//NSLog(@"Max upload date is %@", maxUploadDate);
		
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		
		NSString *today = [df stringFromDate:[NSDate date]];
		[df release];
		//NSLog(@"Setting last upload date to be %@", today);
		
		[today writeToFile:[self dataFilePath] atomically:YES encoding:NSUnicodeStringEncoding error:&error];
		NSLog(@"Data retrieved");
		[self performSelectorOnMainThread:@selector(createMap) withObject:nil waitUntilDone:false]; 
	}
	
}
							  
							  
- (NSString *)dataFilePath
{
	NSLog(@"dataFilePath");
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kFileName];
}

-(id) transformManagedObjectToPlaqueVO:(NSManagedObject *) storedPlaque
{
	PlaqueVO *plaque = [[[PlaqueVO alloc] init] autorelease];
	[plaque setColour:[storedPlaque valueForKey:@"colour"]];
	[plaque setInscription:[storedPlaque valueForKey:@"inscription"]];
	[plaque setLocation:[storedPlaque valueForKey:@"location"]];
	[plaque setPlaqueId:[storedPlaque valueForKey:@"id"]];
	
	NSDate *dtErected = [storedPlaque valueForKey:@"erected_date"];
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"dd-MM-yyyy"];
	[plaque setDtErected:[df stringFromDate:dtErected]];
	[df release];
	
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
	NSLog(@"Store data %d", [plaquesToSave count]);
	//NSArray *toSave = [[NSArray alloc]initWithArray:plaquesToSave];
	//[plaquesToSave removeAllObjects];

	NSOperationQueue *queue = [NSOperationQueue new];
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(saveDataWithOperation)
																			  object:NULL];
	
    /* Add the operation to the queue */
    [queue addOperation:operation];
    [operation release];	
	[queue release];
}

-(void)saveDataWithOperation{
	NSLog(@"saveDataWithOperation");
	NSError *error;
	int storedItems = 0;
	
	NSFetchRequest *request = [[NSFetchRequest alloc]init];
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Plaque" inManagedObjectContext:[self managedObjectContext]];
	[request setEntity:entityDescription];
	//NSLog(@"storing %d plaques from list", [plaquesToSave count]);	
	if(plaquesToSave != nil)
	{
		@synchronized([self managedObjectContext])
		{
			for(PlaqueVO *plaque in plaquesToSave)
			{
				//[self storeData:plaque];
				int plaqueId = [[plaque plaqueId] intValue];
				[request setPredicate:[NSPredicate predicateWithFormat:@"(id = %d)", plaqueId]];
				
				NSManagedObject *thePlaque = nil;
				
				NSArray *objects = [[self managedObjectContext] executeFetchRequest:request error:&error];
				
				if(objects == nil)
				{
					NSLog(@"Got an error storing plaque %@", [plaque plaqueId]);
					continue;
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
				
				if([plaque dtErected] != nil)
				{
					NSDateFormatter *df = [[NSDateFormatter alloc] init];
					[df setDateFormat:@"yyyy-MM-dd"];
					
					NSDate *dtErected = [df dateFromString:[plaque dtErected]];
					//NSLog(@"Saving date last checked as %@", today);
					[df release];
					
					[thePlaque setValue:dtErected forKey:@"erected_date"];
				}
				
				if(storedItems % 75 == 0)
				{
					//NSLog(@"Saving %d items", storedItems);
					[[self managedObjectContext] save:&error];
				}
				
				storedItems++;
			}
			
			//NSLog(@"Saving %d items", storedItems);
			[[self managedObjectContext] save:&error];
			//	[error release];
			[request release];
		}
	}
	
	//[toSave release];
	//NSLog(@"%d plaques stored", storedItems);	//NSLog(@"Setting last upload date to be %@", today);
	
	
	NSError *dateError;
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		
	NSString *today = [df stringFromDate:[NSDate date]];
	//NSLog(@"Saving date last checked as %@", today);
	[today writeToFile:[self dataFilePath] atomically:YES encoding:NSUnicodeStringEncoding error:&dateError];	
	[df release];
	NSLog(@"Data saved");
}

-(void) storeData:(PlaqueVO *)plaque
{
//	NSLog(@"Storing plaque %@", plaque);		
	
	
	//NSLog(@"Plaques Stored %@", thePlaque);
}

-(void) makeAPIRequest
{
	NSLog(@"makeAPIRequest");
	NSString *urlStr = kDataURL;
	if(maxUploadDate != nil)
		urlStr = [NSString stringWithFormat:@"%@?since=%@", kDataURL, maxUploadDate];
	NSLog(@"Requesting data from the API with url %@", urlStr);
	
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSURL *url = [NSURL URLWithString:urlStr];
	NSURLRequest *request = [[NSURLRequest alloc] 
							 initWithURL:url];
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if(receivedData != nil)
		[receivedData release];
	receivedData  =[[NSMutableData data] retain];
	
	[request release];
	
}

-(BOOL) userHasAllowedLocationTracking
{
	return [self locationAllowed];
}

# pragma mark -
# pragma mark CLLocationManager methods

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	NSLog(@"Did update to location");
	locationAllowed = YES;
	
//	[locationManager 
	if (newLocation.horizontalAccuracy > 0.0f &&
		newLocation.horizontalAccuracy < 120.0f)
	{
		[locationManager stopUpdatingLocation];
		currentLocation = newLocation;
		
		if(!dataRetrievalRequested)
		{
			NSOperationQueue *queue = [NSOperationQueue new];
			NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																					selector:@selector(retrieveData)
																					  object:nil];
			
			[queue addOperation:operation];
			[operation release];	
			[queue release];
			dataRetrievalRequested = YES;
		}
	}
}

- (void)locationManager:(CLLocationManager*)aManager didFailWithError:(NSError*)anError
{
	NSString *message = nil;
    switch([anError code])
    {
		case kCLErrorLocationUnknown: // location is currently unknown, but CL will keep trying
			break;
			
		case kCLErrorDenied: // CL access has been denied (eg, user declined location use)
			message = @"Sorry, Open Plaques has to know your location in order to work. You will not be able to see any plaques";
			break;
			
		case kCLErrorNetwork: // general, network-related error
			message = @"Open Plaques can't find you - please check your network connection or that you are not in airplane mode";
    }
	
	if(message != nil)
	{
		locationAllowed = NO;
		[svc showLocationSwitchedOffAlert:message];
		NSLog(@"location off");
		[self createMap];
	}
}

@end

