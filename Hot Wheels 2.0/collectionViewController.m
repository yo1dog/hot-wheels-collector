//
//  hotwheels2SecondViewController.m
//  Hot Wheels 2.0
//
//  Created by Mike on 12/12/13.
//  Copyright (c) 2013 Mike. All rights reserved.
//

#import "collectionViewController.h"

#import "CarManager.h"
#import "CarCell.h"
#import "HotWheels2API.h"
#import "ImageBank.h"
#import "UserManager.h"

#import "detailsViewController.h"

@interface collectionViewController () <UICollectionViewDataSource>
@property(nonatomic, weak)   IBOutlet UICollectionView *collectionView;
@property(nonatomic, strong) IBOutlet UIBarButtonItem  *refreshButton;
@property(nonatomic, weak)   IBOutlet UILabel          *emptyCollectionLabel;

@property(nonatomic, strong) UIBarButtonItem         *activityButton;
@property(nonatomic, strong) UIActivityIndicatorView *activityView;

@property(nonatomic, weak) CarManager *carManager;

@property(nonatomic, strong) NSMutableArray *collection;
@property                    bool            collectionRequesting;
@end



@implementation collectionViewController

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
	self.collection = [NSMutableArray array];
	self.collectionRequesting = false;
	
	// get the collection
	[self refreshCollection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// refresh collection on view
/*- (void)viewWillAppear:(BOOL)animated
 {
 [self refreshCollection];
 }*/




- (void)toggleRefreshActivity:(bool) show
{
	self.navigationItem.rightBarButtonItem = show ? self.activityButton : self.refreshButton;
}




- (IBAction)refreshButtonPressed:(id) sender
{
	[self refreshCollection];
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
		if (carWrapper.collectionIndexPath.row < [self.collection count])
			[self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:carWrapper.collectionIndexPath]];
	});
}




- (void)refreshCollection
{
	// make sure we are not already refreshing
	if (self.collectionRequesting)
		return;
	
	// we are now requesting, disable the refresh button and show the activity indicator
	self.collectionRequesting = true;
	self.refreshButton.enabled = false;
	[self toggleRefreshActivity:true];
	
	// make the request
	[HotWheels2API getCollection:[UserManager getUserID] handler:^(NSError *rc_error, NSMutableArray *rc_cars)
	{
		self.collectionRequesting = false;
		
		// enable the refresh button and hide the activity indicator
		dispatch_async(dispatch_get_main_queue(), ^
		{
			self.refreshButton.enabled = true;
			[self toggleRefreshActivity:false];
		});
		
		
		if (rc_error)
			return;
		
		
		// unregister previous collection
		for (CarWrapper *carWrapper in self.collection)
		{
			[carWrapper unregisterCollectionViewController];
			[self.carManager checkForRemoval:carWrapper];
		}
		
		// wipe the old collection
		[self.collection removeAllObjects];
		
		// add the new collection
		for (int i = 0; i < [rc_cars count]; ++i)
		{
			// get/add the car from/to the car manager
			CarWrapper * carWrapper = [self.carManager getCarWrapper:rc_cars[i]];
			
			// register self as the collectionViewController
			[carWrapper registerCollectionViewController:self indexPath:[NSIndexPath indexPathForRow:i inSection:0]];
			
			[self.collection addObject:carWrapper];
		}
		
		// update screen
		dispatch_async(dispatch_get_main_queue(), ^
		{
			[self.collectionView reloadData];
			
			self.navigationItem.title = [NSString stringWithFormat:@"Collection (%lu)", (unsigned long)[self.collection count]];
			
			// show the "empty collection" label if did not get any results
			self.emptyCollectionLabel.hidden = [self.collection count] > 0;
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
    return [self.collection count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	// get the cell at the index path
	CarCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"CarSearchResultCell_Collection" forIndexPath:indexPath];
	
	// get the car wrapper from the collection
	CarWrapper *carWrapper = (CarWrapper *)self.collection[indexPath.row];
	
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
	if ([segue.identifier isEqualToString:@"collection_showDetails"])
	{
		detailsViewController *controller = (detailsViewController *)segue.destinationViewController;
		
		// get the car wrapper based on the selected cell
		CarWrapper *carWrapper = self.collection[[[self.collectionView indexPathsForSelectedItems][0] row]];
		
		// set the new car wrapper and register
		controller.carWrapper     = carWrapper;
		controller.parentViewType = DVPV_COLLECTION;
    }
}
@end
