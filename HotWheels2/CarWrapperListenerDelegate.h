//
//  CarWrapperListenerDelegate.h
//  HotWheels 2.0
//
//  Created by Mike on 4/10/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarWrapper.h"
#import "CarWrapperUpdatedEvent.h"

@class CarWrapper;

@protocol CarWrapperListenerDelegate
-(void) carWrapperUpdated:(CarWrapper *) carWrapper event:(CarWrapperUpdatedEvent) event;
@end
