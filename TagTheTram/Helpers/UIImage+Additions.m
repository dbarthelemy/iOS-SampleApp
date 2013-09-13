//
//  UIImage+Additions.m
//  TagTheTram
//
//  Created by David Barthelemy on 09/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "UIImage+Additions.h"
#import "UIImage+ProportionalFill.h"

@implementation UIImage (Additions)

- (UIImage*)resizeImageToFitInWidth:(NSInteger)width height:(NSInteger)height
{
    return [self resizeImageToFitInWidth:width height:height ignoreScale:NO];
}

- (UIImage*)resizeImageToFitInWidth:(NSInteger)width height:(NSInteger)height ignoreScale:(BOOL)ignoreScale
{
    CGSize scaledSize = CGSizeMake((CGFloat)width, (CGFloat)height);
    return [self imageToFitSize:scaledSize method:MGImageResizeScale ignoreScale:ignoreScale];
}

- (UIImage*)resizeCroppedImageToWidth:(NSInteger)width height:(NSInteger)height
{
    return [self resizeCroppedImageToWidth:width height:height ignoreScale:NO];
}

- (UIImage*)resizeCroppedImageToWidth:(NSInteger)width height:(NSInteger)height ignoreScale:(BOOL)ignoreScale
{
    CGSize scaledSize = CGSizeMake((CGFloat)width, (CGFloat)height);
    return [self imageToFitSize:scaledSize method:MGImageResizeCrop ignoreScale:ignoreScale];
}

- (UIImage *)cropImageUsingRect:(CGRect)rect
{
    CGAffineTransform rectTransform;
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -self.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -self.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -self.size.width, -self.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectApplyAffineTransform(rect, rectTransform));
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}
@end
