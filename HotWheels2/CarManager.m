//
//  CarManager.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/20/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "CarManager.h"

@interface CarManager ()
@property(nonatomic, strong) NSMutableDictionary *carWrappers;
@end


@implementation CarManager

static CarManager *carManager;
+ (CarManager *)getSingleton
{
	if (!carManager)
		carManager = [[CarManager alloc] init];
	
	return carManager;
}




- (id)init
{
	self = [super init];
	
	self.carWrappers = [[NSMutableDictionary alloc] init];
	
	return self;
}


- (CarWrapper *)getCarWrapper:(Car *) car
{
	CarWrapper *carWrapper = [self.carWrappers valueForKey:car._id];
	
	if (!carWrapper)
	{
		carWrapper = [[CarWrapper alloc] init:car];
		
		[self.carWrappers setValue:carWrapper forKey:car._id];
	}
	else
	{
		// update the local copy with the one we got from HW2
		[carWrapper update:car];
	}
	
	return carWrapper;
}


- (void)releaseCarWrapper:(CarWrapper *) carWrapper
{
	[self.carWrappers removeObjectForKey:carWrapper.car._id];
}

@end
