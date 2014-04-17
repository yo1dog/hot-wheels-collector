//
//  ImageBank.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/19/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageBank : NSObject

+ (UIImage *)getBadgeOwned;
+ (UIImage *)getBadgeUnowned;
+ (UIImage *)getCarError;

@end