//
//  Photo+CRUD.h
//  TagTheTram
//
//  Created by David Barthelemy on 11/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "Photo.h"
#import <QuickLook/QuickLook.h>

@interface Photo (CRUD) <QLPreviewItem>

// QLPreviewItem protocol
@property (readonly) NSString *previewItemTitle;
@property (readonly) NSURL *previewItemURL;

// Create
+ (Photo *)addPhotoWithImage:(UIImage *)image
                   timeStamp:(NSDate *)timeStamp
                       title:(NSString *)title
                    latitude:(NSNumber *)latitude
                   longitude:(NSNumber *)longitude
                     station:(Station *)station;

+ (Photo *)addPhotoWithImage:(UIImage *)image
                   timeStamp:(NSDate *)timeStamp
                       title:(NSString *)title
                    latitude:(NSNumber *)latitude
                   longitude:(NSNumber *)longitude
                     station:(Station *)station
      inManagedObjectContext:(NSManagedObjectContext *)context;

// Read (also refer to <QLPreviewItem>)
@property (readonly) NSURL *thumbnailURL;
@property (readonly) NSURL *photoURL;

// Update
- (BOOL)updatePhotoWithTitle:(NSString *)title
                    latitude:(NSNumber *)latitude
                   longitude:(NSNumber *)longitude
                thumbnailUrl:(NSURL *)thumbnailUrl;

// Delete
- (void)deletePhoto;

@end
