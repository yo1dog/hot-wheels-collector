//
//  CarWrapper.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/17/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Car.h"

#import "searchViewController.h"
#import "collectionViewController.h"
#import "collectionRemovalsViewController.h"
#import "detailsViewController.h"

@class searchViewController;
@class collectionViewController;
@class collectionRemovalsViewController;
@class detailsViewController;

@interface CarWrapper : NSObject
@property (nonatomic, strong) Car *car;

@property (nonatomic, weak) searchViewController             *searchViewController;
@property (nonatomic, weak) collectionViewController         *collectionViewController;
@property (nonatomic, weak) collectionRemovalsViewController *collectionRemovalsViewController;

@property (nonatomic, weak) detailsViewController *searchDetailsViewController;
@property (nonatomic, weak) detailsViewController *collectionDetailsViewController;
@property (nonatomic, weak) detailsViewController *collectionRemovalsDetailsViewController;
@property (nonatomic, weak) detailsViewController *scannerDetailsViewController;

@property (nonatomic, strong) NSIndexPath *searchIndexPath;
@property (nonatomic, strong) NSIndexPath *collectionIndexPath;
@property (nonatomic, strong) NSIndexPath *collectionRemovalsIndexPath;

@property bool carImageRequesting;
@property bool carDetailImageRequesting;
@property bool carSetOwnedRequesting;


- (id)init:(Car *) car;
- (void)carUpdated;


- (void)registerSearchViewController:(searchViewController *) viewController
						   indexPath:(NSIndexPath *) indexPath;

- (void)registerCollectionViewController:(collectionViewController *) viewController
							   indexPath:(NSIndexPath *) indexPath;

- (void)registerCollectionRemovalsViewController:(collectionRemovalsViewController *) viewController
							   indexPath:(NSIndexPath *) indexPath;

- (void)registerSearchDetailsViewController:(detailsViewController *) viewController;
- (void)registerCollectionDetailsViewController:(detailsViewController *) viewController;
- (void)registerCollectionRemovalsDetailsViewController:(detailsViewController *) viewController;
- (void)registerScannerDetailsViewController:(detailsViewController *) viewController;

- (void)unregisterSearchViewController;
- (void)unregisterCollectionViewController;
- (void)unregisterCollectionRemovalsViewController;

- (void)unregisterSearchDetailsViewController;
- (void)unregisterCollectionDetailsViewController;
- (void)unregisterCollectionRemovalsDetailsViewController;
- (void)unregisterScannerDetailsViewController;


- (void)downloadCarImage;
- (void)downloadCarDetailImage;
- (void)requestSetCarOwned:(NSString *) userID
				     owned:(bool)       owned;

@end
