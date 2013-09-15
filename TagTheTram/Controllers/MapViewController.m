//
//  MapViewController.m
//  TagTheTram
//
//  Created by David Barthelemy on 14/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "PhotosViewController.h"
#import "Station+CRUD.h"

@interface MapViewController () <NSFetchedResultsControllerDelegate, MKMapViewDelegate>
@property (retain, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (retain, nonatomic) IBOutlet MKMapView *stationMapView;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_fetchedResultsController release];
    [_managedObjectContext release];
    [_stationMapView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    MKCoordinateRegion initialRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(43.610873, 3.876704),
                                                              MKCoordinateSpanMake(0.02, 0.02));
    [self.stationMapView setRegion:initialRegion animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Add annotations
    [self.stationMapView addAnnotations:self.fetchedResultsController.fetchedObjects];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.stationMapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
    self.stationMapView.showsUserLocation = NO;
}

- (void)viewDidUnload {
    [self setStationMapView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction methods

- (IBAction)done:(UIBarButtonItem *)sender
{
    [self.delegate mapViewControllerDidFinish:self];
}

- (IBAction)showUserLocationAction:(UIBarButtonItem *)sender
{
    [self.stationMapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}


#pragma mark - Storyboard methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showStation"]) {
        Station *aStation = [(MKAnnotationView *)sender annotation];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setTheStation:aStation];
    }
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
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil] autorelease];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.stationMapView addAnnotation:anObject];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.stationMapView removeAnnotation:anObject];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.stationMapView removeAnnotation:anObject];
            [self.stationMapView addAnnotation:anObject];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.stationMapView removeAnnotation:anObject];
            [self.stationMapView addAnnotation:anObject];
            break;
    }
}


#pragma mark - MKMapViewDelegate Protocol

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
	}
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[Station class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView* pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"StationPinAnnotationView"];
		
        if (!pinView) {
            // If an existing pin view was not available, create one.
			pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
													   reuseIdentifier:@"StationPinAnnotationView"] autorelease];
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
			
            // Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
        }
        else {
            pinView.annotation = annotation;
		}
        
        // Use the color to inform the user about photo availability
        if ([[(Station *)annotation photos] count] == 0) {
            pinView.pinColor = MKPinAnnotationColorGreen;
        }
        else {
            pinView.pinColor = MKPinAnnotationColorRed;
        }
        
        return pinView;
    }
	
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"showStation" sender:view];
}

@end
