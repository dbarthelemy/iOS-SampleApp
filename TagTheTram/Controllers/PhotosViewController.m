//
//  PhotosViewController.m
//  TagTheTram
//
//  Created by David Barthelemy on 09/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "PhotosViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "PhotoPreviewViewController.h"
#import "Photo+CRUD.h"

@interface PhotosViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
- (void)configureView;
@end

@implementation PhotosViewController

- (void)dealloc
{
    [_fetchedResultsController release];
    [_managedObjectContext release];
    [_theStation release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)configureView
{
    if (self.theStation) {
        self.title = self.theStation.name;
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Custom Getter/Setter

- (void)setTheStation:(Station *)theStation
{
    if (_theStation != theStation) {
        [_theStation release];
        _theStation = [theStation retain];

        // Update the view.
        [self configureView];
    }
}


#pragma mark - IBAction methods

- (IBAction)addPhotoAction:(UIBarButtonItem *)sender
{
    [self startCameraControllerFromViewController:self
                                    usingDelegate:self];
}


#pragma mark - Table View

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}


#pragma mark - Storyboard methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showPhoto"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Photo *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setThePhoto:object];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set predicate
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"station.remoteId like[cd] %@", self.theStation.remoteId]];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES] autorelease];
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
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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
    Photo *aPhoto = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [aPhoto.title length] ? aPhoto.title : @"Photo sans titre";
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
            // Retrieve Metadata
            NSDictionary *originalMetadata = (NSDictionary *)[info objectForKey:UIImagePickerControllerMediaMetadata];

            // Save the new image (original or edited) to the Camera Roll
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

            [library writeImageToSavedPhotosAlbum:imageToSave.CGImage metadata:originalMetadata completionBlock:^(NSURL* assetURL, NSError* error) {
                if (error.code == 0) {
                    DLog(@"Photo URL: %@", assetURL);
                    
                    [Photo addPhotoWithAssetUrl:assetURL
                                      timeStamp:[NSDate date]
                                          title:nil
                                       latitude:nil
                                      longitude:nil
                                        station:self.theStation];
                }
                else {
                    DLog(@"Photo saved failled with error: %@", [error localizedDescription]);
                    
                    UIAlertView *saveAlert = [[UIAlertView alloc] initWithTitle:@"Erreur"
                                                                        message:@"Sauvegarde impossible"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Ok"
                                                              otherButtonTitles:nil];
                    [saveAlert show];
                    [saveAlert release];
                }
            }];
        }
    }
        
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [picker release];
}

@end
