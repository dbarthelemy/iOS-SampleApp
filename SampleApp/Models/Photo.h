//
//  Photo.h
//  SampleApp
//
//  Created by David Barthelemy on 13/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Station;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSData * photoBookmark;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * thumbnailBookmark;
@property (nonatomic, retain) Station *station;

@end
