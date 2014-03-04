//
//  hotwheels2SecondViewController.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "collectionRemovalsViewController.h"

#import "CarManager.h"
#import "CarCell.h"
#import "HotWheels2API.h"
#import "ImageBank.h"
#import "UserManager.h"

#import "detailsViewController.h"

@interface collectionRemovalsViewController () <UICollectionViewDataSource>
@property(nonatomic, weak)   IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) IBOutlet UIBarButtonItem  *refreshButton;
@property(nonatomic, weak)   IBOutlet UILabel          *emptyCollectionRemovalsLabel;

@property(nonatomic, strong) UIBarButtonItem         *activityButton;
@property(nonatomic, strong) UIActivityIndicatorView *activityView;

@property(nonatomic, weak) CarManager *carManager;

@property(nonatomic, strong) NSMutableArray *collectionRemovals;
@property                    bool            collectionRemovalsRequesting;
@end



@implementation collectionRemovalsViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// get the car manager
	self.carManager = [CarManager getSingleton];
	
	// create the activity button for the navigation bar
	self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[self.activityView startAnimating];
	
	self.activityButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityView];
	
	// init some vars
	self.collectionRemovals = [NSMutableArray array];
	self.collectionRemovalsRequesting = false;
	
	// get the collection
	[self refreshCollectionRemovals];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


// refresh collection on view
/*- (void)viewWillAppear:(BOOL)animated
{
	[self refreshCollectionRemovals];
}*/




- (void)toggleRefreshActivity:(bool) show
{
	self.navigationItem.rightBarButtonItem = show ? self.activityButton : self.refreshButton;
}




- (IBAction)refreshButtonPressed:(id) sender
{
	[self refreshCollectionRemovals];
}



- (IBAction)badgeButtonPressed:(id) sender
{
	// if I refrence CarCellBadgeButton (sender) the reference gets overriden
	// get the car wrapper from the button
	CarWrapper *bbp_carWrapper = ((CarCellBadgeButton *)sender).carWrapper;
	
	// make request
	[bbp_carWrapper requestSetCarOwned:[UserManager getUserID] owned:!bbp_carWrapper.car.owned];
}




- (void)carUpdated:(CarWrapper *) carWrapper
{
	dispatch_async(dispatch_get_main_queue(), ^
	{
		if (carWrapper.collectionRemovalsIndexPath.row < [self.collectionRemovals count])
			[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:carWrapper.collectionRemovalsIndexPath]];
	});
}




- (void)refreshCollectionRemovals
{
	// make sure we are not already refreshing
	if (self.collectionRemovalsRequesting)
		return;
	
	// we are now requesting, disable the refresh button and show the activity indicator
	self.collectionRemovalsRequesting = true;
	self.refreshButton.enabled = false;
	[self toggleRefreshActivity:true];
	
	// make the request
	[HotWheels2API getCollectionRemovals:[UserManager getUserID] handler:^(NSError *rcr_error, NSMutableArray *rcr_cars)
	{
		self.collectionRemovalsRequesting = false;
		
		// enable the refresh button and hide the activity indicator
		dispatch_async(dispatch_get_main_queue(), ^
		{
			self.refreshButton.enabled = true;
			[self toggleRefreshActivity:false];
		});
		
		
		if (rcr_error)
			return;
		
		
		// unregister previous collection removals
		for (CarWrapper *carWrapper in self.collectionRemovals)
		{
			[carWrapper unregisterCollectionRemovalsViewController];
			[self.carManager checkForRemoval:carWrapper];
		}
		
		// wipe the old collection removals
		[self.collectionRemovals removeAllObjects];
		
		// add the new collection removals
		for (int i = 0; i < [rcr_cars count]; ++i)
		{
			// get/add the car from/to the car manager
			CarWrapper * carWrapper = [self.carManager getCarWrapper:rcr_cars[i]];
			
			// register self as the collectionRemovalsViewController
			[carWrapper registerCollectionRemovalsViewController:self indexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			
			[self.collectionRemovals addObject:carWrapper];
		}
		
		// update screen
		dispatch_async(dispatch_get_main_queue(), ^
		{
			[self.collectionView reloadData];
			
			// show the "no removals" label if did not get any results
			self.emptyCollectionRemovalsLabel.hidden = [self.collectionRemovals count] > 0;
		});
	}];
}




#pragma mark - UICollectionView Datasource
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
	return [self.collectionRemovals count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	// get the cell at the index path
	CarCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"CarSearchResultCell_CollectionRemovals" forIndexPath:indexPath];
	
	// get the car wrapper from the collection removals
	CarWrapper *carWrapper = (CarWrapper *)self.collectionRemovals[indexPath.row];
	
	// update the UI
	cell.label.text           = carWrapper.car.name;
	cell.imageView.image      = carWrapper.car.iconImage;
	cell.badgeImageView.image = carWrapper.car.owned ? [ImageBank getBadgeOwned] : [ImageBank getBadgeUnowned];
	cell.badgeImageView.alpha = carWrapper.carSetOwnedRequesting? 0.5f : 1.0f;
	
	// give the badge button the car wrapper so we know what to update when it is pressed
	cell.badgeButton.carWrapper = carWrapper;
	
	// if we don't have an image...
	if (carWrapper.car.iconImage == NULL)
	{
		// download the image
		[carWrapper downloadCarImage];
		
		// show the activity indicator
		if (![cell.activityView isAnimating])
			[cell.activityView startAnimating];
	}
	else
	{
		// hide the activity indicator
		if ([cell.activityView isAnimating])
			[cell.activityView stopAnimating];
	}
	
	return cell;
}




#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	// TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
	// TODO: Deselect item
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"collectionRemovals_showDetails"])
	{
		detailsViewController *controller = (detailsViewController *)segue.destinationViewController;
		
		// get the car wrapper based on the selected cell
		CarWrapper *carWrapper = self.collectionRemovals[[[self.collectionView indexPathsForSelectedItems][0] row]];
		
		// set the new car wrapper and register
		controller.carWrapper     = carWrapper;
		controller.parentViewType = DVPV_COLLECTION_REMOVALS;
	}
}
@end
