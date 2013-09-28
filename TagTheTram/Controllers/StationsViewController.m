//
//  StationsViewController.m
//  TagTheTram
//
//  Created by David Barthelemy on 09/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "StationsViewController.h"
#import "PhotosViewController.h"
#import "Station+CRUD.h"
#import "StationWebService.h"
#import "MapViewController.h"

@interface StationsViewController () <NSFetchedResultsControllerDelegate, StationWebServiceDelegate, UIAlertViewDelegate, MapViewControllerDelegate, UISearchDisplayDelegate>
@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) UIAlertView *networkAlertView;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation StationsViewController

- (void)dealloc
{
    [[StationWebService sharedInstance] setDelegate:nil];
    
    [_fetchedResultsController release];
    [_managedObjectContext release];
    [_networkAlertView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[StationWebService sharedInstance] setDelegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
        });
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.networkAlertView) {
        [self.networkAlertView dismissWithClickedButtonIndex:[self.networkAlertView cancelButtonIndex] animated:YES];
        self.networkAlertView = nil;
    }
    [super viewWillDisappear:animated];
}


#pragma mark - UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"showStation" sender:nil];
    }
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StationCell" forIndexPath:indexPath]; // iOS6 only
    static NSString *CellIdentifier = @"StationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo name];
    } else
        return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}


#pragma mark - Storyboard methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showStation"]) {
        NSIndexPath *indexPath;
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            indexPath = [self.tableView indexPathForCell:sender];
        }
        else {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        }
        Station *aStation = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setTheStation:aStation];
    }
    else if ([[segue identifier] isEqualToString:@"showMap"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        MapViewController *destinationViewController = (MapViewController *)navigationController.topViewController;

        [destinationViewController setDelegate:self];
        [destinationViewController setManagedObjectContext:self.managedObjectContext];
    }
}


#pragma mark - MapViewControllerDelegate protocol

- (void)mapViewControllerDidFinish:(MapViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Station" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Pre-fetching photos
    [fetchRequest setRelationshipKeyPathsForPrefetching:@[@"photos"]];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                 managedObjectContext:self.managedObjectContext
                                                                                                   sectionNameKeyPath:@"sectionIndex"
                                                                                                            cacheName:nil] autorelease];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    ALog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Station *aStation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = aStation.name;
    cell.detailTextLabel.text = [aStation photoCounterString];
}


#pragma mark - StationWebServiceDelegate Protocol

- (void)fetchStationsDidSucceed
{
    // To fix minor UI glitch on the iniital cell prior indexes were inserted in the Table View during the initial data fetch.
    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)fetchStationsDidFailedWithError:(NSError *)error
{
    ALog(@"Error from the Web Service: %@", error.localizedDescription);
    
    if (([[self.fetchedResultsController fetchedObjects] count] == 0) && (!self.networkAlertView)) {
        // Notify the user about the network error only if the list is empty
        UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:@"Erreur"
                                                          message:@"Récupération de la liste impossible"
                                                         delegate:self
                                                cancelButtonTitle:@"Annuler"
                                                otherButtonTitles:@"Réessayer", nil];
        self.networkAlertView = anAlert;
        [anAlert show];
        [anAlert release];
    }
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.networkAlertView) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            // Retry
            [[StationWebService sharedInstance] fetchStations];
        }
        self.networkAlertView = nil;
    }
}


#pragma mark - UISearchDisplayDelegate protocol

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentUsingSearchDisplayController:controller];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentUsingSearchDisplayController:controller];
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self filterContentUsingSearchDisplayController:nil];
}


#pragma mark - UISearchDisplayDelegate protocol helper methods

- (void)filterContentUsingSearchDisplayController:(UISearchDisplayController *)controller
{
    NSString *query = controller.searchBar.text;
    if ((query) && ([query length] > 0)) {
        NSPredicate *predicate;
        if (controller.searchBar.selectedScopeButtonIndex == 0) {
            predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", query];
        }
        else {
            predicate = [NSPredicate predicateWithFormat:@"photos.@count > 0 AND name contains[cd] %@", query];
        }
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    else {
        [self.fetchedResultsController.fetchRequest setPredicate:nil];
    }
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
	    ALog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
    }
}

@end
