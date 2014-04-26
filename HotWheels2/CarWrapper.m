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
	int oldOwnedTimestamp = self.car.ownedTimestamp;
	self.car = car;
	
	// set the timestamp to the old value if we are in the middle of an update
	if (self.getSetCarOwnedInProgress)
		self.car.ownedTimestamp = oldOwnedTimestamp;
	
	[self notifyListeners];
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
	
	[self checkForRelease];
}

- (void)checkForRelease
{
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

- (void)setCarOwned:(NSString *)userID
{
	[self setCarOwned:userID completionHandler:nil];
}
- (void)setCarOwned:(NSString *)userID completionHandler:(void (^)(HotWheels2APIError *error, bool setCarOwnedInProgress, bool alreadyOwned))handler
{
	// dont do anything if we are already setting the ownership
	if (self.setCarOwnedInProgress)
	{
		if (handler)
			handler(nil, true, false);
		
		return;
	}
	
	self.setCarOwnedInProgress = true;
	
	// tell the listeners we are now setting the ownership
	[self notifyListeners];
	
	// set the ownership with HW2 API
	[HotWheels2API setCarOwned:userID carID:self.car._id completionHandler:^(HotWheels2APIError *error, int ownedTimestamp, bool alreadyOwned)
	{
		self.setCarOwnedInProgress = false;
		
		if (error)
		{
			if (handler)
				handler(error, false, false);
			else
				[[error createAlert:@"Unable to add Car" withMessagePrefix:[NSString stringWithFormat:@"Failed to add %@ to your collection because of the following error:", self.car.name]] show];
		}
		else
			self.car.ownedTimestamp = ownedTimestamp;
		
		// tell the listerners we are done setting the ownership
		[self notifyListeners];
		
		if (handler)
			handler(nil, false, alreadyOwned);
	}];
}

- (void)setCarUnowned:(NSString *)userID
{
	// dont do anything if we are already setting the ownership
	if (self.setCarOwnedInProgress)
		return;
	
	self.setCarOwnedInProgress = true;
	
	// tell the listeners we are now setting the ownership
	[self notifyListeners];
	
	[HotWheels2API setCarUnowned:userID carID:self.car._id completionHandler:^(HotWheels2APIError *error)
	{
		self.setCarOwnedInProgress = false;
		
		if (error)
			[[error createAlert:@"Unable to add Car" withMessagePrefix:[NSString stringWithFormat:@"Failed to remove %@ from your collection because of the following error:", self.car.name]] show];
		else
			self.car.ownedTimestamp = -1;
		
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
