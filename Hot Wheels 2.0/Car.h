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
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *toyNumber;
@property (nonatomic, strong) NSString *segment;
@property (nonatomic, strong) NSString *series;
@property (nonatomic, strong) NSString *make;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *style;
@property (nonatomic, strong) NSNumber *numUsersCollected;
@property (nonatomic, strong) NSString *iconImageURL;
@property (nonatomic, strong) NSString *detailImageURL;

@property bool owned;

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) UIImage *detailImage;

@property (nonatomic, strong) NSString *barcode;
@property (nonatomic, strong) NSString *distinguishingNotes;

- (id) init:(NSDictionary *)jsonObject;
@end