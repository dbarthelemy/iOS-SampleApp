//
//  StationsViewController.h
//  SampleApp
//
//  Created by David Barthelemy on 09/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MapViewController.h"

@interface StationsViewController : UITableViewController
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign, nonatomic) MapViewController *mapViewController;
@property (retain, nonatomic) UIPopoverController *presentedInPopoverController;
@property (retain, nonatomic) UIBarButtonItem *popoverControllerPresenter;

- (void)presentPhotosForStation:(Station *)station;
@end
