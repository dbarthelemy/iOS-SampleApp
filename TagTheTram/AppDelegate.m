//
//  AppDelegate.m
//  TagTheTram
//
//  Created by David Barthelemy on 09/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "AppDelegate.h"
#import "StationsViewController.h"
#import "StationWebService.h"

@interface AppDelegate ()
@property (nonatomic, retain) NSURL *applicationMediasDirectory;

- (void)handleSettingBundle;
@end

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [_applicationMediasDirectory release];
    [super dealloc];
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self handleSettingBundle];

    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    StationsViewController *controller = (StationsViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.managedObjectContext;
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[StationWebService sharedInstance] fetchStations];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            ALog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [_managedObjectContext setUndoManager:nil]; // The undo manager is not required by this App.
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TagTheTram" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TagTheTram.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // Enable Lightweight Migration
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        ALog(@"Unresolved error %@, %@", error, [error userInfo]);

        ALog(@"Delete existing store");
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        // Retry
        NSError *retryError = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&retryError]) {
            ALog(@"Unresolved error upon retry %@, %@", retryError, [retryError userInfo]);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

- (void)resetLocalStore
{
	NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
		NSArray *stores = [coordinator persistentStores];
		
		for(NSPersistentStore *store in stores) {
			[coordinator removePersistentStore:store error:nil];
			[[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
		}
		
		[_persistentStoreCoordinator release], _persistentStoreCoordinator = nil;
	}
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)applicationMediasDirectory
{
    if (!_applicationMediasDirectory) {
        NSURL *baseUrl = [self applicationDocumentsDirectory];
        NSURL *mediasUrl = [baseUrl URLByAppendingPathComponent:kMediasDirectory isDirectory:YES];
        _applicationMediasDirectory = [mediasUrl retain];
        
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:mediasUrl withIntermediateDirectories:YES attributes:nil error:&error]) {
            if (error) {
                ALog(@"NSFileManager error %@, %@", error, [error userInfo]);
                _applicationMediasDirectory = [baseUrl retain];
            }
        }
    }
    return _applicationMediasDirectory;
}


#pragma mark - Setting Bundle

- (void)handleSettingBundle
{
    // Handle NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"AppVersion"]) {
        // Update NSUserDefaults
        DLog(@"Update NSUserDefaults");
        [defaults setObject:BUNDLE_APP_VERSION forKey:@"AppVersion"];
        [defaults setObject:BUNDLE_BUILD_VERSION forKey:@"BuildVersion"];
    }
    else {
        // Register NSUserDefaults
        DLog(@"Register NSUserDefaults");
        [defaults setObject:BUNDLE_APP_VERSION forKey:@"AppVersion"];
        [defaults setObject:BUNDLE_BUILD_VERSION forKey:@"BuildVersion"];
        
        // Make sure it is saved in the filesystem
        if (![defaults synchronize]) {
            ALog(@"NSUserDefaults cannot be saved");
        }
    }
    
    // Handle Cache flush
    if ([defaults boolForKey:@"ResetCache"]) {
        // Remove cached media
        [self removeCachedMediaFiles];
        
        // Reset the Core Data local store
        [self resetLocalStore];
        
        // Clear the flag
        [defaults setBool:NO forKey:@"ResetCache"];
    }
    
    [defaults synchronize];
}

- (void)removeCachedMediaFiles
{
    NSError *error = nil;
    NSArray *medias = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.applicationMediasDirectory
                                                    includingPropertiesForKeys:nil
                                                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                         error:&error];
    if (!error) {
        for (NSURL *eachItem in medias) {
            NSError *itemError = nil;
            [[NSFileManager defaultManager] removeItemAtURL:eachItem error:&itemError];
            if (itemError) {
                ALog(@"NSFileManager error %@, %@", error, [error userInfo]);
            }
        }
    }
    else {
        ALog(@"NSFileManager error %@, %@", error, [error userInfo]);
    }
}

@end
