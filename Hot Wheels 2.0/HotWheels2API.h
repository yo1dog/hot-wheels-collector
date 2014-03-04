//
//  HotWheels2API.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Car.h"

@interface HotWheels2API : NSObject

+ (void)   search:(NSString *)                                     query
		   userID:(NSString *)                                     userID
completionHandler:(void (^)(NSError *error, NSMutableArray *cars)) handler;

+ (void)getCollection:(NSString *) userID
			  handler:(void (^)(NSError *error, NSMutableArray *cars)) handler;

+ (void)getCollectionRemovals:(NSString *) userID
					  handler:(void (^)(NSError *error, NSMutableArray *cars)) handler;

+ (void)getCarFromQRCode:(NSString *) qrCodeData
				  userID:(NSString *) userID
				 handler:(void (^)(NSError *error, Car *car)) handler;

+ (void)setCarOwned:(NSString *)               userID
			  carID:(NSString *)               carID
			  owned:(bool)                     owned
  completionHandler:(void (^)(NSError *error)) handler;

+ (void) getImage:(NSString *) urlStr
	imageCacheKey:(NSString *) imageCacheKey
   imageIsDetails:(bool)       imageIsDetails
completionHandler:(void (^)(NSError* error, UIImage *image)) handler;

@end
