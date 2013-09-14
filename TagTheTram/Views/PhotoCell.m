//
//  PhotoCell.m
//  TagTheTram
//
//  Created by David Barthelemy on 14/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import "PhotoCell.h"

@implementation PhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_thumbnailImageView release];
    [_titleLabel release];
    [_timestampLabel release];
    [_inputTitleTextField release];
    [super dealloc];
}


#pragma mark - Public methods

- (void)showInputTitleTextField
{
    self.titleLabel.hidden = YES;
    self.inputTitleTextField.hidden = NO;
    self.inputTitleTextField.enabled = YES;
}

- (void)showTitleLabel
{
    self.inputTitleTextField.enabled = NO;
    self.inputTitleTextField.hidden = YES;
    self.titleLabel.hidden = NO;
}

@end
