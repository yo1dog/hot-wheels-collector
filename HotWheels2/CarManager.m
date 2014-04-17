//
//  CarManager.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/20/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "CarManager.h"

@implementation CarManager

static NSMutableDictionary *carWrappers;



+ (void)initialize
{
	[super initialize];
	
	carWrappers = [[NSMutableDictionary alloc] init];
}


+ (CarWrapper *)getCarWrapper:(Car *) car
{
	CarWrapper *carWrapper = [carWrappers valueForKey:car._id];
	
	if (!carWrapper)
	{
		carWrapper = [[CarWrapper alloc] init:car];
		
		[carWrappers setValue:carWrapper forKey:car._id];
	}
	else
	{
		// update the local copy with the one we got from HW2
		[carWrapper update:car];
	}
	
	return carWrapper;
}


// should only be called from CarWrapper
+ (void)releaseCarWrapper:(CarWrapper *) carWrapper
{
	[carWrappers removeObjectForKey:carWrapper.car._id];
}

@end
