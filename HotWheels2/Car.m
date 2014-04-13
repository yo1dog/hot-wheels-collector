//
//  Car.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "Car.h"
#import "HotWheels2API.h"
#import "ImageBank.h"

@implementation Car

- (id)init:(NSDictionary *)jsonObject
{
	self._id                 = [jsonObject objectForKey:@"id"];
	self.vehicleID           = [jsonObject objectForKey:@"vehicleID"];
	self.name                = [jsonObject objectForKey:@"name"];
	self.toyNumber           = [jsonObject objectForKey:@"toyNumber"];
	self.segment             = [jsonObject objectForKey:@"segment"];
	self.series              = [jsonObject objectForKey:@"series"];
	self.make                = [jsonObject objectForKey:@"make"];
	self.color               = [jsonObject objectForKey:@"color"];
	self.style               = [jsonObject objectForKey:@"style"];
	self.numUsersCollected   = [jsonObject objectForKey:@"numUsersCollected"];
	self.isCustom            = [(NSNumber *)[jsonObject objectForKey:@"isCustom"] isEqualToNumber:[NSNumber numberWithInt:1]];
	self.customToyNumber     = [jsonObject objectForKey:@"customToyNumber"];
	self.distinguishingNotes = [jsonObject objectForKey:@"distinguishingNotes"];
	self.barcodeData         = [jsonObject objectForKey:@"barcodeData"];
	
	self.iconImageURL   = [jsonObject objectForKey:@"imageURL"];
	self.detailImageURL = [jsonObject objectForKey:@"detailImageURL"];
	
	self.owned = [(NSNumber *)[jsonObject objectForKey:@"owned"] isEqualToNumber:[NSNumber numberWithInt:1]];
	
	
	if (self.vehicleID == (id)[NSNull null])
		self.vehicleID = nil;
	if (self.toyNumber == (id)[NSNull null])
		self.toyNumber = nil;
	if (self.numUsersCollected == (id)[NSNull null])
		self.numUsersCollected = nil;
	if (self.customToyNumber == (id)[NSNull null])
		self.customToyNumber = nil;
	if (self.distinguishingNotes == (id)[NSNull null])
		self.distinguishingNotes = nil;
	if (self.barcodeData == (id)[NSNull null])
		self.barcodeData = nil;
	
	if (self.iconImageURL == (id)[NSNull null])
		self.iconImageURL = nil;
	if (self.detailImageURL == (id)[NSNull null])
		self.detailImageURL = nil;
	
	if (!self.iconImageURL)
		self.iconImage = [ImageBank getCarError];
	else
		self.iconImage = [HotWheels2API getImageFromCache:self._id imageIsDetails:false];
	
	if (!self.detailImageURL)
		self.detailImage = [ImageBank getCarError];
	else
		self.detailImage = [HotWheels2API getImageFromCache:self._id imageIsDetails:true];
	
	return self;
}
@end