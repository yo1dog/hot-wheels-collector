//
//  hotwheels2DetailsViewController.h
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarWrapper.h"

@class CarWrapper;

typedef enum detailViewParentViewTypes
{
	DVPV_SEARCH,
	DVPV_COLLECTION,
	DVPV_COLLECTION_REMOVALS,
	DVPV_SCANNER
} DetailViewParentViewType;

@interface detailsViewController : UIViewController
@property(nonatomic, strong) CarWrapper *carWrapper;
@property(nonatomic, strong) Car        *car;

@property DetailViewParentViewType parentViewType;

- (void)carUpdated:(CarWrapper *) carWrapper;
@end
