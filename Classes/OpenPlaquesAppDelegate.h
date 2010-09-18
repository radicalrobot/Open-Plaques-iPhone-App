//
//  OpenPlaquesAppDelegate.h
//  OpenPlaques
//
//  Created by Emily Toop on 07/08/2010.
//  Copyright BuildBrighton 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SplashViewController.h"
#import "MapViewController.h"


#define kDataURL @"http://www.openplaques.org/plaques.json"

@class SplashViewController;

@interface OpenPlaquesAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
    
    UIWindow *window;
	SplashViewController *svc;
	
	NSMutableDictionary *plaqueList;
	UINavigationController *navController;
	NSString *maxUploadDate;
	NSURLConnection *connection;
	NSMutableData *receivedData;
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
	NSMutableArray *plaquesToSave;
	
	BOOL locationAllowed;
	BOOL dataRetrievalRequested;
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SplashViewController *svc;
@property (nonatomic, retain) NSMutableDictionary *plaqueList;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) BOOL locationAllowed;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;
-(void) createMap;
- (void) parsePlaques;
-(void) storeData;
-(void) storeData:(PlaqueVO *)plaque;
-(void) retrieveData;
-(void) makeAPIRequest;
-(id) retrievePlaque:(int) plaqueId;
-(id) transformManagedObjectToPlaqueVO:(NSManagedObject *) storedPlaque;
- (NSString *)dataFilePath;
-(BOOL) userHasAllowedLocationTracking;
@end

