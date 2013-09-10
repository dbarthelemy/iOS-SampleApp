//
//  DetailViewController.h
//  TagTheTram
//
//  Created by David Barthelemy on 09/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Station.h"

@interface PhotosViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (retain, nonatomic) Station *theStation;

@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
