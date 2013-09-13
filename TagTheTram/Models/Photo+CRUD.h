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
                     station:(Station *)station;

+ (Photo *)addPhotoWithImage:(UIImage *)image
                   timeStamp:(NSDate *)timeStamp
                       title:(NSString *)title
                     station:(Station *)station
      inManagedObjectContext:(NSManagedObjectContext *)context;

// Read (also refer to <QLPreviewItem>)
@property (readonly) NSURL *thumbnailURL;
@property (readonly) NSURL *photoURL;

// Update
- (BOOL)updatePhotoWithTitle:(NSString *)title
                thumbnailUrl:(NSURL *)thumbnailUrl;

// Delete
- (void)deletePhoto;

@end
