//
//  CarWrapper.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/17/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "CarWrapper.h"
#import "CarWrapperListenerDelegate.h"
#import "CarWrapperUpdatedEvent.h"
#import "CarWrapperListener.h"
#import "CarManager.h"
#import "HotWheels2API.h"
#import "ImageBank.h"

@interface CarWrapper ()
@property bool downloadCarIconImageInProgress;
@property bool downloadCarDetailImageInProgress;
@property bool setCarOwnedInProgress;

@property (nonatomic, strong) NSMutableArray *listeners;
@end


@implementation CarWrapper

- (bool)getDownloadCarIconImageInProgress   { return self.downloadCarIconImageInProgress; }
- (bool)getDownloadCarDetailImageInProgress { return self.downloadCarDetailImageInProgress; }
- (bool)getSetCarOwnedInProgress            { return self.setCarOwnedInProgress; }


- (id)init:(Car *) car
{
	self = [super init];
	
	self.car = car;
	self.listeners = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)update:(Car *) car
{
	
	if (!self.getSetCarOwnedInProgress)
	{
		if (self.car.owned != car.owned)
		{
			self.car.owned = car.owned;
			[self notifyListeners];
		}
	}
}



- (void)registerListenerDelegate:(id<CarWrapperListenerDelegate>) listenerDelegate
{
	for (CarWrapperListener *listener in self.listeners)
	{
		if (listener.listenerDelegate == listenerDelegate)
			return;
	}
	
	[self.listeners addObject:[[CarWrapperListener alloc] initWithListenerDelegate:listenerDelegate]];
}

- (void)unregisterListenerDelegate:(id<CarWrapperListenerDelegate>) listenerDelegate
{
	for (CarWrapperListener *listener in self.listeners)
	{
		if (listener.listenerDelegate == listenerDelegate)
		{
			[self.listeners removeObject:listener];
			break;
		}
	}
	
	if (self.listeners.count == 0)
		[CarManager releaseCarWrapper:self];
}



- (void)downloadCarIconImage
{
	// dont do anything if we are already downloading
	if (self.downloadCarIconImageInProgress)
		return;
	
	// dont download if we dont have a URL
	if (!self.car.iconImageURL)
		return;
	
	self.downloadCarIconImageInProgress = true;
	
	// tell the listeners we are now downlaoding the image
	[self notifyListeners];
	
	// get the image from HW2 API
	[HotWheels2API getImage:self.car.iconImageURL
			  imageCacheKey:self.car._id
			 imageIsDetails:false
		  completionHandler:^(HotWheels2APIError *error, UIImage *image, bool wasCached)
	{
		self.downloadCarIconImageInProgress = false;
		
		self.car.iconImage = error ? [ImageBank getCarError] : image;
		
		// tell the listerners we are done downloading the image
		[self notifyListeners:CWUE_DoneDownloadingIconImage];
	}];
}


- (void)downloadCarDetailImage
{
	// dont do anything if we are already downloading
	if (self.downloadCarDetailImageInProgress)
		return;
	
	// dont download if we dont have a URL
	if (self.car.detailImageURL == NULL)
		return;
	
	self.downloadCarDetailImageInProgress = true;
	
	// tell the listeners we are now downloading the image
	[self notifyListeners];
	
	// get the image from HW2 API
	[HotWheels2API getImage:self.car.detailImageURL
			  imageCacheKey:self.car._id
			 imageIsDetails:true
		  completionHandler:^(HotWheels2APIError *error, UIImage *image, bool wasCached)
	 {
		 self.downloadCarDetailImageInProgress = false;
		 
		 self.car.detailImage = error ? [ImageBank getCarError] : image;
		 
		 // tell the listerners we are done downloading the image
		 [self notifyListeners:CWUE_DoneDownloadingDetailImage];
	 }];
}


- (void)setCarOwned:(NSString *) userID owned:(bool) owned
{
	// dont do anything if we are already setting the ownership
	if (self.setCarOwnedInProgress)
		return;
	
	self.setCarOwnedInProgress = true;
	
	// tell the listeners we are now setting the ownership
	[self notifyListeners];
	
	// set the ownership with HW2 API
	[HotWheels2API setCarOwned:userID carID:self.car._id owned:owned completionHandler:^(HotWheels2APIError *error)
	{
		self.setCarOwnedInProgress = false;
		
		if (error)
			[[error createAlert:@"Unable to add Car" withMessagePrefix:[NSString stringWithFormat:@"Failed to add %@ to your collection because of the following error:", self.car.name]] show];
		else
			self.car.owned = owned;
		
		// tell the listerners we are done setting the ownership
		[self notifyListeners];
	}];
}



- (void)notifyListeners
{
	[self notifyListeners: CWUE_Other];
}
- (void)notifyListeners: (CarWrapperUpdatedEvent) event
{
	for (CarWrapperListener *listener in self.listeners)
		[listener notify:self withEvent:event];
}
@end
