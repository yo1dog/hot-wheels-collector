//
//  UserManager.m
//  HotWheels 2.0
//
//  Created by Mike on 12/25/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "UserManager.h"

@implementation UserManager
NSString *loggedInUserID;

+ (void)login:(NSString *)userID
{
	loggedInUserID = userID;
}

+ (NSString *)getLoggedInUserID
{
	return loggedInUserID;
}
@end
