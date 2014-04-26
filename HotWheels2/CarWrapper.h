//
//  CarWrapper.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/17/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Car.h"
#import "HotWheels2APIErrors.h"
#import "CarWrapperListenerDelegate.h"


@interface CarWrapper : NSObject
@property (nonatomic, strong) Car *car;

- (bool)getDownloadCarIconImageInProgress;
- (bool)getDownloadCarDetailImageInProgress;
- (bool)getSetCarOwnedInProgress;

- (id)init:(Car *) car;
- (void)update:(Car *) car;

- (void)registerListenerDelegate:(id<CarWrapperListenerDelegate>) listenerDelegate;
- (void)unregisterListenerDelegate:(id<CarWrapperListenerDelegate>) listenerDelegate;
- (void)checkForRelease;

- (void)downloadCarIconImage;
- (void)downloadCarDetailImage;

- (void)setCarOwned:(NSString *) userID;
- (void)setCarOwned:(NSString *) userID
  completionHandler:(void (^)(HotWheels2APIError *error, bool setCarOwnedInProgress, bool alreadyOwned)) handler;

- (void)setCarUnowned:(NSString *) userID;
@end
