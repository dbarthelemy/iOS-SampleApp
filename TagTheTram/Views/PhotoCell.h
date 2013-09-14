//
//  PhotoCell.h
//  TagTheTram
//
//  Created by David Barthelemy on 14/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *timestampLabel;
@property (retain, nonatomic) IBOutlet UITextField *inputTitleTextField;

- (void)showInputTitleTextField;
- (void)showTitleLabel;

@end
