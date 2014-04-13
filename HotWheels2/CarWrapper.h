//
//  CarWrapper.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/17/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Car.h"
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

- (void)downloadCarIconImage;
- (void)downloadCarDetailImage;
- (void)setCarOwned:(NSString *) userID owned:(bool) owned;
@end
