//
//  Car.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Car : NSObject
@property (nonatomic, strong) NSString *_id;
@property (nonatomic, strong) NSString *vehicleID;           // nullable
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *toyNumber;           // nullable
@property (nonatomic, strong) NSString *segment;             // can be empty
@property (nonatomic, strong) NSString *series;              // can be empty
@property (nonatomic, strong) NSString *make;                // can be empty
@property (nonatomic, strong) NSString *color;               // can be empty
@property (nonatomic, strong) NSString *style;               // can be empty
@property (nonatomic, strong) NSNumber *numUsersCollected;   // nullable
@property                     bool      isCustom;
@property (nonatomic, strong) NSString *customToyNumber;     // nullable
@property (nonatomic, strong) NSString *distinguishingNotes; // nullable
@property (nonatomic, strong) NSString *barcodeData;         // nullable
@property                     int       ownedTimestamp;

@property (nonatomic, strong) NSString *iconImageURL;        // nullable
@property (nonatomic, strong) NSString *detailImageURL;      // nullable

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImage *detailImage;

- (id) init:(NSDictionary *)jsonObject;

- (bool) isOwned;
@end