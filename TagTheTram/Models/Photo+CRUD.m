//
//  Photo+CRUD.m
//  TagTheTram
//
//  Created by David Barthelemy on 11/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "Photo+CRUD.h"
#import "AppDelegate.h"

@interface Photo (CRUD_Private)
// URL persitence
+ (NSData*)bookmarkForURL:(NSURL*)url;
+ (NSURL*)urlForBookmark:(NSData*)bookmark;
@end

@implementation Photo (CRUD_Private)

+ (NSData*)bookmarkForURL:(NSURL*)url {
    NSError* theError = nil;
    NSData* bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
                     includingResourceValuesForKeys:nil
                                      relativeToURL:nil
                                              error:&theError];
    if (theError || (bookmark == nil)) {
        // Handle any errors.
        return nil;
    }
    return bookmark;
}

+ (NSURL*)urlForBookmark:(NSData*)bookmark {
    BOOL bookmarkIsStale = NO;
    NSError* theError = nil;
    NSURL* bookmarkURL = [NSURL URLByResolvingBookmarkData:bookmark
                                                   options:NSURLBookmarkResolutionWithoutUI
                                             relativeToURL:nil
                                       bookmarkDataIsStale:&bookmarkIsStale
                                                     error:&theError];
    
    if (bookmarkIsStale || (theError != nil)) {
        // Handle any errors
        return nil;
    }
    return bookmarkURL;
}

@end

@implementation Photo (CRUD)

#pragma mark - Create methods

+ (Photo *)addPhotoWithAssetUrl:(NSURL *)assetUrl
                      timeStamp:(NSDate *)timeStamp
                          title:(NSString *)title
                       latitude:(NSNumber *)latitude
                      longitude:(NSNumber *)longitude
                        station:(Station *)station
{
    // Use the main CodeData context
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    return [Photo addPhotoWithAssetUrl:assetUrl
                             timeStamp:timeStamp
                                 title:title
                              latitude:latitude
                             longitude:longitude
                               station:station
                inManagedObjectContext:context];
}

+ (Photo *)addPhotoWithAssetUrl:(NSURL *)assetUrl
                      timeStamp:(NSDate *)timeStamp
                          title:(NSString *)title
                       latitude:(NSNumber *)latitude
                      longitude:(NSNumber *)longitude
                        station:(Station *)station
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (!assetUrl) {
        ALog(@"assetUrl is nil");
        return nil;
    }
    if (!station) {
        ALog(@"station is nil");
        return nil;
    }
    NSData *assetBookmark = [Photo bookmarkForURL:assetUrl];
    if (!assetBookmark) {
        ALog(@"assetUrl cannot be converted to bookmark");
        return nil;
    }
    
    NSEntityDescription *entityDescriptor = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
    Photo *photo = [[[Photo alloc] initWithEntity:entityDescriptor insertIntoManagedObjectContext:context] autorelease];
    
    // Initialize attributes
    photo.bookmark = assetBookmark;
    photo.timeStamp = timeStamp ? timeStamp : [NSDate date];
    photo.title = title ? title : @"";
    photo.latitude = latitude ? latitude : @0.0;
    photo.longitude = longitude ? longitude : @0.0;

    // Initialize relationships
    photo.station = station;
    
    NSError *error = nil;
    if (![context save:&error]) {
        ALog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return photo;
}


#pragma mark - Read methods

- (NSURL *)assetUrl
{
    return [Photo urlForBookmark:self.bookmark];
}


#pragma mark - Update methods

- (BOOL)updatePhotoWithTitle:(NSString *)title
                    latitude:(NSNumber *)latitude
                   longitude:(NSNumber *)longitude
{
    BOOL wasUpdated = NO;
    
    if ((title) && (![self.title isEqualToString:title])) {
        self.title = title;
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


#pragma mark - Delete methods

- (void)deletePhoto
{
    // Any cached images in the App Sandbox should be removed before deleting the object.
    
    NSManagedObjectContext *context = self.managedObjectContext;

    [context deleteObject:self];
    
    NSError *error;
    if (![context save:&error]) {
        ALog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
