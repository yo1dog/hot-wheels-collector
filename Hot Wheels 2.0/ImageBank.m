//
//  ImageBank.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/19/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "ImageBank.h"

@implementation ImageBank

static UIImage *carError;
+ (UIImage *)getCarError
{
	if (!carError)
		carError = [UIImage imageNamed:@"carError"];
	
	return carError;
}

static UIImage *badgeOwned;
+ (UIImage *)getBadgeOwned
{
	if (!badgeOwned)
		badgeOwned = [UIImage imageNamed:@"badgeOwned"];
	
	return badgeOwned;
}

static UIImage *badgeUnowned;
+ (UIImage *)getBadgeUnowned
{
	if (!badgeUnowned)
		badgeUnowned = [UIImage imageNamed:@"badgeUnowned"];
	
	return badgeUnowned;
}

@end
