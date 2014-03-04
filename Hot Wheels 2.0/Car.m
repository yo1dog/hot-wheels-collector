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
	self._id               = [jsonObject objectForKey:@"id"];
	self.name              = [jsonObject objectForKey:@"name"];
	self.toyNumber         = [jsonObject objectForKey:@"toyNumber"];
	self.segment           = [jsonObject objectForKey:@"segment"];
	self.series            = [jsonObject objectForKey:@"series"];
	self.make              = [jsonObject objectForKey:@"make"];
	self.color             = [jsonObject objectForKey:@"color"];
	self.style             = [jsonObject objectForKey:@"style"];
	self.numUsersCollected = [jsonObject objectForKey:@"numUsersCollected"];
	self.iconImageURL          = [jsonObject objectForKey:@"imageURL"];
	self.detailImageURL    = [jsonObject objectForKey:@"detailImageURL"];
	
	self.owned = [(NSNumber *)[jsonObject objectForKey:@"owned"] isEqualToNumber:[NSNumber numberWithInt:1]];
	
	self.iconImage       = NULL;
	self.detailImage = NULL;
	
	return self;
}
@end