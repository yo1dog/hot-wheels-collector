//
//  CarWrapperListener.h
//  HotWheels 2.0
//
//  Created by Mike on 4/12/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarWrapper.h"
#import "CarWrapperListenerDelegate.h"

@interface CarWrapperListener : NSObject
@property(nonatomic, weak) id<CarWrapperListenerDelegate> listenerDelegate;

- (id)initWithListenerDelegate:(id<CarWrapperListenerDelegate>) listenerDelegate;

- (void)notify:(CarWrapper *)carWrapper;
- (void)notify:(CarWrapper *)carWrapper withEvent:(CarWrapperUpdatedEvent)event;
@end
