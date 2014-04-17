//
//  UserManager.h
//  HotWheels 2.0
//
//  Created by Mike on 12/25/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserManager : NSObject
+ (void)login:(NSString *)userID;
+ (NSString *)getLoggedInUserID;
@end
