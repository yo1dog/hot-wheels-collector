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

static CarManager *carManager = NULL;
+ (CarManager *)getSingleton
{
	if (!carManager)
		carManager = [[CarManager alloc] init];
	
	return carManager;
}




- (id)init
{
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
		// if we are not in the middle of an update, set owned
		if (!carWrapper.carSetOwnedRequesting)
		{
			if (carWrapper.car.owned != car.owned)
			{
				carWrapper.car.owned = car.owned;
				[carWrapper carUpdated];
			}
		}
	}
	
	return carWrapper;
}


- (void)checkForRemoval:(CarWrapper *) carWrapper
{
	if (!carWrapper.searchViewController &&
		!carWrapper.collectionViewController &&
		!carWrapper.collectionRemovalsViewController &&
		
		!carWrapper.searchDetailsViewController &&
		!carWrapper.collectionDetailsViewController &&
		!carWrapper.collectionRemovalsDetailsViewController &&
		!carWrapper.scannerDetailsViewController)
	{
		[self.carWrappers removeObjectForKey:carWrapper.car._id];
	}
}

@end
