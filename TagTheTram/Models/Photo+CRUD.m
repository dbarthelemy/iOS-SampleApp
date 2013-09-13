//
//  Photo+CRUD.m
//  TagTheTram
//
//  Created by David Barthelemy on 11/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "Photo+CRUD.h"
#import "AppDelegate.h"
#import "UIImage+Additions.h"

@interface Photo (CRUD_Private)
// URL persitence
+ (NSData*)bookmarkForURL:(NSURL*)url;
+ (NSURL*)urlForBookmark:(NSData*)bookmark;
// Photo persistence
+ (NSURL *)urlForSavedPhotoUsingImage:(UIImage *)image date:(NSDate *)date;
+ (NSURL *)urlForSavedThumbnailUsingImage:(UIImage *)image date:(NSDate *)date;
+ (NSURL *)urlForSavedImage:(UIImage *)image usingDate:(NSDate *)date suffixName:(NSString *)suffix;
@end

@implementation Photo (CRUD_Private)

+ (NSData*)bookmarkForURL:(NSURL*)url
{
    if (!url) {
        return nil;
    }
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

+ (NSURL*)urlForBookmark:(NSData*)bookmark
{
    if (!bookmark) {
        return nil;
    }
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

+ (NSURL *)urlForSavedPhotoUsingImage:(UIImage *)image date:(NSDate *)date
{
    return [Photo urlForSavedImage:image usingDate:date suffixName:@"Photo"];
}

+ (NSURL *)urlForSavedThumbnailUsingImage:(UIImage *)image date:(NSDate *)date
{
    UIImage *thumbnail = [image resizeCroppedImageToWidth:kMediaThumbnailWidth height:kMediaThumbnailHeight];
    
    return [Photo urlForSavedImage:thumbnail usingDate:date suffixName:@"Thumbnail"];
}

+ (NSURL *)urlForSavedImage:(UIImage *)image usingDate:(NSDate *)date suffixName:(NSString *)suffix
{
    NSURL *savedUrl = nil;
    
    NSData *imageRepresentation = UIImageJPEGRepresentation(image, 1.0);
    if (imageRepresentation) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *filename = [NSString stringWithFormat:@"%@-%@", [dateFormatter stringFromDate:date], suffix];
        [dateFormatter release];
        
        NSURL *baseUrl = [NSURL URLWithString:filename relativeToURL:[(AppDelegate *)[[UIApplication sharedApplication] delegate] applicationMediasDirectory]];
        NSURL *targetUrl = [NSURL URLWithString:filename relativeToURL:baseUrl];
        NSURL *targetUrlWithExt = [targetUrl URLByAppendingPathExtension:@"jpg"];
        
        if ([imageRepresentation writeToURL:targetUrlWithExt atomically:YES]) {
            savedUrl = targetUrlWithExt;
        }
    }
    
    return savedUrl;
}

@end

@implementation Photo (CRUD)

#pragma mark - Create methods

+ (Photo *)addPhotoWithImage:(UIImage *)image
                   timeStamp:(NSDate *)timeStamp
                       title:(NSString *)title
                     station:(Station *)station
{
    // Use the main CodeData context
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    return [Photo addPhotoWithImage:image
                          timeStamp:timeStamp
                              title:title
                            station:station
             inManagedObjectContext:context];
}

+ (Photo *)addPhotoWithImage:(UIImage *)image
                   timeStamp:(NSDate *)timeStamp
                       title:(NSString *)title
                     station:(Station *)station
      inManagedObjectContext:(NSManagedObjectContext *)context
{
    if (!image) {
        ALog(@"image is nil");
        return nil;
    }
    if (!station) {
        ALog(@"station is nil");
        return nil;
    }
    
    NSURL *photoUrl = [Photo urlForSavedPhotoUsingImage:image date:timeStamp];
    NSData *photoBookmark = [Photo bookmarkForURL:photoUrl];
    if (!photoBookmark) {
        ALog(@"Photo cannot be saved");
        return nil;
    }
    
    NSEntityDescription *entityDescriptor = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
    Photo *photo = [[[Photo alloc] initWithEntity:entityDescriptor insertIntoManagedObjectContext:context] autorelease];
    
    // Initialize attributes
    photo.photoBookmark = photoBookmark;
    photo.timeStamp = timeStamp ? timeStamp : [NSDate date];
    photo.title = title ? title : @"";
    photo.thumbnailBookmark = nil;
    
    // Initialize relationships
    photo.station = station;
    
    NSError *error = nil;
    if (![context save:&error]) {
        ALog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    // Prepare the Thumbnail in background
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSURL *thumbnailUrl = [Photo urlForSavedThumbnailUsingImage:image date:timeStamp];
        if (thumbnailUrl) {
            dispatch_async(dispatch_get_main_queue() , ^{
                [photo updatePhotoWithTitle:nil thumbnailUrl:thumbnailUrl];
            });
        }
        else {
            ALog(@"Thumbnail cannot be created");
        }
    });
    
    return photo;
}


#pragma mark - Read & QLPreviewItem protocol methods

- (NSURL *)thumbnailURL
{
    return [Photo urlForBookmark:self.thumbnailBookmark];
}

- (NSURL *)photoURL
{
    return [Photo urlForBookmark:self.photoBookmark];
}

- (NSString *)previewItemTitle
{
    return ([self.title length] > 0) ? self.title : [NSDateFormatter localizedStringFromDate:self.timeStamp
                                                                                   dateStyle:NSDateFormatterShortStyle
                                                                                   timeStyle:NSDateFormatterShortStyle];
}

- (NSURL *)previewItemURL
{
    return [self photoURL];
}


#pragma mark - Update methods

- (BOOL)updatePhotoWithTitle:(NSString *)title
                thumbnailUrl:(NSURL *)thumbnailUrl
{
    BOOL wasUpdated = NO;
    
    if ((title) && (![self.title isEqualToString:title])) {
        self.title = title;
        wasUpdated = YES;
    }
    
    NSData *bookmark = [Photo bookmarkForURL:thumbnailUrl];
    if ((bookmark) && (![bookmark isEqualToData:self.thumbnailBookmark])) {
        self.thumbnailBookmark = bookmark;
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
    NSManagedObjectContext *context = self.managedObjectContext;

    if (self.photoBookmark) {
        NSURL *photoUlr = [Photo urlForBookmark:self.photoBookmark];
        if ([photoUlr isFileURL]) {
            NSError *error = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:photoUlr error:&error]) {
                ALog(@"%@", error.localizedDescription);
            }
        }
    }

    if (self.thumbnailBookmark) {
        NSURL *thumbnailUlr = [Photo urlForBookmark:self.thumbnailBookmark];
        if ([thumbnailUlr isFileURL]) {
            NSError *error = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:thumbnailUlr error:&error]) {
                ALog(@"%@", error.localizedDescription);
            }
        }
    }
    
    [context deleteObject:self];
    
    NSError *error;
    if (![context save:&error]) {
        ALog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
