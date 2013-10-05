//
//  MapViewController.m
//  TagTheTram
//
//  Created by David Barthelemy on 14/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import "PhotosViewController.h"
#import "Station+CRUD.h"
#import "StationsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuickLook/QuickLook.h>
#import "Photo+CRUD.h"

#define kThumbnailTag 999

@interface MapViewController () <NSFetchedResultsControllerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate>
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }
    else {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskLandscape;
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
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


#pragma mark - Custom Getter/Setter

- (void)setStation:(Station *)station
{
    if (station != _station) {
        [_station release];
        _station = [station retain];
        
        [self.stationMapView setCenterCoordinate:station.coordinate animated:YES];
        [self.stationMapView selectAnnotation:station animated:YES];
    }
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
    else if ([[segue identifier] isEqualToString:@"showSearch"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        StationsViewController *destinationViewController = (StationsViewController *)navigationController.topViewController;
        [destinationViewController setMapViewController:self];
        [destinationViewController setManagedObjectContext:self.managedObjectContext];
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

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (view.leftCalloutAccessoryView != nil) {
        UIButton *showPhotosButton = (UIButton *)view.leftCalloutAccessoryView;
        UIImage *thumbnail = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[[(Station *)view.annotation photos] anyObject] thumbnailURL]]
                                              scale:[[UIScreen mainScreen] scale]];
        [showPhotosButton setImage:thumbnail forState:UIControlStateNormal];
    }
}

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
			
            // Add a detail disclosure or photo ass button to the callout.
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                pinView.rightCalloutAccessoryView = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
            }
            else {
                pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
            }
        }
        else {
            pinView.annotation = annotation;
		}
        
        // Use the color to inform the user about photo availability, present a thumbnail if any
        if ([[(Station *)annotation photos] count] == 0) {
            pinView.pinColor = MKPinAnnotationColorGreen;
            
            pinView.leftCalloutAccessoryView = nil;
        }
        else {
            pinView.pinColor = MKPinAnnotationColorRed;
            
            UIButton *showPhotosButton = [UIButton buttonWithType:UIButtonTypeCustom];
            showPhotosButton.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
            showPhotosButton.tag = kThumbnailTag;
            pinView.leftCalloutAccessoryView = showPhotosButton;
        }
        
        return pinView;
    }
	
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self performSegueWithIdentifier:@"showStation" sender:view];
    }
    else {
        self.station = view.annotation;
        
        if (([self.station.photos count] > 0) && (control.tag == kThumbnailTag)) {
            QLPreviewController *previewController = [[QLPreviewController alloc] init];
            previewController.dataSource = self;
            previewController.delegate = self;
            
            // start previewing the document at the current section index
            previewController.currentPreviewItemIndex = 0;
            
            [self presentViewController:previewController animated:YES completion:nil];
            [previewController release];
        }
        else {
            [self startCameraControllerFromViewController:self
                                            usingDelegate:self];
        }
    }
}


#pragma mark - Camera methods

- (BOOL) startCameraControllerFromViewController:(UIViewController*) controller
                                   usingDelegate:(id <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate>) delegate
{
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        ALog(@"Carema is unavailable");
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController:cameraUI animated:YES];
    
    return YES;
}


#pragma mark - UIImagePickerControllerDelegate methods

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [picker release];
}

// For responding to the user accepting a newly-captured picture
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info
{
    NSDate *timestamp = [NSDate date];
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            // Original size
            CGSize originalImageSize = originalImage.size;
            CGRect originalImageRect = CGRectMake(0.0, 0.0, originalImageSize.width, originalImageSize.height);
            
            // Edited origin and size
            CGRect editedImageRect = [(NSValue *)[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
            
            // Check the edited size
            if (!CGRectContainsRect(editedImageRect, originalImageRect)) {
                imageToSave = editedImage;
            }
            else {
                imageToSave = originalImage;
            }
        }
        else {
            imageToSave = originalImage;
        }
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Save photo in App Sandbox
            Photo *aPhoto = [Photo addPhotoWithImage:imageToSave
                                           timeStamp:timestamp
                                               title:nil
                                             station:self.station];
            if (!aPhoto) {
                // Notify the user about the error
                UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Erreur"
                                                                    message:@"Sauvegarde impossible"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                [saveAlert show];
                [saveAlert release];
            }
        }
    }
    
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [picker release];
}


#pragma mark - QLPreviewControllerDataSource Protocol (iPad only)

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return [self.station.photos count];
}

- (id <QLPreviewItem>) previewController: (QLPreviewController *) controller previewItemAtIndex: (NSInteger) index
{
    NSOrderedSet *photos = [NSOrderedSet orderedSetWithSet:self.station.photos];
    Photo *object = [photos objectAtIndex:index];
    
    return object;
}

@end
