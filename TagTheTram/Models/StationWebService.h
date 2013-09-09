//
//  StationWebService.h
//  TagTheTram
//
//  Created by David Barthelemy on 09/09/13.
//  Copyright (c) 2013 David Barthelemy, iMakeit4U. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kWebServiceAPIErrorDomain @"WebServiceAPIErrorDomain"

typedef enum WebServiceAPIErrorCode {
    DummyErrorCode         = 1,
    JSONParsingErrorCode   = 2,
} WebServiceAPIErrorCode;

@protocol StationWebServiceDelegate;

@interface StationWebService : NSObject

@property (nonatomic, assign) id <StationWebServiceDelegate> delegate;

+ (StationWebService *)sharedInstance;

- (BOOL)fetchStations;
- (BOOL)isRunning;

@end

@protocol StationWebServiceDelegate <NSObject>
@optional
- (void)fetchStationsDidSucceed;
- (void)fetchStationsDidFailedWithError:(NSError *)error;
@end