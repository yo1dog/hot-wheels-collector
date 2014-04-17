//
//  ImageBank.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/19/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "ImageBank.h"

@implementation ImageBank

static UIImage *badgeOwned;
static UIImage *badgeUnowned;
static UIImage *carError;

+ (void)initialize
{
	[super initialize];
	
	badgeOwned   = [UIImage imageNamed:@"badgeOwned"];
	badgeUnowned = [UIImage imageNamed:@"badgeUnowned"];
	carError     = [UIImage imageNamed:@"carError"];
}


+ (UIImage *)getBadgeOwned
{
	return badgeOwned;
}
+ (UIImage *)getBadgeUnowned
{
	return badgeUnowned;
}
+ (UIImage *)getCarError
{
	return carError;
}

@end
