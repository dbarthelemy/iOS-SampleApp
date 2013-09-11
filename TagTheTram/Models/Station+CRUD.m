//
//  Station+CRUD.m
//  TagTheTram
//
//  Created by David Barthelemy on 10/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "Station+CRUD.h"
#import "AppDelegate.h"

@interface Station (CRUD_Private)
// Create
+ (Station *)addStationWithId:(NSString *)remoteId
                         name:(NSString *)name
                     latitude:(NSNumber *)latitude
                    longitude:(NSNumber *)longitude
       inManagedObjectContext:(NSManagedObjectContext *)context;

// Update
- (BOOL)updateStationWithName:(NSString *)name
                     latitude:(NSNumber *)latitude
                    longitude:(NSNumber *)longitude;
@end

@implementation Station (CRUD_Private)

#pragma mark - Create methods

+ (Station *)addStationWithId:(NSString *)remoteId
                         name:(NSString *)name
                     latitude:(NSNumber *)latitude
                    longitude:(NSNumber *)longitude
       inManagedObjectContext:(NSManagedObjectContext *)context
{
    if ([remoteId length] == 0) {
        ALog(@"remoteId is empty");
        return nil;
    }
    if ([name length] == 0) {
        ALog(@"name is empty");
        return nil;
    }
    
    NSEntityDescription *entityDescriptor = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:context];
    Station *station = [[[Station alloc] initWithEntity:entityDescriptor insertIntoManagedObjectContext:context] autorelease];
    
    // Initialize attributes
    station.remoteId = remoteId;
    station.name = name;
    station.latitude = latitude;
    station.longitude = longitude;
    
    NSError *error = nil;
    if (![context save:&error]) {
        ALog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return station;
}


#pragma mark - Update methods

- (BOOL)updateStationWithName:(NSString *)name
                     latitude:(NSNumber *)latitude
                    longitude:(NSNumber *)longitude
{
    BOOL wasUpdated = NO;
    
    if ((name) && (![self.name isEqualToString:name])) {
        self.name = name;
        wasUpdated = YES;
    }

    if ((latitude) && (![self.latitude isEqualToNumber:latitude])) {
        self.latitude = latitude;
        wasUpdated = YES;
    }

    if ((longitude) && (![self.longitude isEqualToNumber:longitude])) {
        self.longitude = longitude;
        wasUpdated = YES;
    }

    if (wasUpdated) {
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            ALog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return wasUpdated;
}

@end

@implementation Station (CRUD)

#pragma mark - Read methods

+ (Station *)stationWithId:(NSString *)remoteId
                      name:(NSString *)name
                  latitude:(NSNumber *)latitude
                 longitude:(NSNumber *)longitude
{
    // Use the main CodeData context
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    return [self stationWithId:remoteId
                          name:name
                      latitude:latitude
                     longitude:longitude
        inManagedObjectContext:context];
}

+ (Station *)stationWithId:(NSString *)remoteId
                      name:(NSString *)name
                  latitude:(NSNumber *)latitude
                 longitude:(NSNumber *)longitude
    inManagedObjectContext:(NSManagedObjectContext *)context;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescriptor = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:context];
    fetchRequest.entity = entityDescriptor;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"remoteId = %@", remoteId];
    
    NSError *error = nil;
    NSArray *fetchedItem = [context executeFetchRequest:fetchRequest error:&error];
    
    Station *station = nil;
    
    if (fetchedItem.count == 0) {
        // Station is created here
        station = [Station addStationWithId:(NSString *)remoteId
                                       name:(NSString *)name
                                   latitude:(NSNumber *)latitude
                                  longitude:(NSNumber *)longitude
                     inManagedObjectContext:(NSManagedObjectContext *)context];
    }
    else {
        // Update the exist Station in local database
        station = [fetchedItem objectAtIndex:0];
        [station updateStationWithName:(NSString *)name
                              latitude:(NSNumber *)latitude
                             longitude:(NSNumber *)longitude];
        
    }
    
    [fetchRequest release];
    
    return station;
}

- (NSString *)photoCounterString
{
    if ([self.photos count] == 0) {
        return @"";
    }
    else {
        return [NSString stringWithFormat:@"%u", [self.photos count]];
    }
}

@end
