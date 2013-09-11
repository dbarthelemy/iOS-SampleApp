//
//  Station+CRUD.h
//  TagTheTram
//
//  Created by David Barthelemy on 10/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "Station.h"

@interface Station (CRUD)

// Create (Private)

// Read
+ (Station *)stationWithId:(NSString *)remoteId
                      name:(NSString *)name
                  latitude:(NSNumber *)latitude
                 longitude:(NSNumber *)longitude;

+ (Station *)stationWithId:(NSString *)remoteId
                      name:(NSString *)name
                  latitude:(NSNumber *)latitude
                 longitude:(NSNumber *)longitude
    inManagedObjectContext:(NSManagedObjectContext *)context;

- (NSString *)photoCounterString;

// Update (Private)

// Delete (The assumption here is that a Station won't disapear)

@end
