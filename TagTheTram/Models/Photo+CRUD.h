//
//  Photo+CRUD.h
//  TagTheTram
//
//  Created by David Barthelemy on 11/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "Photo.h"

@interface Photo (CRUD)

// Create
+ (Photo *)addPhotoWithAssetUrl:(NSURL *)assetUrl
                      timeStamp:(NSDate *)timeStamp
                          title:(NSString *)title
                       latitude:(NSNumber *)latitude
                      longitude:(NSNumber *)longitude
                        station:(Station *)station;

+ (Photo *)addPhotoWithAssetUrl:(NSURL *)assetUrl
                      timeStamp:(NSDate *)timeStamp
                          title:(NSString *)title
                       latitude:(NSNumber *)latitude
                      longitude:(NSNumber *)longitude
                        station:(Station *)station
         inManagedObjectContext:(NSManagedObjectContext *)context;

// Read
- (NSURL *)assetUrl;

// Update
- (BOOL)updatePhotoWithTitle:(NSString *)title
                    latitude:(NSNumber *)latitude
                   longitude:(NSNumber *)longitude;

// Delete
- (void)deletePhoto;

@end
