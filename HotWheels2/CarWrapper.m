//
//  CarWrapper.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/17/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "CarWrapper.h"
#import "HotWheels2API.h"
#import "ImageBank.h"

@implementation CarWrapper

- (id)init:(Car *) car
{
	self.car = car;
	
	self.searchViewController             = NULL;
	self.collectionViewController         = NULL;
	self.collectionRemovalsViewController = NULL;
	
	self.searchDetailsViewController             = NULL;
	self.collectionDetailsViewController         = NULL;
	self.collectionRemovalsDetailsViewController = NULL;
	self.scannerDetailsViewController            = NULL;
	
	self.searchIndexPath     = NULL;
	self.collectionIndexPath = NULL;
	
	self.carImageRequesting       = false;
	self.carDetailImageRequesting = false;
	self.carSetOwnedRequesting    = false;
	
	return self;
}




- (void)registerSearchViewController:(searchViewController *) viewController
						   indexPath:(NSIndexPath *) indexPath
{
	self.searchViewController = viewController;
	self.searchIndexPath      = indexPath;
}

- (void)registerCollectionViewController:(collectionViewController *) viewController
							   indexPath:(NSIndexPath *) indexPath
{
	self.collectionViewController = viewController;
	self.collectionIndexPath      = indexPath;
}

- (void)registerCollectionRemovalsViewController:(collectionRemovalsViewController *) viewController
							   indexPath:(NSIndexPath *) indexPath
{
	self.collectionRemovalsViewController = viewController;
	self.collectionRemovalsIndexPath      = indexPath;
}


- (void)registerSearchDetailsViewController:(detailsViewController *) viewController
{
	self.searchDetailsViewController = viewController;
}

- (void)registerCollectionDetailsViewController:(detailsViewController *) viewController
{
	self.collectionDetailsViewController = viewController;
}

- (void)registerCollectionRemovalsDetailsViewController:(detailsViewController *) viewController
{
	self.collectionRemovalsDetailsViewController = viewController;
}

- (void)registerScannerDetailsViewController:(detailsViewController *) viewController
{
	self.scannerDetailsViewController = viewController;
}


- (void)unregisterSearchViewController
{
	self.searchViewController = NULL;
	self.searchIndexPath      = NULL;
}

- (void)unregisterCollectionViewController
{
	self.collectionViewController = NULL;
	self.collectionIndexPath      = NULL;
}

- (void)unregisterCollectionRemovalsViewController
{
	self.collectionRemovalsViewController = NULL;
	self.collectionRemovalsIndexPath      = NULL;
}


- (void)unregisterSearchDetailsViewController
{
	self.searchDetailsViewController = NULL;
}

- (void)unregisterCollectionDetailsViewController
{
	self.collectionDetailsViewController = NULL;
}

- (void)unregisterCollectionRemovalsDetailsViewController
{
	self.collectionRemovalsDetailsViewController = NULL;
}

- (void)unregisterScannerDetailsViewController
{
	self.scannerDetailsViewController = NULL;
}




- (void)downloadCarImage
{
	if (self.carImageRequesting)
		return;
	
	self.carImageRequesting = true;
	[self carUpdated];
	
	[HotWheels2API getImage:self.car.iconImageURL
			  imageCacheKey:self.car._id
			 imageIsDetails:false
		  completionHandler:^(NSError *error, UIImage *image)
	{
		self.carImageRequesting = false;
		
		self.car.iconImage = error ? [ImageBank getCarError] : image;
		
		[self carUpdated];
	}];
}

- (void)downloadCarDetailImage
{
	if (self.carDetailImageRequesting)
		return;
	
	self.carDetailImageRequesting = true;
	[self carUpdated];
	
	[HotWheels2API getImage:self.car.detailImageURL
			  imageCacheKey:self.car._id
			 imageIsDetails:true
		  completionHandler:^(NSError *error, UIImage *image)
	 {
		 self.carDetailImageRequesting = false;
		 
		 self.car.detailImage = error ? [ImageBank getCarError] : image;
		 
		 [self carUpdated];
	 }];
}

- (void)requestSetCarOwned:(NSString *) userID
				     owned:(bool)       owned
{
	if (self.carSetOwnedRequesting)
		return;
	
	self.carSetOwnedRequesting = true;
	[self carUpdated];
	
	[HotWheels2API setCarOwned:userID carID:self.car._id owned:owned completionHandler:^(NSError *error)
	{
		self.carSetOwnedRequesting = false;
		
		if (!error)
			self.car.owned = owned;
		
		[self carUpdated];
	}];
}




- (void)carUpdated
{
	if (self.searchViewController)
		[self.searchViewController carUpdated:self];
	if (self.collectionViewController)
		[self.collectionViewController carUpdated:self];
	if (self.collectionRemovalsViewController)
		[self.collectionRemovalsViewController carUpdated:self];
	
	if (self.searchDetailsViewController)
		[self.searchDetailsViewController carUpdated:self];
	if (self.collectionDetailsViewController)
		[self.collectionDetailsViewController carUpdated:self];
	if (self.collectionRemovalsDetailsViewController)
		[self.collectionRemovalsDetailsViewController carUpdated:self];
	if (self.scannerDetailsViewController)
		[self.scannerDetailsViewController carUpdated:self];
}
@end
