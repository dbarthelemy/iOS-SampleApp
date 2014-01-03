//
//  UIImage+Additions.h
//  SampleApp
//
//  Created by David Barthelemy on 09/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

//- (UIImage*)resizeImageToWidth:(NSInteger)width height:(NSInteger)height; // TODO
//- (UIImage*)resizeImageToWidth:(NSInteger)width height:(NSInteger)height ignoreScale:(BOOL)ignoreScale; // TODO

- (UIImage*)resizeImageToFitInWidth:(NSInteger)width height:(NSInteger)height;
- (UIImage*)resizeImageToFitInWidth:(NSInteger)width height:(NSInteger)height ignoreScale:(BOOL)ignoreScale;

- (UIImage*)resizeCroppedImageToWidth:(NSInteger)width height:(NSInteger)height;
- (UIImage*)resizeCroppedImageToWidth:(NSInteger)width height:(NSInteger)height ignoreScale:(BOOL)ignoreScale;

- (UIImage *)cropImageUsingRect:(CGRect)rect;

@end
