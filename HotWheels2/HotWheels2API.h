//
//  HotWheels2API.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HotWheels2APIErrors.h"
#import "Car.h"
#import "Car.h"

@interface HotWheels2API : NSObject

+ (void)   search:(NSString *) query
		   userID:(NSString *) userID
			 page:(int)        page
completionHandler:(void (^)(HotWheels2APIError *error, NSMutableArray *cars, int numPages)) handler;

+ (void)getCollection:(NSString *) userID
	completionHandler:(void (^)(HotWheels2APIError *error, NSMutableArray *cars)) handler;

+ (void)getCollectionRemovals:(NSString *) userID
			completionHandler:(void (^)(HotWheels2APIError *error, NSMutableArray *cars)) handler;

+ (void)getCarFromQRCode:(NSString *) qrCodeData
				  userID:(NSString *) userID
	   completionHandler:(void (^)(HotWheels2APIError *error, Car *car)) handler;

+ (void)setCarOwned:(NSString *) userID
			  carID:(NSString *) carID
			  owned:(bool)       owned
  completionHandler:(void (^)(HotWheels2APIError *error)) handler;

+ (void)setCarOwnedFromQRCode:(NSString *) userID
				   qrCodeData:(NSString *) qrCodeData
						owned:(bool)       owned
			completionHandler:(void (^)(HotWheels2APIError *error, NSString *carName, bool ownedChanged)) handler;

+ (void) getImage:(NSString *) urlStr
	imageCacheKey:(NSString *) imageCacheKey
   imageIsDetails:(bool)       imageIsDetails
completionHandler:(void (^)(HotWheels2APIError *error, UIImage *image, bool wasCached)) handler;

+ (void)addCustomCar:(Car *)      car
			  userID:(NSString *) userID
	 addToCollection:(bool)       addToCollection
   completionHandler:(void (^)(HotWheels2APIError *error)) handler;
@end