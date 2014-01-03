//
//  MapViewController.h
//  SampleApp
//
//  Created by David Barthelemy on 14/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"

@protocol MapViewControllerDelegate;

@interface MapViewController : UIViewController
@property (assign, nonatomic) id <MapViewControllerDelegate> delegate;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) Station *station;

@end

@protocol MapViewControllerDelegate
- (void)mapViewControllerDidFinish:(MapViewController *)controller;
@end
