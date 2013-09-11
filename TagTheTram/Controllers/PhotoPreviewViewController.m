//
//  PhotoPreviewViewController.m
//  TagTheTram
//
//  Created by David Barthelemy on 11/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "PhotoPreviewViewController.h"

@interface PhotoPreviewViewController ()
- (void)configureView;
@end

@interface PhotoPreviewViewController ()

@end

@implementation PhotoPreviewViewController

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
    [_thePhoto release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    if (self.thePhoto) {
        self.title = self.thePhoto.title;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Custom Getter/Setter

- (void)setThePhoto:(Photo *)thePhoto
{
    if (_thePhoto != thePhoto) {
        [_thePhoto release];
        _thePhoto = [thePhoto retain];
        
        // Update the view.
        [self configureView];
    }
}


#pragma mark - IBAction methods


@end
