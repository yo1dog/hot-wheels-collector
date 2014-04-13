//
//  CarWrapperListener.m
//  HotWheels 2.0
//
//  Created by Mike on 4/12/14.
//  Copyright (c) 2014 Mike. All rights reserved.
//

#import "CarWrapperListener.h"
#import "CarWrapperUpdatedEvent.h"

@implementation CarWrapperListener
- (id)initWithListenerDelegate:(id<CarWrapperListenerDelegate>) listenerDelegate
{
	self = [self init];
	
	self.listenerDelegate = listenerDelegate;
	
	return self;
}

- (void)notify:(CarWrapper *)carWrapper
{
	[self notify:carWrapper withEvent:CWUE_Other];
}
- (void)notify:(CarWrapper *)carWrapper withEvent: (CarWrapperUpdatedEvent) event
{
	[self.listenerDelegate carWrapperUpdated:carWrapper event:event];
}
@end
